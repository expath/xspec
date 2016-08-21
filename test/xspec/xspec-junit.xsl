<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:__x="http://www.w3.org/1999/XSL/TransformAliasAlias"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:impl="urn:x-xspec:compile:xslt:impl"
                version="3.0"
                exclude-result-prefixes="pkg impl">
   <xsl:import href="file:/home/sandro/Documents/programming/github/cirulls/xspec/src/reporter/junit-report.xsl"/>
   <xsl:import href="file:/home/sandro/Documents/programming/github/cirulls/xspec/src/compiler/generate-tests-utils.xsl"/>
   <xsl:namespace-alias stylesheet-prefix="__x" result-prefix="xsl"/>
   <xsl:variable name="x:stylesheet-uri"
                 as="xs:string"
                 select="'file:/home/sandro/Documents/programming/github/cirulls/xspec/src/reporter/junit-report.xsl'"/>
   <xsl:output name="x:report" method="xml" indent="yes"/>
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
            <xsl:call-template name="x:d5e2"/>
            <xsl:call-template name="x:d5e15"/>
            <xsl:call-template name="x:d5e30"/>
         </x:report>
      </xsl:result-document>
   </xsl:template>
   <xsl:template name="x:d5e2">
      <xsl:message>When processing a successful test</xsl:message>
      <x:scenario>
         <x:label>When processing a successful test</x:label>
         <x:context>
            <x:test successful="true">
               <x:label>
                  <xsl:text>Successful test</xsl:text>
               </x:label>
               <x:result>
                  <p>
                     <xsl:text>Foo</xsl:text>
                  </p>
               </x:result>
               <x:expect>
                  <p>
                     <xsl:text>Foo</xsl:text>
                  </p>
               </x:expect>
            </x:test>
         </x:context>
         <xsl:variable name="x:result" as="item()*">
            <xsl:variable name="impl:context-doc" as="document-node()">
               <xsl:document>
                  <x:test successful="true">
                     <x:label>
                        <xsl:text>Successful test</xsl:text>
                     </x:label>
                     <x:result>
                        <p>
                           <xsl:text>Foo</xsl:text>
                        </p>
                     </x:result>
                     <x:expect>
                        <p>
                           <xsl:text>Foo</xsl:text>
                        </p>
                     </x:expect>
                  </x:test>
               </xsl:document>
            </xsl:variable>
            <xsl:variable name="impl:context" select="$impl:context-doc/node()"/>
            <xsl:apply-templates select="$impl:context"/>
         </xsl:variable>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e13">
            <xsl:with-param name="x:result" select="$x:result"/>
         </xsl:call-template>
      </x:scenario>
   </xsl:template>
   <xsl:template name="x:d5e13">
      <xsl:param name="x:result" required="yes"/>
      <xsl:message>convert it to test case with status passed</xsl:message>
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
      <xsl:variable name="impl:expected-doc" as="document-node()">
         <xsl:document>
            <testcase name="Successful test" status="passed"/>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="impl:expected" select="$impl:expected-doc/node()"/>
      <xsl:variable name="impl:successful"
                    as="xs:boolean"
                    select="                    test:deep-equal(                      $impl:expected,                      if ( $impl:with-context ) then $impl:context else $x:result,                      3)"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{ $impl:successful }">
         <x:label>convert it to test case with status passed</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$impl:expected"/>
            <xsl:with-param name="wrapper-name" select="'x:expect'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
   <xsl:template name="x:d5e15">
      <xsl:message>When processing a failing test</xsl:message>
      <x:scenario>
         <x:label>When processing a failing test</x:label>
         <x:context>
            <x:test successful="false">
               <x:label>
                  <xsl:text>failing test</xsl:text>
               </x:label>
               <x:result>
                  <p>
                     <xsl:text>Foo</xsl:text>
                  </p>
               </x:result>
               <x:expect>
                  <p>
                     <xsl:text>Bar</xsl:text>
                  </p>
               </x:expect>
            </x:test>
         </x:context>
         <xsl:variable name="x:result" as="item()*">
            <xsl:variable name="impl:context-doc" as="document-node()">
               <xsl:document>
                  <x:test successful="false">
                     <x:label>
                        <xsl:text>failing test</xsl:text>
                     </x:label>
                     <x:result>
                        <p>
                           <xsl:text>Foo</xsl:text>
                        </p>
                     </x:result>
                     <x:expect>
                        <p>
                           <xsl:text>Bar</xsl:text>
                        </p>
                     </x:expect>
                  </x:test>
               </xsl:document>
            </xsl:variable>
            <xsl:variable name="impl:context" select="$impl:context-doc/node()"/>
            <xsl:apply-templates select="$impl:context"/>
         </xsl:variable>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e26">
            <xsl:with-param name="x:result" select="$x:result"/>
         </xsl:call-template>
      </x:scenario>
   </xsl:template>
   <xsl:template name="x:d5e26">
      <xsl:param name="x:result" required="yes"/>
      <xsl:message>convert it to test case with status failed</xsl:message>
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
      <xsl:variable name="impl:expected-doc" as="document-node()">
         <xsl:document>
            <testcase name="failing test" status="failed">
               <failure message="expect assertion failed">
                  <xsl:text>&lt;x:expect xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:test="http://www.jenitennison.com/xslt/unit-test" xmlns:x="http://www.jenitennison.com/xslt/xspec"&gt;&lt;p&gt;Bar&lt;/p&gt;&lt;/x:expect&gt;</xsl:text>
               </failure>
            </testcase>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="impl:expected" select="$impl:expected-doc/node()"/>
      <xsl:variable name="impl:successful"
                    as="xs:boolean"
                    select="                    test:deep-equal(                      $impl:expected,                      if ( $impl:with-context ) then $impl:context else $x:result,                      3)"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{ $impl:successful }">
         <x:label>convert it to test case with status failed</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$impl:expected"/>
            <xsl:with-param name="wrapper-name" select="'x:expect'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
   <xsl:template name="x:d5e30">
      <xsl:message>When processing successful and failing tests</xsl:message>
      <x:scenario>
         <x:label>When processing successful and failing tests</x:label>
         <x:context>
            <x:test successful="true">
               <x:label>
                  <xsl:text>Successful test</xsl:text>
               </x:label>
               <x:result>
                  <p>
                     <xsl:text>Foo</xsl:text>
                  </p>
               </x:result>
               <x:expect>
                  <p>
                     <xsl:text>Foo</xsl:text>
                  </p>
               </x:expect>
            </x:test>
            <x:test successful="false">
               <x:label>
                  <xsl:text>Failing test</xsl:text>
               </x:label>
               <x:result>
                  <p>
                     <xsl:text>Foo</xsl:text>
                  </p>
               </x:result>
               <x:expect>
                  <p>
                     <xsl:text>Bar</xsl:text>
                  </p>
               </x:expect>
            </x:test>
         </x:context>
         <xsl:variable name="x:result" as="item()*">
            <xsl:variable name="impl:context-doc" as="document-node()">
               <xsl:document>
                  <x:test successful="true">
                     <x:label>
                        <xsl:text>Successful test</xsl:text>
                     </x:label>
                     <x:result>
                        <p>
                           <xsl:text>Foo</xsl:text>
                        </p>
                     </x:result>
                     <x:expect>
                        <p>
                           <xsl:text>Foo</xsl:text>
                        </p>
                     </x:expect>
                  </x:test>
                  <x:test successful="false">
                     <x:label>
                        <xsl:text>Failing test</xsl:text>
                     </x:label>
                     <x:result>
                        <p>
                           <xsl:text>Foo</xsl:text>
                        </p>
                     </x:result>
                     <x:expect>
                        <p>
                           <xsl:text>Bar</xsl:text>
                        </p>
                     </x:expect>
                  </x:test>
               </xsl:document>
            </xsl:variable>
            <xsl:variable name="impl:context" select="$impl:context-doc/node()"/>
            <xsl:apply-templates select="$impl:context"/>
         </xsl:variable>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="x:d5e50">
            <xsl:with-param name="x:result" select="$x:result"/>
         </xsl:call-template>
      </x:scenario>
   </xsl:template>
   <xsl:template name="x:d5e50">
      <xsl:param name="x:result" required="yes"/>
      <xsl:message>convert it to test cases with status passed and failing</xsl:message>
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
      <xsl:variable name="impl:expected-doc" as="document-node()">
         <xsl:document>
            <testcase name="Successful test" status="passed"/>
            <testcase name="Failing test" status="failed">
               <failure message="expect assertion failed">
                  <xsl:text>&lt;x:expect xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:test="http://www.jenitennison.com/xslt/unit-test" xmlns:x="http://www.jenitennison.com/xslt/xspec"&gt;&lt;p&gt;Bar&lt;/p&gt;&lt;/x:expect&gt;</xsl:text>
               </failure>
            </testcase>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="impl:expected" select="$impl:expected-doc/node()"/>
      <xsl:variable name="impl:successful"
                    as="xs:boolean"
                    select="                    test:deep-equal(                      $impl:expected,                      if ( $impl:with-context ) then $impl:context else $x:result,                      3)"/>
      <xsl:if test="not($impl:successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <x:test successful="{ $impl:successful }">
         <x:label>convert it to test cases with status passed and failing</x:label>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$x:result"/>
            <xsl:with-param name="wrapper-name" select="'x:result'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
         <xsl:call-template name="test:report-value">
            <xsl:with-param name="value" select="$impl:expected"/>
            <xsl:with-param name="wrapper-name" select="'x:expect'"/>
            <xsl:with-param name="wrapper-ns" select="'http://www.jenitennison.com/xslt/xspec'"/>
         </xsl:call-template>
      </x:test>
   </xsl:template>
</xsl:stylesheet>
