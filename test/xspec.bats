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
#       LICENSE:  GNU GPL v3
#
#===============================================================================

@test "invoking xspec without arguments prints usage" {
  run ../bin/xspec.sh
  [ "$status" -eq 1 ]
  [ "${lines[2]}" = "Usage: xspec [-t|-q|-c|-h] filename [coverage]" ]
}


@test "invoking code coverage with Saxon9HE returns error message" {
  export SAXON_CP=/path/to/saxon9he.jar
  run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9SA returns error message" {
  export SAXON_CP=/path/to/saxon9sa.jar
  run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9 returns error message" {
  export SAXON_CP=/path/to/saxon9.jar
  run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon8SA returns error message" {
  export SAXON_CP=/path/to/saxon8sa.jar
  run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon8 returns error message" {
  export SAXON_CP=/path/to/saxon8.jar
  run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9EE creates test stylesheet" {
  export SAXON_CP=/path/to/saxon9ee.jar
  run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking code coverage with Saxon9PE creates test stylesheet" {
  export SAXON_CP=/path/to/saxon9ee.jar
  run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Creating Test Stylesheet..." ]
}
