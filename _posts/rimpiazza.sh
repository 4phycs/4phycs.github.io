#!/bin/bash
# 
search="Paolo/2000-01-01-mapReduce.md"
replace="CalcoloParallelo/2000-01-01-mapReduce.md"


#search="CalcoloParalleleo/2000-01-01-MPI.md"
#replace="CalcoloParallelo/2000-01-01-MPI.md"

#  ricorsivo
#find . -type f -exec     sed -i  "s|$search|$replace|g"            {} +
sed -i  "s|$search|$replace|g"  *.md

