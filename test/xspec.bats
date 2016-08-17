
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

@test "invoking xspec without arguments prints usage" {
  run ../bin/xspec.sh
  [ "$status" -eq 1 ]
  [ "${lines[2]}" = "Usage: xspec [-t|-q|-c|-j|-h] filename [coverage]" ]
}


@test "invoking xspec generates XML report file" {
  run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
  run stat ../tutorial/xspec/escape-for-regex-result.xml
  [ "$status" -eq 0 ]
}

@test "invoking xspec generates HTML report file" {
  run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
  run stat ../tutorial/xspec/escape-for-regex-result.html
  [ "$status" -eq 0 ]
}

@test "invoking xspec with -j option with Saxon8 returns error message" {
  export SAXON_CP=/path/to/saxon8.jar
  run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Saxon8 detected. JUnit report requires Saxon9." ]
}


@test "invoking xspec with -j option with Saxon8-SA returns error message" {
  export SAXON_CP=/path/to/saxon8sa.jar
  run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Saxon8 detected. JUnit report requires Saxon9." ]
}


@test "invoking xspec with -j option generates message with JUnit report location" {
  run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
  [ "$status" -eq 0 ]
  [ "${lines[18]}" = "Report available at ../tutorial/xspec/escape-for-regex-junit.xml" ]
}

@test "invoking xspec with -j option generates XML report file" {
  run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
  run stat ../tutorial/xspec/escape-for-regex-result.xml
  [ "$status" -eq 0 ]
}

@test "invoking xspec with -j option generates JUnit report file" {
  run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
  run stat ../tutorial/xspec/escape-for-regex-junit.xml
  [ "$status" -eq 0 ]
}
