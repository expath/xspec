# SAXON is my script to launch Saxon[1].  In particular, it can launch
# both transform and queries.  TODO: This has to be adapted to be
# independent on the platform and usable by other people.
# [1]https://expath.org/svn/pkg/trunk/saxon/pkg-saxon/src/shell/saxon
SAXON=../../../../../bin/saxon

all: xspec-function-xsl.html xspec-function-xq.html xspec-rule-xsl.html

%.xsl: %.xspec
	"$(SAXON)"                                \
	    -xsl:../generate-xspec-tests.xsl      \
	    -s:$<                                 \
	    -o:$@

%.xq: %.xspec
	"$(SAXON)"                                \
	    -xsl:../generate-query-tests.xsl      \
	    -s:$<                                 \
	    -o:$@

%-xsl.xml: %.xsl xspec-tested.xsl
	"$(SAXON)"                                \
	    -xsl:$<                               \
	    -o:$@                                 \
	    -it:"{http://www.jenitennison.com/xslt/xspec}main"

%-xq.xml: %.xq xspec-tested.xql
	"$(SAXON)" --xq -o:$@ $< '!indent=yes'

%.html: %.xml
	"$(SAXON)"                                \
	    -xsl:../format-xspec-report.xsl       \
	    -s:$<                                 \
	    -o:$@
