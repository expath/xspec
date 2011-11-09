<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       harness-lib.xpl                                          -->
<!--  Author:     Florent Georges                                          -->
<!--  Date:       2011-11-08                                               -->
<!--  URI:        http://xspec.googlecode.com/                             -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2011 Florent Georges (see end of file.)              -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:t="http://www.jenitennison.com/xslt/xspec"
           xmlns:pkg="http://expath.org/ns/pkg"
           pkg:import-uri="#none"
           version="1.0">

   <!--
       Compile the suite on source into a stylesheet on result.
   -->
   <p:declare-step type="t:compile-xslt" name="compile-xsl">
      <!-- the port declarations -->
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <!-- if xspec-home is not passed, then use packaging public URI -->
      <p:option name="xspec-home" select="''"/>
      <!-- either the public URI, or resolved from xspec-home if packaging not supported -->
      <p:variable name="compiler" select="
          if ( $xspec-home ) then
            resolve-uri('src/compiler/generate-xspec-tests.xsl', $xspec-home)
          else
            'http://www.jenitennison.com/xslt/xspec/generate-xspec-tests.xsl'"/>
      <!-- load the compiler -->
      <p:load name="compiler">
         <p:with-option name="href" select="$compiler"/>
      </p:load>
      <!-- actually compile the suite in a stylesheet -->
      <p:xslt>
         <p:input port="source">
            <p:pipe port="source" step="compile-xsl"/>
         </p:input>
         <p:input port="stylesheet">
            <p:pipe port="result" step="compiler"/>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <!--
       Compile the suite on source into a query on result.
       
       The query is wrapped into an element c:query.  Parameters to the XSpec
       XQuery compiler, AKA generate-query-tests.xsl, can be passed on the
       parameters port (e.g. utils-library-at to set the at location hint to use
       to import the XSpec utils library module in the generated query).
   -->
   <p:declare-step type="t:compile-xquery" name="compile-xq">
      <!-- the port declarations -->
      <p:input  port="source" primary="true"/>
      <p:input  port="parameters" kind="parameter"/>
      <p:output port="result" primary="true"/>
      <!-- if xspec-home is not passed, then use packaging public URI -->
      <p:option name="xspec-home" select="''"/>
      <!-- either the public URI, or resolved from xspec-home if packaging not supported -->
      <p:variable name="compiler" select="
          if ( $xspec-home ) then
            resolve-uri('src/compiler/generate-query-tests.xsl', $xspec-home)
          else
            'http://www.jenitennison.com/xslt/xspec/generate-query-tests.xsl'"/>
      <!-- wrap the generated query in a c:query element -->
      <p:string-replace match="xsl:import/@href" name="compiler">
         <p:with-option name="replace" select="concat('''', $compiler, '''')"/>
         <p:input port="source">
            <p:inline>
               <!-- TODO: I think this is due to a bug in Calabash, if I don't create a node
                    using the prefix 't', then the biding is not visible to Saxon and it throws
                    a compilation error for this stylesheet... -->
               <xsl:stylesheet version="2.0" t:dummy="...">
                  <xsl:import href="..."/>
                  <xsl:template match="/">
                     <c:query>
                        <xsl:call-template name="t:generate-tests"/>
                     </c:query>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:string-replace>
      <!-- actually compile the suite in a query -->
      <p:xslt>
         <p:input port="source">
            <p:pipe step="compile-xq" port="source"/>
         </p:input>
         <p:input port="stylesheet">
            <p:pipe step="compiler" port="result"/>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <!--
       Get the XML report on source, and give the HTML report on result.
       
       If xspec-home is set, it is used to resolve the XSLT that formats the
       report.  If not, its public URI is used, to be resolved through the
       EXPath packaging system.  If the document element is not an XSpec
       t:report, the error t:ERR001 is thrown.
   -->
   <p:declare-step type="t:format-report" name="format">
      <!-- the port declarations -->
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <!-- if xspec-home is not passed, then use packaging public URI -->
      <p:option name="xspec-home" select="''"/>
      <!-- either the public URI, or resolved from xspec-home if packaging not supported -->
      <p:variable name="formatter" select="
          if ( $xspec-home ) then
            resolve-uri('src/reporter/format-xspec-report.xsl', $xspec-home)
          else
            'http://www.jenitennison.com/xslt/xspec/format-xspec-report.xsl'"/>
      <!-- if there is a report, format it, or it is an error -->
      <p:choose>
         <p:when test="exists(/t:report)">
            <p:load name="formatter" pkg:kind="xslt">
               <p:with-option name="href" select="$formatter"/>
            </p:load>
            <p:xslt name="format-report">
               <p:input port="source">
                  <p:pipe step="format" port="source"/>
               </p:input>
               <p:input port="stylesheet">
                  <p:pipe step="formatter" port="result"/>
               </p:input>
               <p:input port="parameters">
                  <p:empty/>
               </p:input>
            </p:xslt>
         </p:when>
         <p:otherwise>
            <p:error code="t:ERR001"/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

</p:library>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.             -->
<!--                                                                       -->
<!-- Copyright (c) 2011 Florent Georges                                    -->
<!--                                                                       -->
<!-- The contents of this file are subject to the MIT License (see the URI -->
<!-- http://www.opensource.org/licenses/mit-license.php for details).      -->
<!--                                                                       -->
<!-- Permission is hereby granted, free of charge, to any person obtaining -->
<!-- a copy of this software and associated documentation files (the       -->
<!-- "Software"), to deal in the Software without restriction, including   -->
<!-- without limitation the rights to use, copy, modify, merge, publish,   -->
<!-- distribute, sublicense, and/or sell copies of the Software, and to    -->
<!-- permit persons to whom the Software is furnished to do so, subject to -->
<!-- the following conditions:                                             -->
<!--                                                                       -->
<!-- The above copyright notice and this permission notice shall be        -->
<!-- included in all copies or substantial portions of the Software.       -->
<!--                                                                       -->
<!-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       -->
<!-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    -->
<!-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.-->
<!-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  -->
<!-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  -->
<!-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     -->
<!-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
