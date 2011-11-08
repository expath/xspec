<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       basex-server-xquery-harness.xproc                        -->
<!--  Author:     Florent Georges                                          -->
<!--  Date:       2011-08-30                                               -->
<!--  URI:        http://xspec.googlecode.com/                             -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2011 Florent Georges (see end of file.)              -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"
            xmlns:t="http://www.jenitennison.com/xslt/xspec"
            xmlns:rest="http://www.basex.org/rest"
            xmlns:pkg="http://expath.org/ns/pkg"
            pkg:import-uri="http://www.jenitennison.com/xslt/xspec/basex/harness/server/xquery.xproc"
            name="basex-server-xquery-harness"
            type="t:basex-server-xquery-harness"
            version="1.0">

   <p:documentation>
      <p>This pipeline executes an XSpec test suite on a BaseX server instance.</p>
      <p><b>Primary input:</b> A XSpec test suite document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
      <p>The XQuery library module to test must already be on the BaseX instance
        (its URI is passed through the option 'query-at').  The instance endpoint
        is passed in the option 'endpoint'.  The runtime utils library (also known
        as generate-query-utils.xql) must also be on the instance (its location
        hint, that is the 'at' clause to use) is passed in the option 'utils-lib'.
        The dir where you unzipped the XSpec archive on your filesystem is passed
        in the option 'xspec-home'.  User credentials are passed through options
        'username' and 'password'.</p>
   </p:documentation>

   <p:serialization port="result" indent="true"/>

   <p:option name="xspec-home" required="true"/>
   <p:option name="query-at"/>
   <!-- Is it really good to provide default for the default admin credentials? -->
   <p:option name="username"   select="'admin'"/>
   <p:option name="password"   select="'admin'"/>
   <p:option name="utils-lib"  select="'/xspec/generate-query-utils.xql'"/>
   <p:option name="endpoint"   select="'http://localhost:8984/rest/'"/>

   <!-- TODO: Use the absolute URIs through the EXPath Packaging System.  And
        make them options, just in case the user does not use the Packaging
        System... -->
   <p:variable name="compiler" select="
       resolve-uri('src/compiler/generate-query-tests.xsl', $xspec-home)"/>
   <p:variable name="formatter" select="
       resolve-uri('src/reporter/format-xspec-report.xsl', $xspec-home)"/>

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
                  <rest:text>
                     <xsl:call-template name="t:generate-tests"/>
                  </rest:text>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:input>
   </p:string-replace>

   <p:choose>
      <p:when test="p:value-available('query-at')">
         <p:xslt name="compile">
            <p:input port="source">
               <p:pipe step="basex-server-xquery-harness" port="source"/>
            </p:input>
            <p:input port="stylesheet">
               <p:pipe step="compiler" port="result"/>
            </p:input>
            <p:with-param name="query-at"         select="$query-at"/>
            <p:with-param name="utils-library-at" select="$utils-lib"/>
         </p:xslt>
      </p:when>
      <p:otherwise>
         <p:xslt name="compile">
            <p:input port="source">
               <p:pipe step="basex-server-xquery-harness" port="source"/>
            </p:input>
            <p:input port="stylesheet">
               <p:pipe step="compiler" port="result"/>
            </p:input>
            <p:with-param name="utils-library-at" select="$utils-lib"/>
         </p:xslt>
      </p:otherwise>
   </p:choose>

   <p:escape-markup name="escape"/>

   <p:wrap wrapper="rest:query" match="/*"/>
   <p:wrap wrapper="c:body" match="/*"/>
   <p:add-attribute attribute-name="content-type" attribute-value="application/xml" match="/*"/>
   <p:wrap wrapper="c:request" match="/*"/>
   <p:add-attribute attribute-name="method" attribute-value="POST" match="/*"/>
   <p:add-attribute attribute-name="href" match="/*">
      <p:with-option name="attribute-value" select="$endpoint"/>
   </p:add-attribute>
   <p:add-attribute attribute-name="username" attribute-value="admin" match="/*"/>
   <p:add-attribute attribute-name="password" attribute-value="admin" match="/*"/>
   <p:add-attribute attribute-name="auth-method" attribute-value="basic" match="/*"/>

   <!-- TODO: Allow dumping the document for debugging purposes. -->

   <!-- TODO: Check HTTP return code, etc.? (using @detailed = true) -->
   <p:http-request name="run"/>

   <p:choose>
      <p:when test="exists(/t:report)">
         <p:load name="formatter">
            <p:with-option name="href" select="$formatter"/>
         </p:load>
         <p:xslt name="format-report">
            <p:input port="source">
               <p:pipe step="run" port="result"/>
            </p:input>
            <p:input port="stylesheet">
               <p:pipe step="formatter" port="result"/>
            </p:input>
         </p:xslt>
      </p:when>
      <p:otherwise>
         <p:error code="t:ERR001"/>
      </p:otherwise>
   </p:choose>

</p:pipeline>


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
