CP=$$SAXON_HOME/saxon9he.jar:$$SAXON_HOME/saxon9.jar
XSLT=java -cp $(CP) net.sf.saxon.Transform
XQUERY=java -cp $(CP) net.sf.saxon.Query

all: xspec-function-xsl.html xspec-function-xq.html xspec-rule-xsl.html

clean:
	rm *.html

%.xsl: %.xspec
	$(XSLT)                                   \
	    -xsl:../generate-xspec-tests.xsl      \
	    -s:$<                                 \
	    -o:$@

%.xq: %.xspec
	$(XSLT)                                   \
	    -xsl:../generate-query-tests.xsl      \
	    -s:$<                                 \
	    -o:$@

%-xsl.xml: %.xsl xspec-tested.xsl
	$(XSLT)                                   \
	    -xsl:$<                               \
	    -o:$@                                 \
	    -it:"{http://www.jenitennison.com/xslt/xspec}main"

%-xq.xml: %.xq xspec-tested.xql
	$(XQUERY)                                 \
	    -o:$@ $< '!indent=yes'

%.html: %.xml
	$(XSLT)                                   \
	    -xsl:../format-xspec-report.xsl       \
	    -s:$<                                 \
	    -o:$@
