<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       exist-xquery-harness.xproc                               -->
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
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            xmlns:pkg="http://expath.org/ns/pkg"
            pkg:import-uri="http://www.jenitennison.com/xslt/xspec/exist/harness/xquery.xproc"
            name="exist-xquery-harness"
            type="t:exist-xquery-harness"
            version="1.0">
	
   <p:documentation>
      <p>This pipeline executes an XSpec test suite on an eXist instance.</p>
      <p><b>Primary input:</b> A XSpec test suite document.</p>
      <p><b>Primary output:</b> A formatted HTML XSpec report.</p>
      <p>The XQuery library module to test must already be on the eXist instance
        (its URI is passed through the option 'query-at').  The instance endpoint
        is passed in the option 'endpoint'.  The runtime utils library (also known
        as generate-query-utils.xql) must also be on the instance (its location
        hint, that is the 'at' clause to use) is passed in the option 'utils-lib'.
        The dir where you unzipped the XSpec archive on your filesystem is passed
        in the option 'xspec-home'.</p>
   </p:documentation>

   <p:serialization port="result" indent="true"/>

   <p:option name="xspec-home" required="true"/>
   <p:option name="query-at"/>
   <p:option name="utils-lib"  select="'xmldb:exist:///db/xspec/generate-query-utils.xql'"/>
   <!-- What about credentials...? -->
   <p:option name="endpoint"   select="'http://localhost:8080/exist/rest/db/'"/>
   <!-- if set, then save the generated query at this URI -->
   <p:option name="compiled-uri"/>
   <!-- if set, then save the generated query at this URI -->
   <p:option name="report-uri"/>

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
   <p:escape-markup name="escape"/>

   <!-- save it on disk if compiled-uri is provided, for debugging purpose -->
   <!-- TODO: Is it possible to conditionize p:debug instead?  If not, it should
        be a util (standard?) step. -->
   <p:choose>
      <p:when test="p:value-available('compiled-uri')">
         <p:store method="text">
            <p:with-option name="href" select="$compiled-uri"/>
         </p:store>
         <p:identity>
            <p:input port="source">
               <p:pipe step="escape" port="result"/>
            </p:input>
         </p:identity>
      </p:when>
      <p:otherwise>
         <p:identity/>
      </p:otherwise>
   </p:choose>

   <!-- construct the eXist REST query element around the query itself -->
   <p:rename new-name="exist:text" match="/*"/>
   <p:wrap wrapper="exist:query" match="/*"/>
   <!-- construct the HTTP request following eXist REST interface -->
   <p:wrap wrapper="c:body" match="/*"/>
   <p:add-attribute attribute-name="content-type" attribute-value="application/xml" match="/*"/>
   <p:wrap wrapper="c:request" match="/*"/>
   <p:add-attribute attribute-name="method" attribute-value="POST" match="/*"/>
   <p:add-attribute attribute-name="href" match="/*">
      <p:with-option name="attribute-value" select="$endpoint"/>
   </p:add-attribute>

   <!-- run it on eXist -->
   <p:http-request name="run"/>

   <!-- unwrap the http-request step wrapper element -->
   <p:unwrap name="unwrap" match="/c:result"/>

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
