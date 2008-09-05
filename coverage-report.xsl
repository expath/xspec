<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:test="http://www.jenitennison.com/xslt/unit-test"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs saxon">

<xsl:import href="format-utils.xsl" />

<xsl:param name="tests" as="xs:string" required="yes" />
  
<xsl:variable name="tests-uri" as="xs:anyURI"
  select="if (starts-with($tests, '/'))
          then xs:anyURI($tests)
          else xs:anyURI(concat('file:/', translate($tests, '\', '/')))" />
  
<xsl:variable name="stylesheet-uri" as="xs:anyURI"
  select="if (doc($tests-uri)/*/@stylesheet)
          then resolve-uri(doc($tests-uri)/*/@stylesheet, $tests-uri)
          else $tests-uri" />

<xsl:variable name="trace" as="document-node()" select="/" />

<xsl:variable name="stylesheet-trees" as="document-node()+"
  select="test:collect-stylesheets(doc($stylesheet-uri))" />

<xsl:function name="test:collect-stylesheets" as="document-node()+">
  <xsl:param name="stylesheets" as="document-node()+" />
  <xsl:variable name="imports" as="document-node()*"
    select="document($stylesheets/xsl:import/@href)" />
  <xsl:variable name="new-stylesheets" as="document-node()*"
    select="$stylesheets | $imports" />
  <xsl:choose>
    <xsl:when test="$imports except $stylesheets">
      <xsl:sequence select="test:collect-stylesheets($stylesheets | $imports)" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$stylesheets" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:key name="tree" match="node()" use="saxon:line-number(.)" />
<xsl:key name="coverage" match="hit" use="concat(@module, ':', @line)" />

<xsl:template match="/">
  <xsl:apply-templates select="." mode="test:coverage-report" />
</xsl:template>

<xsl:template match="/" mode="test:coverage-report">
  <html>
    <head>
      <title>Test Coverage Report for <xsl:value-of select="test:format-URI($stylesheet-uri)" /></title>
      <link rel="stylesheet" type="text/css" 
        href="{resolve-uri('test-report.css', static-base-uri())}" />
    </head>
    <body>
      <h1>Test Coverage Report</h1>
      <p>Stylesheet:  <a href="{$stylesheet-uri}"><xsl:value-of select="test:format-URI($stylesheet-uri)" /></a></p>
      <xsl:apply-templates select="$stylesheet-trees/xsl:*" mode="test:coverage-report" />
    </body>
  </html>
</xsl:template>
  
<xsl:template match="xsl:stylesheet | xsl:transform" mode="test:coverage-report">
  <xsl:variable name="stylesheet-uri" as="xs:anyURI"
    select="base-uri(.)" />
  <xsl:variable name="stylesheet-tree" as="document-node()"
    select=".." />
  <xsl:variable name="stylesheet-string" as="xs:string"
    select="unparsed-text($stylesheet-uri)" />
  <xsl:variable name="stylesheet-lines" as="xs:string+" 
    select="tokenize($stylesheet-string, '\n')" />
  <xsl:variable name="number-of-lines" as="xs:integer"
    select="count($stylesheet-lines)" />
  <xsl:variable name="number-width" as="xs:integer"
    select="string-length(xs:string($number-of-lines))" />
  <xsl:variable name="number-format" as="xs:string"
    select="string-join(for $i in 1 to $number-width return '0', '')" />
  <h2>
    module: <xsl:value-of select="$stylesheet-uri" />; 
    <xsl:value-of select="$number-of-lines" /> lines
  </h2>
  <pre>
    <xsl:apply-templates select="." mode="test:line">
      <xsl:with-param name="number-format" select="$number-format" tunnel="yes" />
      <xsl:with-param name="lines" select="$stylesheet-lines" tunnel="yes" />
      <xsl:with-param name="last-line" select="0" tunnel="yes" />
    </xsl:apply-templates>
  </pre>
</xsl:template>

<xsl:template match="text()[not(normalize-space())]" mode="test:line">
  <xsl:apply-templates select="following::node()[1]" mode="test:line" />
</xsl:template>

<xsl:template match="node()" mode="test:line">
  <xsl:param name="number-format" as="xs:string" required="yes" tunnel="yes" />
  <xsl:param name="lines" as="xs:string+" required="yes" tunnel="yes" />
  <xsl:param name="last-line" as="xs:integer" required="yes" tunnel="yes" />
  <xsl:variable name="line-number" as="xs:integer" select="saxon:line-number(.)" />
  <xsl:variable name="coverage" as="xs:string" select="test:coverage(.)" />
  <xsl:call-template name="test:output-lines">
    <xsl:with-param name="line-number" select="$last-line + 1" />
    <xsl:with-param name="lines"
      select="$lines[position() &lt;= $line-number]" />
    <xsl:with-param name="node-start" as="xs:string">
      <xsl:choose>
        <xsl:when test="self::element()">
          <xsl:value-of select="concat('&lt;', name(.))" />
        </xsl:when>
        <xsl:when test="self::text()">
          <xsl:value-of select="tokenize(., '&#xA;')[last()]" />
        </xsl:when>
      </xsl:choose>
    </xsl:with-param>
  </xsl:call-template>
  <xsl:apply-templates select="(node() | following::node())[1]" mode="test:line">
    <xsl:with-param name="last-line" select="$line-number" tunnel="yes" />
  </xsl:apply-templates>
</xsl:template>

<xsl:template name="test:output-lines">
  <xsl:param name="line-number" as="xs:integer" required="yes" />
  <xsl:param name="lines" as="xs:string*" required="yes" />
  <xsl:param name="node-start" as="xs:string" required="yes" />
</xsl:template>

<xsl:function name="test:coverage" as="xs:string">
  <xsl:param name="node" as="node()" />
  <xsl:choose>
    <!-- A hit on these nodes doesn't really count; you have to hit
      their contents to hit them -->
    <xsl:when test="$node/self::xsl:otherwise or
                    $node/self::xsl:when or
                    $node/self::xsl:matching-substring or
                    $node/self::xsl:non-matching-substring or
                    $node/self::xsl:for-each">
      <xsl:variable name="hits-on-content" as="element(hit)*"
        select="test:hit-on-nodes($node/node())" />
      <xsl:choose>
        <xsl:when test="exists($hits-on-content)">hit</xsl:when>
        <xsl:otherwise>missed</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="hit" as="element(hit)*"
        select="test:hit-on-nodes($node)" />
      <xsl:choose>
        <xsl:when test="exists($hit)">hit</xsl:when>
        <xsl:when test="$node/self::xsl:variable">
          <xsl:sequence select="test:coverage($node/following-sibling::*[not(self::xsl:variable)][1])" />
        </xsl:when>
        <xsl:when test="$node/ancestor::xsl:variable">
          <xsl:sequence select="test:coverage($node/ancestor::xsl:variable)" />
        </xsl:when>
        <xsl:when test="$node/self::xsl:stylesheet or
                        $node/self::xsl:transform">ignored</xsl:when>
        <xsl:when test="$node/self::xsl:function or
                        $node/self::xsl:template">missed</xsl:when>
        <!-- A node within an top-level non-XSLT element -->
        <xsl:when test="not($node/ancestor::xsl:*/parent::xsl:stylesheet)">ignored</xsl:when>
        <xsl:when test="$node/self::xsl:param">
          <xsl:sequence select="test:coverage($node/parent::*)" />
        </xsl:when>
        <xsl:otherwise>missed</xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="test:hit-on-nodes" as="element(hit)*">
  <xsl:param name="nodes" as="node()*" />
  <xsl:for-each select="$nodes[not(self::text()[not(normalize-space())])]">
    <xsl:variable name="stylesheet-path" as="xs:string"
      select="if (starts-with(base-uri(.), '/'))
              then concat('file:', base-uri(.))
              else base-uri(.)" />
    <xsl:sequence select="test:hit-on-lines(saxon:line-number(.), $stylesheet-path)" />
  </xsl:for-each>
</xsl:function>

<xsl:function name="test:hit-on-lines" as="element(hit)*">
  <xsl:param name="line-numbers" as="xs:integer*" />
  <xsl:variable name="stylesheet-path" as="xs:string"
    select="if (starts-with($stylesheet-uri, '/'))
            then concat('file:', $stylesheet-uri)
            else $stylesheet-uri" />
  <xsl:sequence select="test:hit-on-lines($line-numbers, $stylesheet-path)" />
</xsl:function>

<xsl:function name="test:hit-on-lines" as="element(hit)*">
  <xsl:param name="line-numbers" as="xs:integer*" />
  <xsl:param name="stylesheet-path" as="xs:string" />
  <xsl:variable name="keys" as="xs:string*"
    select="for $l in $line-numbers
            return concat($stylesheet-path, ':', $l)" />
  <xsl:sequence select="key('coverage', $keys, $trace)" />
</xsl:function>

</xsl:stylesheet>
