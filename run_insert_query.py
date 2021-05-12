import sys
import query_functions as qf

#arg 1 index level
#arg 2 number of iterations
index_level = 1
iterations = 1
if len(sys.argv) > 2:
    index_level = int(sys.argv[1])

if len(sys.argv) > 2:
    iterations = int(sys.argv[2])

print("Running insert query at index level {} for {} iterations".format(index_level, iterations))
qf.runInsertQuery(index_level, iterations)
