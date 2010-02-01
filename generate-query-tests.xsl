<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                exclude-result-prefixes="xs test x"
                version="2.0">

   <xsl:import href="generate-common-tests.xsl"/>
   <xsl:import href="generate-query-helper.xsl"/>

   <xsl:output omit-xml-declaration="yes"/>

   <xsl:variable name="xspec-prefix" as="xs:string">
      <xsl:variable name="e" select="/*"/>
      <xsl:variable name="u" select="xs:anyURI('http://www.jenitennison.com/xslt/xspec')"/>
      <xsl:sequence select="
          in-scope-prefixes($e)[namespace-uri-for-prefix(., $e) eq $u][1]"/>
   </xsl:variable>

   <!-- TODO: The at hint should not be always resolved (e.g. for MarkLogic). -->
   <xsl:param name="query-at" as="xs:anyURI?" select="
       /x:description/@query-at/resolve-uri(., base-uri(..))"/>

   <xsl:template match="/">
      <xsl:call-template name="x:generate-tests"/>
   </xsl:template>

   <xsl:template match="x:description" mode="x:decl-ns">
      <xsl:param name="except" as="xs:string"/>
      <xsl:variable name="e" as="element()" select="."/>
      <xsl:for-each select="in-scope-prefixes($e)[not(. = ('xml', $except))]">
         <xsl:text>declare namespace </xsl:text>
         <xsl:value-of select="."/>
         <xsl:text> = "</xsl:text>
         <xsl:value-of select="namespace-uri-for-prefix(., $e)"/>
         <xsl:text>";&#10;</xsl:text>
      </xsl:for-each>
   </xsl:template>

   <!-- *** x:generate-tests *** -->
   <!-- Does the generation of the test stylesheet -->
  
   <xsl:template match="x:description" mode="x:generate-tests">
      <xsl:variable name="this" select="."/>
      <!-- A prefix has to be defined for the target namespace on x:description. -->
      <!-- TODO: If not, we should generate one. -->
      <xsl:variable name="prefix" select="
          in-scope-prefixes($this)[
            namespace-uri-for-prefix(., $this) eq xs:anyURI($this/@query)
          ][1]"/>
      <xsl:text>import module namespace </xsl:text>
      <xsl:value-of select="$prefix"/>
      <xsl:text> = "</xsl:text>
      <xsl:value-of select="@query"/>
      <xsl:if test="exists($query-at)">
         <xsl:text>"&#10;  at "</xsl:text>
         <xsl:value-of select="$query-at"/>
      </xsl:if>
      <xsl:text>";&#10;</xsl:text>
      <xsl:text>import module namespace test = </xsl:text>
      <xsl:text>"http://www.jenitennison.com/xslt/unit-test"&#10;</xsl:text>
      <xsl:text>  at "</xsl:text>
      <!-- TODO: Once again, this is dependent on the target
           processor... (e.g. on MarkLogic or eXist, this XSpec module
           - or the corresponding, processor-dependent one - should
           have been installed on the server).  -->
      <xsl:value-of select="resolve-uri('generate-query-utils.xql', static-base-uri())"/>
      <xsl:text>";&#10;</xsl:text>
      <xsl:apply-templates select="." mode="x:decl-ns">
         <xsl:with-param name="except" select="$prefix"/>
      </xsl:apply-templates>
      <!-- Compile the test suite params (aka global params). -->
      <xsl:call-template name="x:compile-params"/>
      <!-- Compile the top-level scenarios. -->
      <xsl:call-template name="x:compile-scenarios"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:element name="{ $xspec-prefix }:report"
                   namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:attribute name="date"  select="current-dateTime()"/>
         <xsl:attribute name="query" select="$this/@query"/>
         <xsl:if test="exists($query-at)">
            <xsl:attribute name="query-at" select="$query-at"/>
         </xsl:if>
         <xsl:text> {&#10;</xsl:text>
         <!-- Generate calls to the compiled top-level scenarios. -->
         <xsl:call-template name="x:call-scenarios"/>
         <xsl:text>&#10;}&#10;</xsl:text>
      </xsl:element>
   </xsl:template>

   <!-- *** x:output-call *** -->
   <!-- Generates a call to the function compiled from a scenario or an expect element. --> 

   <xsl:template name="x:output-call">
      <xsl:param name="name"   as="xs:string"/>
      <xsl:param name="last"   as="xs:boolean"/>
      <xsl:param name="params" as="element(param)*"/>
      <xsl:text>      let $x:tmp := local:</xsl:text>
      <xsl:value-of select="$name"/>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="$params">
         <xsl:value-of select="@select"/>
         <xsl:if test="position() ne last()">
            <xsl:text>, </xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:text>) return (&#10;</xsl:text>
      <xsl:text>        $x:tmp</xsl:text>
      <xsl:if test="not($last)">
         <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
      <!-- Continue compiling calls. -->
      <xsl:call-template name="x:continue-call-scenarios"/>
      <xsl:text>      )&#10;</xsl:text>
   </xsl:template>

   <!-- *** x:compile *** -->
   <!-- Generates the functions that perform the tests -->

   <xsl:template match="x:pending" mode="x:compile">
      <xsl:apply-templates mode="x:compile">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       TODO: Take $pending into account...
   -->
   <xsl:template name="x:output-scenario">
      <xsl:param name="pending" select="()" tunnel="yes" as="node()?"/>
      <xsl:param name="context" select="()" tunnel="yes" as="element(x:context)?"/>
      <xsl:param name="call"    select="()" tunnel="yes" as="element(x:call)?"/>
      <!-- x:context and x:call/@template not supported for XQuery -->
      <xsl:if test="exists($context)">
         <xsl:variable name="msg" select="
             concat('x:context not supported for XQuery (scenario ', x:label(.), ')')"/>
         <xsl:sequence select="error(xs:QName('x:XSPEC003'), $msg)"/>
      </xsl:if>
      <xsl:if test="exists($call/@template)">
         <xsl:variable name="msg" select="
             concat('x:call/@template not supported for XQuery (scenario ', x:label(.), ')')"/>
         <xsl:sequence select="error(xs:QName('x:XSPEC004'), $msg)"/>
      </xsl:if>
      <!-- x:call required if there are x:expect -->
      <xsl:if test="x:expect and not($call)">
         <xsl:variable name="msg" select="
             concat('there are x:expect but no x:call in scenario ''', x:label(.), '''')"/>
         <xsl:sequence select="error(xs:QName('x:XSPEC005'), $msg)"/>
      </xsl:if>
      <!--
        declare function local:...()
        {
      -->
      <xsl:text>&#10;declare function local:</xsl:text>
      <xsl:value-of select="generate-id()"/>
      <xsl:text>()&#10;{&#10;</xsl:text>
      <x:scenario>
         <x:label>
            <xsl:value-of select="x:label(.)"/>
         </x:label>
         <!-- Generate a seq ctor to generate x:context or x:call in the report. -->
         <xsl:apply-templates select="x:context|x:call" mode="x:report"/>
         <xsl:text>      &#10;{&#10;</xsl:text>
         <xsl:apply-templates select="$call/x:param" mode="x:compile"/>
         <!--
           let $t:result := ...(...)
             return (
               test:report-value($t:result, 'x:result'),
               ...
             )
         -->
         <xsl:text>  let $t:result := </xsl:text>
         <xsl:value-of select="$call/@function"/>
         <xsl:text>(</xsl:text>
         <xsl:for-each select="$call/x:param">
            <xsl:sort select="xs:integer(@position)"/>
            <xsl:text>$</xsl:text>
            <xsl:value-of select="( @name, generate-id() )[1]"/>
            <xsl:if test="position() != last()">, </xsl:if>
         </xsl:for-each>
         <xsl:text>)&#10;</xsl:text>
         <xsl:text>    return (&#10;</xsl:text>
         <xsl:text>      test:report-value($t:result, 'x:result'),&#10;</xsl:text>
         <xsl:call-template name="x:call-scenarios"/>
         <xsl:text>    )&#10;</xsl:text>
         <xsl:text>      }&#10;</xsl:text>
      </x:scenario>
      <xsl:text>};&#10;</xsl:text>
      <xsl:call-template name="x:compile-scenarios"/>
   </xsl:template>

   <!--
       Generate an XQuery function from the expect element.
       
       This function, when called, checks the expectation against the
       actual result of the test and return the corresponding t:test
       element for the XML report.
   -->
   <xsl:template name="x:output-expect">
      <xsl:param name="pending" select="()"    tunnel="yes" as="node()?"/>
      <xsl:param name="call"    required="yes" tunnel="yes" as="element(x:call)?"/>
      <xsl:param name="params"  required="yes"              as="element(param)*"/>
      <!--
        declare function local:...($t:result as item()*)
        {
      -->
      <xsl:text>&#10;declare function local:</xsl:text>
      <xsl:value-of select="generate-id()"/>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="$params">
         <xsl:text>$</xsl:text>
         <xsl:value-of select="@name"/>
         <xsl:if test="position() ne last()">
            <xsl:text>, </xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:text>)&#10;{&#10;</xsl:text>
      <xsl:choose>
         <xsl:when test="exists($pending)">
            <xsl:text>  ()</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <!--
              let $local:expected :=
                  ( ... )
            -->
            <xsl:text>  let $local:expected    := (: expected result (none here) :)&#10;</xsl:text>
            <!-- FIXME: Not correct, the x:expect model is more complex than
                 a simple variable... (see how the original stylesheet, for
                 XSLT, handles that...) Factorize with the XSLT version...
                 The value of $local:expected depends on x:expect's depends
                 on content, @href and @select. -->
            <xsl:text>      ( </xsl:text>
            <xsl:value-of select="@select"/>
            <xsl:copy-of select="node()"/>
            <xsl:text> )&#10;</xsl:text>
            <!--
              let $local:test-result :=
                  if ( $t:result instance of node() ) then
                    $t:result/( ... )
                  else
                    ( ... )
            -->
            <xsl:text>  let $local:test-result := (: evaluate the predicate :)&#10;</xsl:text>
            <xsl:text>      if ( $</xsl:text>
            <xsl:value-of select="$xspec-prefix"/>
            <xsl:text>:result instance of node() ) then&#10;</xsl:text>
            <xsl:text>        $</xsl:text>
            <xsl:value-of select="$xspec-prefix"/>
            <xsl:text>:result/( </xsl:text>
            <xsl:value-of select="@test"/>
            <xsl:text> )&#10;</xsl:text>
            <xsl:text>      else&#10;</xsl:text>
            <xsl:text>        ( </xsl:text>
            <xsl:value-of select="@test"/>
            <xsl:text> )&#10;</xsl:text>
            <!--
              let $local:successful :=
                  if ( $local:test-result instance of xs:boolean ) then
                    $local:test-result
                  else
                    test:deep-equal($local:expected, $local:test-result)
            -->
            <xsl:text>  let $local:successful  := (: did the test pass?:)&#10;</xsl:text>
            <xsl:text>      if ( $local:test-result instance of xs:boolean ) then&#10;</xsl:text>
            <xsl:text>        $local:test-result&#10;</xsl:text>
            <xsl:text>      else&#10;</xsl:text>
            <xsl:text>        test:deep-equal($local:expected, $local:test-result)&#10;</xsl:text>
            <xsl:text>    return&#10;      </xsl:text>
            <!--
              return the x:test element for the report
            -->
            <x:test successful="{{ $local:successful }}">
               <xsl:sequence select="x:label(.)"/>
               <xsl:text>&#10;      { if ( $local:test-result instance of xs:boolean ) then () else test:report-value($local:test-result, 'x:result') }</xsl:text>
               <xsl:text>&#10;      { test:report-value($local:expected, 'x:expect') }</xsl:text>
            </x:test>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;};&#10;</xsl:text>
   </xsl:template>

   <!-- *** x:generate-declarations *** -->
   <!-- Code to generate parameter declarations -->
   <xsl:template match="x:param" mode="x:generate-declarations">
      <xsl:text>declare variable $</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text> := </xsl:text>
      <xsl:value-of select="@select"/>
      <xsl:copy-of select="node()"/>
      <xsl:text>;&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="x:space" mode="test:create-xslt-generator">
      <text>
         <xsl:value-of select="."/>
      </text>
   </xsl:template>  

   <xsl:template match="x:param" mode="x:report">
      <xsl:element name="x:{local-name()}">
         <xsl:apply-templates select="@*" mode="x:report"/>
         <xsl:apply-templates mode="test:create-xslt-generator"/>
      </xsl:element>
   </xsl:template>

   <xsl:template match="x:call" mode="x:report">
      <x:call>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="x:report"/>
      </x:call>
   </xsl:template>

   <xsl:template match="@select" mode="x:report">
      <xsl:attribute name="select" select="
          replace(replace(., '\{', '{{'), '\}', '}}')"/>
   </xsl:template>

   <xsl:template match="@*" mode="x:report">
      <xsl:sequence select="."/>
   </xsl:template>

   <xsl:function name="x:label" as="node()?">
      <xsl:param name="labelled" as="element()"/>
      <xsl:choose>
         <xsl:when test="exists($labelled/x:label)">
            <xsl:sequence select="$labelled/x:label"/>
         </xsl:when>
         <xsl:otherwise>
            <x:label><xsl:value-of select="$labelled/@label"/></x:label>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

</xsl:stylesheet>
