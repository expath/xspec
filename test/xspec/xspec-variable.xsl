<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:__x="http://www.w3.org/1999/XSL/TransformAliasAlias"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:impl="urn:x-xspec:compile:xslt:impl"
                xmlns:t="http://www.jenitennison.com/xslt/xspec"
                xmlns:my="http://example.org/ns/my"
                version="2.0"
                exclude-result-prefixes="pkg impl">
   <xsl:import href="file:/home/sandro/Documents/programming/github/cirulls/xspec/test/xspec-tested.xsl"/>
   <xsl:import href="file:/home/sandro/Documents/programming/github/cirulls/xspec/src/compiler/generate-tests-utils.xsl"/>
   <xsl:namespace-alias stylesheet-prefix="__x" result-prefix="xsl"/>
   <xsl:variable name="x:stylesheet-uri"
                 as="xs:string"
                 select="'file:/home/sandro/Documents/programming/github/cirulls/xspec/test/xspec-tested.xsl'"/>
   <xsl:output name="x:report" method="xml" indent="yes"/>
   <xsl:variable name="test-data-doc"
                 as="document-node()"
                 select="doc('file:/home/sandro/Documents/programming/github/cirulls/xspec/test/xspec-variable.xml')"/>
   <xsl:variable name="test-data" select="$test-data-doc"/>
   <xsl:variable select="$test-data/*/test[xs:integer(@num) eq 3]" name="test-3"/>
   <xsl:template name="x:main">
      <xsl:message>
         <xsl:text>Testing with </xsl:text>
         <xsl:value-of select="system-property('xsl:product-name')"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="system-property('xsl:product-version')"/>
      </xsl:message>
      <xsl:result-document format="x:report">
         <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="file:/home/sandro/Documents/programming/github/cirulls/xspec/src/compiler/format-xspec-report.xsl"</xsl:processing-instruction>
         <x:report stylesheet="{$x:stylesheet-uri}" date="{current-dateTime()}">
            <xsl:call-template name="x:d5e4"/>
            <xsl:call-template name="x:d5e10"/>
         </x:report>
      </xsl:result-document>
   </xsl:template>
   <xsl:template name="x:d5e4">
      <xsl:message>call global var</xsl:message>
      <x:scenario>
         <x:label>call global var</x:label>
         <x:call function="my:square">
            <x:param select="$test-3/@num"/>
         </x:call>
         <xsl:variable name="x:result" as="item()*">
            <xsl:variable select="$test-3/@num" name="d6e1"/>
            <xsl:sequence select="my:square($d6e1)"/>
         </xsl:variable>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e7">
            <xsl:with-param name="x:result" select="$x:result"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e8">
            <xsl:with-param name="x:result" select="$x:result"/>
         </xsl:call-template>
      </x:scenario>
   </xsl:template>
   <xsl:template name="x:d5e7">
      <xsl:param name="x:result" required="yes"/>
      <xsl:message>the result</xsl:message>
      <xsl:variable name="impl:just-nodes"
                    select="                          $x:result instance of node()+"/>
      <xsl:variable name="impl:with-context"
                    select="                          exists($x:result) and empty($x:result[2]) or $impl:just-nodes"/>
      <xsl:variable name="impl:context" as="item()?">
         <xsl:choose>
            <xsl:when test="$impl:just-nodes">
               <xsl:document>
                  <xsl:sequence select="$x:result"/>
               </xsl:document>
            </xsl:when>
            <xsl:when test="$impl:with-context">
               <xsl:sequence select="$x:result"/>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="impl:assert" as="item()*">
         <xsl:choose>
            <xsl:when test="$impl:with-context">
               <xsl:for-each select="$impl:context">
                  <xsl:sequence select="$x:result eq $test-3/xs:integer(@value)"/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$x:result eq $test-3/xs:integer(@value)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="not($impl:assert instance of xs:boolean)">
         <xsl:message terminate="yes">ERROR in scenario "the result": @assert|@test did not return a boolean</xsl:message>
      </xsl:if>
      <xsl:variable name="impl:successful" as="xs:boolean" select="$impl:assert"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{ $impl:successful }">
         <x:label>the result</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
   <xsl:template name="x:d5e8">
      <xsl:param name="x:result" required="yes"/>
      <xsl:message>the result</xsl:message>
      <xsl:variable name="impl:with-context"
                    select="                          exists($x:result) and empty($x:result[2])"/>
      <xsl:variable name="impl:context" as="item()?">
         <xsl:choose>
            <xsl:when test="$impl:with-context">
               <xsl:sequence select="$x:result"/>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="impl:assert" as="item()*">
         <xsl:choose>
            <xsl:when test="$impl:with-context">
               <xsl:for-each select="$impl:context">
                  <xsl:sequence select="$x:result eq $test-3/xs:integer(@value)"/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$x:result eq $test-3/xs:integer(@value)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="not($impl:assert instance of xs:boolean)">
         <xsl:message terminate="yes">ERROR in scenario "the result": @assert|@test did not return a boolean</xsl:message>
      </xsl:if>
      <xsl:variable name="impl:successful" as="xs:boolean" select="$impl:assert"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{ $impl:successful }">
         <x:label>the result</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
   <xsl:template name="x:d5e10">
      <xsl:message>call local var</xsl:message>
      <x:scenario>
         <x:label>call local var</x:label>
         <x:call function="my:square">
            <x:param select="$param"/>
         </x:call>
         <xsl:variable select="$test-3/@num" name="param"/>
         <xsl:variable name="x:result" as="item()*">
            <xsl:variable select="$param" name="d18e1"/>
            <xsl:sequence select="my:square($d18e1)"/>
         </xsl:variable>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:variable select="$test-3/@value" name="result"/>
         <xsl:call-template name="x:d5e15">
            <xsl:with-param name="x:result" select="$x:result"/>
            <xsl:with-param name="param" select="$param"/>
            <xsl:with-param name="result" select="$result"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e16">
            <xsl:with-param name="x:result" select="$x:result"/>
            <xsl:with-param name="param" select="$param"/>
            <xsl:with-param name="result" select="$result"/>
         </xsl:call-template>
      </x:scenario>
   </xsl:template>
   <xsl:template name="x:d5e15">
      <xsl:param name="x:result" required="yes"/>
      <xsl:param name="param" required="yes"/>
      <xsl:param name="result" required="yes"/>
      <xsl:message>the result</xsl:message>
      <xsl:variable name="impl:just-nodes"
                    select="                          $x:result instance of node()+"/>
      <xsl:variable name="impl:with-context"
                    select="                          exists($x:result) and empty($x:result[2]) or $impl:just-nodes"/>
      <xsl:variable name="impl:context" as="item()?">
         <xsl:choose>
            <xsl:when test="$impl:just-nodes">
               <xsl:document>
                  <xsl:sequence select="$x:result"/>
               </xsl:document>
            </xsl:when>
            <xsl:when test="$impl:with-context">
               <xsl:sequence select="$x:result"/>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="impl:assert" as="item()*">
         <xsl:choose>
            <xsl:when test="$impl:with-context">
               <xsl:for-each select="$impl:context">
                  <xsl:sequence select="$x:result eq xs:integer($result)"/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$x:result eq xs:integer($result)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="not($impl:assert instance of xs:boolean)">
         <xsl:message terminate="yes">ERROR in scenario "the result": @assert|@test did not return a boolean</xsl:message>
      </xsl:if>
      <xsl:variable name="impl:successful" as="xs:boolean" select="$impl:assert"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{ $impl:successful }">
         <x:label>the result</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
   <xsl:template name="x:d5e16">
      <xsl:param name="x:result" required="yes"/>
      <xsl:param name="param" required="yes"/>
      <xsl:param name="result" required="yes"/>
      <xsl:message>the result</xsl:message>
      <xsl:variable name="impl:with-context"
                    select="                          exists($x:result) and empty($x:result[2])"/>
      <xsl:variable name="impl:context" as="item()?">
         <xsl:choose>
            <xsl:when test="$impl:with-context">
               <xsl:sequence select="$x:result"/>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="impl:assert" as="item()*">
         <xsl:choose>
            <xsl:when test="$impl:with-context">
               <xsl:for-each select="$impl:context">
                  <xsl:sequence select="$x:result eq xs:integer($result)"/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$x:result eq xs:integer($result)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="not($impl:assert instance of xs:boolean)">
         <xsl:message terminate="yes">ERROR in scenario "the result": @assert|@test did not return a boolean</xsl:message>
      </xsl:if>
      <xsl:variable name="impl:successful" as="xs:boolean" select="$impl:assert"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{ $impl:successful }">
         <x:label>the result</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
</xsl:stylesheet>
