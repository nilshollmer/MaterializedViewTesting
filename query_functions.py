import pyodbc
import csv

driver = '{ODBC Driver 17 for SQL Server}'
server = 'LAPTOP-RTFAICSU\MSSQLSERVER01' # Change this name to the server name of your choice 
database = 'RadonovaDB' 


def runInsertQuery(level, iterations=1):
    query_to_run = "sql/insert/insert_query.sql"
    filename = "csv/insert/insert_query_level_{}.csv".format(level)

    with open(filename, 'a+', newline='') as csvfile:
        wr = csv.writer(csvfile, delimiter=',',
                        quotechar='"', quoting=csv.QUOTE_MINIMAL)

        columns = ['Query text', 'CPU time in kb', 'Execution time in kb',
                   'Logical reads', 'Physical reads', 'Rows', 'Iterations']
        wr.writerow(["Index level " + str(level)])
        wr.writerow(columns)

    
    changeIndexLevel(level)

    executeScriptFromFile(query_to_run, 1)

    clearQueryPerformance()
    executeScriptFromFile(query_to_run, iterations)

    printInsertPerformance(filename, level)


def runSelectQuery(query_name, iterations=1):
    index_levels = 9

    query_folder = "sql/select/{}/".format(str(query_name))
    csv_folder = "csv/select/"
    query_version = "unindexed"

    filename = csv_folder + query_name + '.csv'

    # Create a new file, overwriting the old one if exists
    with open(filename, 'w+', newline='') as csvfile:
        wr = csv.writer(csvfile, delimiter=',',
                        quotechar='"', quoting=csv.QUOTE_MINIMAL)

        columns = ['Level', 'CPU time in kb', 'Execution time in kb',
                   'Logical reads', 'Physical reads', 'Rows', 'Iterations']
        wr.writerow(columns)
        

    print(
        f"Level     : {'CPU': <8}|{'Time': <8}|{'Logical': <8}|{'Physical': <8}|{'Rows': <8}|{'Iterations': <8}")
    for level in range(1, index_levels + 1):

        if level == 1:
            query_version = 'unindexed'
        else:
            query_version = 'indexed'

        changeIndexLevel(level)

        query_to_run = query_folder + query_version + ".sql"

        executeScriptFromFile(query_to_run, 1)

        clearQueryPerformance()
        executeScriptFromFile(query_to_run, iterations)

        printSelectPerformance(filename, level)
 

def executeScriptFromFile(filename, iterations=1, delimiter="\n\n\n"):
    try:
        i = 0
        query_handler = open(filename, 'r')
        query_file = query_handler.read()
        query_handler.close()
        
        sql_commands = query_file.split(delimiter)

        while i < iterations:
            cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';DATABASE='+database+';TRUSTED_CONNECTION=YES')
            cursor = cnxn.cursor()
            for command in sql_commands:
                try:
                    cursor.execute(command)
                    cnxn.commit()
                except Exception as e:
                    print('Command skipped: ', e)
                    print(command)
            cnxn.close()
            i += 1
    except:
        print("Invalid filename")



def printSelectPerformance(filename="standard", index_level="Undefined"):
    cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';DATABASE='+database+';TRUSTED_CONNECTION=YES')
    cursor = cnxn.cursor()

    sql_query = '''
SELECT
    AVG(cpu_time),
    AVG(elapsed_time),
    AVG(total_logical_reads),
    AVG(total_physical_reads),
    total_rows,
    COUNT(*),
    query_text
FROM
    Performance.Radonova.QueryPerformance
GROUP BY
    query_text, total_rows;
    '''
    
    cursor.execute(sql_query)
    result = cursor.fetchall()
    try:
        with open(filename, 'a', newline='') as csvfile:
            wr = csv.writer(csvfile, delimiter=',',
                                    quotechar='"', quoting=csv.QUOTE_MINIMAL)

            for row in result:
                tmp = [index_level] + list(row)
                wr.writerow(tmp[:-1])
            
                print(
                    f"{tmp[0]: <8}  : {tmp[1]: <8}|{tmp[2]: <8}|{tmp[3]: <8}|{tmp[4]: <8}|{tmp[5]: <8}|{tmp[6]: <8}")
    except:
        print("Invalid filename")
    finally:
        cnxn.close()


def printInsertPerformance(filename="standard", level="Undefined"):
    cnxn = pyodbc.connect('DRIVER='+driver+'ERVER=' +
                          server+';DATABASE='+database+';TRUSTED_CONNECTION=YES')
    cursor = cnxn.cursor()

    sql_query = '''
SELECT
    query_text,
    AVG(cpu_time),
    AVG(elapsed_time),
    AVG(total_logical_reads),
    AVG(total_physical_reads),
    total_rows,
    COUNT(*)
FROM
    Performance.Radonova.QueryPerformance
GROUP BY
    query_text, total_rows;
    '''
    cursor.execute(sql_query)
    result = cursor.fetchall()

    with open(filename, 'a', newline='') as csvfile:
        wr = csv.writer(csvfile, delimiter=',',
                        quotechar='"', quoting=csv.QUOTE_MINIMAL)

        for row in result:
            wr.writerow(row)

    cnxn.close()



def clearQueryPerformance():
    cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';DATABASE='+database+';TRUSTED_CONNECTION=YES')
    cursor = cnxn.cursor()

    sql_query = '''DELETE FROM Performance.Radonova.QueryPerformance;'''
    cursor.execute(sql_query)
    cnxn.commit()
    cnxn.close()


def changeIndexLevel(level=1):
    cnxn = pyodbc.connect('DRIVER='+driver+';SERVER='+server+';DATABASE='+database+';TRUSTED_CONNECTION=YES')
    cursor = cnxn.cursor()

    filename = "sql/views/index_level_{}.sql".format(level)

    try:
        handler = open(filename, 'r')
        query_file = handler.read()
        handler.close()
        sql_commands = query_file.split(';')
        for command in sql_commands:
            try:
                cursor.execute(command)
                cnxn.commit()
            except Exception as e:
                print('Command skipped: ', e)
            
        #print("Index level set to {}.".format(level))
    except:
        print("Invalid filename")
    finally:
        cnxn.close()
