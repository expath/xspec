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
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Usage: xspec [-t|-q|-c|-j|-h] filename [coverage]" ]
}


@test "invoking code coverage with Saxon9HE returns error message" {
    export SAXON_CP=/path/to/saxon9he.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9SA returns error message" {
    export SAXON_CP=/path/to/saxon9sa.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9 returns error message" {
    export SAXON_CP=/path/to/saxon9.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon8SA returns error message" {
    export SAXON_CP=/path/to/saxon8sa.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon8 returns error message" {
    export SAXON_CP=/path/to/saxon8.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


# this test must run first to create xspec directory
@test "invoking code coverage with Saxon9EE creates test stylesheet" {
    export SAXON_CP=/path/to/saxon9ee.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Creating Test Stylesheet..." ]
}


@test "invoking code coverage with Saxon9PE creates test stylesheet" {
    export SAXON_CP=/path/to/saxon9pe.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking xspec generates XML report file" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    run stat ../tutorial/xspec/escape-for-regex-result.xml
	echo $output
    [ "$status" -eq 0 ]
}

@test "invoking xspec generates HTML report file" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    run stat ../tutorial/xspec/escape-for-regex-result.html
	echo $output
    [ "$status" -eq 0 ]
}

@test "invoking xspec with -j option with Saxon8 returns error message" {
    export SAXON_CP=/path/to/saxon8.jar
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Saxon8 detected. JUnit report requires Saxon9." ]
}


@test "invoking xspec with -j option with Saxon8-SA returns error message" {
    export SAXON_CP=/path/to/saxon8sa.jar
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Saxon8 detected. JUnit report requires Saxon9." ]
}


@test "invoking xspec with -j option generates message with JUnit report location" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at ../tutorial/xspec/escape-for-regex-junit.xml" ]
}

@test "invoking xspec with -j option generates XML report file" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    run stat ../tutorial/xspec/escape-for-regex-result.xml
	echo $output
    [ "$status" -eq 0 ]
}

@test "invoking xspec with -j option generates JUnit report file" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    run stat ../tutorial/xspec/escape-for-regex-junit.xml
	echo $output
    [ "$status" -eq 0 ]
}


@test "invoking xspec with Saxon-B-9-1-0-8 creates test stylesheet" {
    export SAXON_CP=/path/to/saxonb9-1-0-8.jar
	run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo $output
	[ "$status" -eq 1 ]
  	[ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking xspec.sh with TEST_DIR already set externally generates files inside TEST_DIR" {
    export TEST_DIR=/tmp
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at /tmp/escape-for-regex-result.html" ]
}


@test "invoking xspec.sh without TEST_DIR generates files in default location" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at ../tutorial/xspec/escape-for-regex-result.html" ]
}
