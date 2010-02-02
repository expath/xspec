## To use this Makefile, $SAXON_HOME must be set to a directory that
## contains either saxon9.jar (for B in 9.1 or below) or saxon9he.jar
## (for HE in 9.2 and above).  Set it the usual way you set environ
## variables.

# the classpath to invoke Saxon
CP=$$SAXON_HOME/saxon9he.jar:$$SAXON_HOME/saxon9.jar
# invoke Saxon as XSLT processor
XSLT=java -cp $(CP) net.sf.saxon.Transform
# invoke Saxon as XQuery processor
XQUERY=java -cp $(CP) net.sf.saxon.Query

### MAIN TARGETS ###

# run all tests
all: xslt xquery

# run XSLT tests
xslt: xspec-function-xsl.html                     \
      xspec-rule-xsl.html                         \
      xspec-import-xsl.html                       \
      xspec-pending-xsl.html

# run XQuery tests
xquery: xspec-function-xq.html                    \
        xspec-import-xq.html                      \
        xspec-pending-xq.html

# clean result files
clean:
	rm -fv *.html

### FILE RULES ###

# compile to XSLT
%.xsl: %.xspec
	$(XSLT)                                   \
	    -xsl:../generate-xspec-tests.xsl      \
	    -s:$<                                 \
	    -o:$@

# compile to XQuery
%.xq: %.xspec
	$(XSLT)                                   \
	    -xsl:../generate-query-tests.xsl      \
	    -s:$<                                 \
	    -o:$@

# run an XSLT compiled suite
%-xsl.xml: %.xsl xspec-tested.xsl
	$(XSLT)                                   \
	    -xsl:$<                               \
	    -o:$@                                 \
	    -it:"{http://www.jenitennison.com/xslt/xspec}main"

# run an XQuery compiled suite
%-xq.xml: %.xq xspec-tested.xql
	$(XQUERY)                                 \
	    -o:$@ $< '!indent=yes'

# format an XML report to HTML
%.html: %.xml
	$(XSLT)                                   \
	    -xsl:../format-xspec-report.xsl       \
	    -s:$<                                 \
	    -o:$@
