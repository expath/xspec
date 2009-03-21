<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:s="http://www.jenitennison.com/xslt/xspec"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                exclude-result-prefixes="s xs test"
                xmlns="http://www.w3.org/1999/xhtml">
  
<xsl:import href="format-utils.xsl" />

<xsl:template match="/">
  <xsl:apply-templates select="." mode="s:html-report" />
</xsl:template>  
  
<xsl:template match="s:report" mode="s:html-report">
  <html>
    <head>
      <title>Test Report for <xsl:value-of select="test:format-URI(@stylesheet)" /></title>
      <link rel="stylesheet" type="text/css" 
            href="{resolve-uri('test-report.css', static-base-uri())}" />
    </head>
    <body>
      <h1>Test Report</h1>
      <p>Stylesheet:  <a href="{@stylesheet}"><xsl:value-of select="test:format-URI(@stylesheet)" /></a></p>
      <p>
        <xsl:text>Tested: </xsl:text>
        <xsl:value-of select="format-dateTime(@date, '[D] [MNn] [Y] at [H01]:[m01]')" />
      </p>
      <h2>Contents</h2>
      <table class="xspec">
        <col width="85%" />
        <col width="15%" />
        <thead>
          <tr>
            <th style="text-align: right; font-weight: normal; ">passed/pending/failed/total</th>
            <th>
              <xsl:call-template name="s:totals">
                <xsl:with-param name="tests" select="//s:test" />
              </xsl:call-template>
            </th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="s:scenario">
            <xsl:variable name="pending" as="xs:boolean"
              select="exists(@pending)" />
            <xsl:variable name="any-failure" as="xs:boolean"
              select="exists(.//s:test[@successful = 'false'])" />
            <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
              <th>
                <xsl:if test="@pending != ''">(<strong><xsl:value-of select="@pending" /></strong>) </xsl:if>
                <a href="#{generate-id()}">
                  <xsl:apply-templates select="s:label" mode="s:html-report" />
                </a>
              </th>
              <th>
                <xsl:call-template name="s:totals">
                  <xsl:with-param name="tests" select=".//s:test" />
                </xsl:call-template>
              </th>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
      <xsl:for-each select="s:scenario[not(@pending)]">
        <div id="{generate-id()}">
          <h2>
            <xsl:if test="@pending != ''">(<strong><xsl:value-of select="@pending" /></strong>) </xsl:if>
            <xsl:apply-templates select="s:label" mode="s:html-report" />
          </h2>
          <table class="xspec" id="{generate-id()}">
            <col width="85%" />
            <col width="15%" />
            <thead>
              <tr>
                <th style="text-align: right; font-weight: normal; ">passed/pending/failed/total</th>
                <th>
                  <xsl:call-template name="s:totals">
                    <xsl:with-param name="tests" select=".//s:test" />
                  </xsl:call-template>
                </th>
              </tr>
            </thead>
            <tbody>
              <xsl:variable name="pending" as="xs:boolean"
                select="exists(@pending)" />
              <xsl:variable name="any-failure" as="xs:boolean"
                select="exists(s:test[@successful = 'false'])" />
              <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
                <th>
                  <xsl:if test="@pending != ''">(<strong><xsl:value-of select="@pending" /></strong>) </xsl:if>
                  <xsl:apply-templates select="s:label" mode="s:html-report" />
                </th>
                <th>
                  <xsl:call-template name="s:totals">
                    <xsl:with-param name="tests" select="s:test" />
                  </xsl:call-template>
                </th>
              </tr>
              <xsl:apply-templates select="s:test" mode="s:html-summary" />
              <xsl:for-each select=".//s:scenario[s:test]">
                <xsl:variable name="pending" as="xs:boolean"
                  select="exists(@pending)" />
                <xsl:variable name="any-failure" as="xs:boolean"
                  select="exists(s:test[@successful = 'false'])" />
                <xsl:variable name="label" as="node()+">
                	<xsl:for-each select="ancestor-or-self::s:scenario[position() != last()]">
                		<xsl:apply-templates select="s:label" mode="s:html-report" />
                		<xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if>
                	</xsl:for-each>
                </xsl:variable>
                <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
                  <th>
                    <xsl:if test="@pending != ''">(<strong><xsl:value-of select="@pending" /></strong>) </xsl:if>
                    <xsl:choose>
                      <xsl:when test="$any-failure">
                        <a href="#{generate-id()}">
                          <xsl:sequence select="$label" />
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:sequence select="$label" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </th>
                  <th>
                    <xsl:call-template name="s:totals">
                      <xsl:with-param name="tests" select="s:test" />
                    </xsl:call-template>
                  </th>
                </tr>
                <xsl:apply-templates select="s:test" mode="s:html-summary" />
              </xsl:for-each>
            </tbody>
          </table>
          <xsl:apply-templates select="descendant-or-self::s:scenario[s:test[@successful = 'false']]" mode="s:html-report" />
        </div>
      </xsl:for-each>
    </body>
  </html>
</xsl:template>

<xsl:template match="s:test[exists(@pending)]" mode="s:html-summary">
  <tr class="pending">
    <td>
      <xsl:if test="@pending != '' and @pending != ../@pending">(<strong><xsl:value-of select="@pending" /></strong>) </xsl:if>
      <xsl:apply-templates select="s:label" mode="s:html-report" />
    </td>
    <td>Pending</td>
  </tr>
</xsl:template>

<xsl:template match="s:test[@successful = 'true']" mode="s:html-summary">
  <tr class="successful">
  	<td><xsl:apply-templates select="s:label" mode="s:html-report" /></td>
    <td>Success</td>
  </tr>
</xsl:template>
  
<xsl:template match="s:test[@successful = 'false']" mode="s:html-summary">
  <tr class="failed">                  
    <td>
      <a href="#{generate-id()}">
      	<xsl:apply-templates select="s:label" mode="s:html-report" />
      </a>
    </td>
    <td>Failure</td>
  </tr>
</xsl:template>
  
<xsl:template match="s:scenario" mode="s:html-report">
  <h3 id="{generate-id()}">
  	<xsl:for-each select="ancestor-or-self::s:scenario">
  		<xsl:apply-templates select="s:label" mode="s:html-report" />
  		<xsl:if test="position() != last()">
  			<xsl:text> </xsl:text>
  		</xsl:if>
  	</xsl:for-each>
  </h3>
  <xsl:apply-templates select="s:test[@successful = 'false']" mode="s:html-report" />
</xsl:template>  
  
<xsl:template match="s:test" mode="s:html-report">
  <xsl:variable name="result" as="element(s:result)"
    select="if (s:result) then s:result else ../s:result" />
  <h4 id="{generate-id()}">
    <xsl:apply-templates select="s:label" mode="s:html-report" />
  </h4>
  <table class="xspecResult">
    <thead>
      <tr>
        <th>Result</th>
        <th>
          <xsl:choose>
            <xsl:when test="s:result">Expecting</xsl:when>
            <xsl:otherwise>Expected Result</xsl:otherwise>
          </xsl:choose>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>
          <xsl:apply-templates select="$result" mode="s:value">
            <xsl:with-param name="comparison" select="s:expect" />
          </xsl:apply-templates>
        </td>
        <td>
          <xsl:choose>
            <xsl:when test="not(s:result) and s:expect/@test">
              <pre>
                <xsl:value-of select="@test" />
              </pre>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="s:expect" mode="s:value">
                <xsl:with-param name="comparison" select="$result" />
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>
        </td>
      </tr>
    </tbody>
  </table>
</xsl:template>  

<xsl:template match="*" mode="s:value">
  <xsl:param name="comparison" as="element()?" select="()" />
  <xsl:variable name="expected" as="xs:boolean" select=". instance of element(s:expect)" />
  <xsl:choose>
    <xsl:when test="@href or node()">
      <xsl:if test="@select">
        <p>XPath <code><xsl:value-of select="@select" /></code> from:</p>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@href">
          <p><a href="{@href}"><xsl:value-of select="test:format-URI(@href)" /></a></p>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="indentation"
            select="string-length(substring-after(text()[1], '&#xA;'))" />
          <pre>
            <xsl:choose>
              <xsl:when test="exists($comparison)">
                <xsl:variable name="compare" as="node()*" 
                  select="if ($comparison/@href) 
                          then document($comparison/@href)/node() 
                          else $comparison/(node() except text()[not(normalize-space())])" />
                <xsl:for-each select="node() except text()[not(normalize-space())]">
                  <xsl:variable name="pos" as="xs:integer" select="position()" />
                  <xsl:apply-templates select="." mode="test:serialize">
                    <xsl:with-param name="indentation" tunnel="yes" select="$indentation" />
                    <xsl:with-param name="perform-comparison" tunnel="yes" select="true()" />
                    <xsl:with-param name="comparison" select="$compare[position() = $pos]" />
                    <xsl:with-param name="expected" select="$expected" />
                  </xsl:apply-templates>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="node() except text()[not(normalize-space())]" mode="test:serialize">
                  <xsl:with-param name="indentation" tunnel="yes"
                    select="$indentation" />
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </pre>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <pre><xsl:value-of select="@select" /></pre>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>  

<xsl:template name="s:totals">
  <xsl:param name="tests" as="element(s:test)*" required="yes" />
  <xsl:param name="labels" as="xs:boolean" select="false()" />
  <xsl:if test="$tests">
    <xsl:variable name="passed" as="element(s:test)*" select="$tests[@successful = 'true']" />
    <xsl:variable name="pending" as="element(s:test)*" select="$tests[exists(@pending)]" />
    <xsl:variable name="failed" as="element(s:test)*" select="$tests[@successful = 'false']" />
    <xsl:if test="$labels">passed: </xsl:if>
    <xsl:value-of select="count($passed)" />
    <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
    <xsl:text>/</xsl:text>
    <xsl:if test="$labels"> pending: </xsl:if>
    <xsl:value-of select="count($pending)" />
    <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
    <xsl:text>/</xsl:text>
    <xsl:if test="$labels"> failed: </xsl:if>
    <xsl:value-of select="count($failed)" />
    <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
    <xsl:text>/</xsl:text>
    <xsl:if test="$labels"> total: </xsl:if>
    <xsl:value-of select="count($tests)" />
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
