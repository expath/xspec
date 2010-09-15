#! /bin/bash

##############################################################################
##
## This script is used to compile a test suite to XSLT, run it, format
## the report and open it in a browser.
##
## It relies on the environment variable $SAXON_HOME to be set to the
## dir Saxon has been installed to (i.e. the containing the Saxon JAR
## file), or on $SAXON_CP to be set to a full classpath containing
## Saxon (and maybe more).  The later has precedence over the former.
##
## It also uses the environment variable XSPEC_HOME.  It must be set
## to the XSpec install directory.  By default, it uses this script's
## parent dir.
##
##############################################################################
##
## TODO: See issues 33 & 29 for several comments about shell scripts:
## http://code.google.com/p/xspec/issues/detail?id=33
## http://code.google.com/p/xspec/issues/detail?id=29
##
##############################################################################

##
## some variables ############################################################
##

# the classpath delimiter (aka ':', except ';' on Cygwin)
if uname | grep -i cygwin >/dev/null 2>&1; then
    CP_DELIM=";"
else
    CP_DELIM=":"
fi

# set XSPEC_HOME if it has not been set by the user (set it to the
# parent dir of this script)
if test -z "$XSPEC_HOME"; then
    XSPEC_HOME=`dirname $0`
    # safety checks
    if test \! -f "${XSPEC_HOME}/xspec.bat"; then
        echo "ERROR: XSPEC_HOME seems to be corrupted: ${XSPEC_HOME}"
        exit 1;
    fi
fi

if test \! -d "${XSPEC_HOME}"; then
    echo "ERROR: XSPEC_HOME is not a directory: ${XSPEC_HOME}"
    exit 1;
fi

# set SAXON_CP (either it has been by the user, or set it from SAXON_HOME)

if test -z "$SAXON_CP"; then
    # Set this variable in your environment or here, if you don't set SAXON_CP
    # SAXON_HOME=/path/to/saxon/dir
    if test -z "$SAXON_HOME"; then
        die "SAXON_CP and SAXON_HOME both not set!"
    fi
    if test -f "${SAXON_HOME}/saxon9ee.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9ee.jar";
    elif test -f "${SAXON_HOME}/saxon9pe.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9pe.jar";
    elif test -f "${SAXON_HOME}/saxon9he.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9he.jar";
    elif test -f "${SAXON_HOME}/saxon9sa.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9sa.jar";
    elif test -f "${SAXON_HOME}/saxon9.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9.jar";
    elif test -f "${SAXON_HOME}/saxon8sa.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon8sa.jar";
    elif test -f "${SAXON_HOME}/saxon8.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon8.jar";
    else
        die "Saxon jar cannot be found in SAXON_HOME: $SAXON_HOME"
    fi
fi

CP="${SAXON_CP}${CP_DELIM}${XSPEC_HOME}"

##
## utility functions #########################################################
##

die() {
    echo
    echo "*** $@" >&2
    exit 1
}

if [ `uname` = "Darwin" ]; then
    OPEN=open
else
    OPEN=see
fi

##
## options ###################################################################
##

XSPEC=$1

if [ ! -f "$XSPEC" ]
then
    echo File not found.
    echo Usage:
    echo   xspec filename [coverage]
    echo     filename should specify an XSpec document
    echo     if coverage is specified, outputs test coverage report
    exit 1
fi

COVERAGE=$2

##
## files and dirs ############################################################
##

TEST_DIR=$(dirname "$XSPEC")/xspec
TARGET_FILE_NAME=$(basename "$XSPEC" | sed 's:\...*$::')

COMPILED=$TEST_DIR/$TARGET_FILE_NAME.xsl
COVERAGE_XML=$TEST_DIR/$TARGET_FILE_NAME-coverage.xml
COVERAGE_HTML=$TEST_DIR/$TARGET_FILE_NAME-coverage.html
RESULT=$TEST_DIR/$TARGET_FILE_NAME-result.xml
HTML=$TEST_DIR/$TARGET_FILE_NAME-result.html
COVERAGE_CLASS=com.jenitennison.xslt.tests.XSLTCoverageTraceListener

if [ ! -d "$TEST_DIR" ]
then
    echo "Creating XSpec Directory at $TEST_DIR..."
    mkdir "$TEST_DIR"
    echo
fi 

##
## compile the suite #########################################################
##

echo "Creating Test Stylesheet..."
java -cp "$CP" net.sf.saxon.Transform -o:"$COMPILED" -s:"$XSPEC" \
    -xsl:"$XSPEC_HOME/generate-xspec-tests.xsl" \
    || die "Error compiling the test suite"
echo

##
## run the suite #############################################################
##

echo "Running Tests..."
if test "$COVERAGE" = "coverage" 
then 
    echo "Collecting test coverage data; suppressing progress report..."
    java -cp "$CP" net.sf.saxon.Transform -T:$COVERAGE_CLASS \
        -o:"$RESULT" -s:"$XSPEC" -xsl:"$COMPILED" \
        -it:{http://www.jenitennison.com/xslt/xspec}main 2> "$COVERAGE_XML" \
        || die "Error collecting test coverage data"
else
    java -cp "$CP" net.sf.saxon.Transform -o:"$RESULT" -s:"$XSPEC" -xsl:"$COMPILED" \
        -it:{http://www.jenitennison.com/xslt/xspec}main \
        || die "Error running the test suite"
fi

##
## format the report #########################################################
##

echo
echo "Formatting Report..."
java -cp "$CP" net.sf.saxon.Transform -o:"$HTML" -s:"$RESULT" \
    -xsl:"$XSPEC_HOME/format-xspec-report.xsl" \
    || die "Error formating the report"
if test "$COVERAGE" = "coverage" 
then
    java -cp "$CP" net.sf.saxon.Transform -l:on -o:"$COVERAGE_HTML" -s:"$COVERAGE_XML" \
        -xsl:"$XSPEC_HOME/coverage-report.xsl" "tests=$XSPEC" \
        || die "Error formating the coverage report"
    #$OPEN "$COVERAGE_HTML"
else
    #$OPEN "$HTML"
    echo
fi

echo "Done."
