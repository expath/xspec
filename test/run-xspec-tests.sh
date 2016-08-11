#!/bin/bash
# run it inside test directory
for xspectest in *.xspec; 
	do ../bin/xspec.sh $xspectest &> result.log; 
	if grep -q ".*failed:\s[1-9]" result.log; 
		then echo "$xspectest failed" && exit 1; 
	fi	
done
