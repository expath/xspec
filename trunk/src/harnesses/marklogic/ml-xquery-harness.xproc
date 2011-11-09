<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       ml-xquery-harness.xproc                                  -->
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
            xmlns:ml="http://xmlcalabash.com/ns/extensions/marklogic"
            xmlns:pkg="http://expath.org/ns/pkg"
            pkg:import-uri="http://www.jenitennison.com/xslt/xspec/marklogic/harness/xquery.xproc"
            name="ml-xquery-harness"
            type="t:ml-xquery-harness"
            version="1.0">
	
   <p:documentation>
      <p>This pipeline executes an XSpec test suite on a MarkLogic instance.</p>
      <p><b>Primary input:</b> A XSpec test suite document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
      <p>The XQuery library module to test must already be on the MarkLogic
        instance.  The instance endpoint is passed in the option 'endpoint'.  The
        runtime utils library (also known as generate-query-utils.xql) must also
        be on the instance (its location hint, that is the 'at' clause to use) is
        passed in the option 'utils-lib'.  The dir where you unzipped the XSpec
        archive on your filesystem is passed in the option 'xspec-home'.</p>
   </p:documentation>

   <p:serialization port="result" indent="true"/>

   <p:option name="xspec-home" required="true"/>
   <p:option name="query-at"/>
   <p:option name="utils-lib"  select="'xspec/generate-query-utils.xql'"/>
   <p:option name="host"       required="true"/>
   <!-- this must be the port of an XDBC server -->
   <p:option name="port"       required="true"/>
   <p:option name="user"       required="true"/>
   <p:option name="password"   required="true"/>

   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
   <p:import href="../harness-lib.xpl"/>

   <!-- compile the suite into a query -->
   <p:choose>
      <p:when test="p:value-available('query-at')">
         <t:compile-xquery>
            <p:with-option name="xspec-home"       select="$xspec-home"/>
            <p:with-param  name="query-at"         select="$query-at"/>
            <p:with-param  name="utils-library-at" select="$utils-lib"/>
         </t:compile-xquery>
      </p:when>
      <p:otherwise>
         <t:compile-xquery>
            <p:with-option name="xspec-home"       select="$xspec-home"/>
            <p:with-param  name="utils-library-at" select="$utils-lib"/>
         </t:compile-xquery>
      </p:otherwise>
   </p:choose>

   <!-- escape the query as text -->
   <p:escape-markup/>

   <!-- run it on marklogic -->
   <ml:adhoc-query name="run">
      <p:with-option name="host"     select="$host"/>
      <p:with-option name="port"     select="$port"/>
      <p:with-option name="user"     select="$user"/>
      <p:with-option name="password" select="$password"/>
      <p:input port="parameters">
         <p:empty/>
      </p:input>
   </ml:adhoc-query>

   <!-- format the report -->
   <t:format-report>
      <p:with-option name="xspec-home" select="$xspec-home"/>
   </t:format-report>

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
