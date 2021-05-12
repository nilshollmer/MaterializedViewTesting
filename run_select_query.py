import sys
import query_functions as qf


#arg 1 query name
#arg 2 number of iterations
query_name = ""
iterations = 1

if len(sys.argv) > 1:
    query_name = sys.argv[1]

if len(sys.argv) > 2:
    iterations = int(sys.argv[2])

if query_name != "":
    print("Running query {} for {} iterations".format(query_name, iterations))
    qf.runSelectQuery(query_name, iterations)
else:
    print("No query given")