import sys
from query_functions import changeIndexLevel

program_name = sys.argv[0]
index_level = 1

if len(sys.argv) > 1:
    index_level = sys.argv[1]

changeIndexLevel(index_level)