#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Collect & Check domains data

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# 1. merge
./merge_roots.sh

# Check 
# python3 filter_domains.py; mv cleaned.txt warm.txt

#2. Check domains
./check-alive-multi.sh

# 3. Check aval
./check-alive.sh warm.txt

# Merge
grep -vFf nxdomains.log warm.txt > clean_warm.txt; mv clean_warm.txt warm.txt; echo "" > nxdomains.log

# Final
./check-alive.sh warm.txt
