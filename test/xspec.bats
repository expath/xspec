#!/usr/bin/env bats
#===============================================================================
#
#         USAGE:  bats xspec.bats 
#         
#   DESCRIPTION:  Unit tests for script bin/xspec.sh 
#
#         INPUT:  N/A
#
#        OUTPUT:  Unit tests results
#
#  DEPENDENCIES:  This script requires bats (https://github.com/sstephenson/bats)
#
#        AUTHOR:  Sandro Cirulli, github.com/cirulls
#
#       LICENSE:  MIT License (https://opensource.org/licenses/MIT)
#
#===============================================================================


@test "invoking xspec with Saxon9-1-0-8 (Saxon-B) returns correct version number at compile time" {
	run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	[ "$status" -eq 0 ]
  	[ "${lines[3]}" = "Testing with SAXON 9.1.0.8" ]
}


@test "invoking xspec with Saxon9-1-0-8 (Saxon-B) creates test stylesheet" {
	run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	[ "$status" -eq 0 ]
  	[ "${lines[1]}" = "Creating Test Stylesheet..." ]
}
