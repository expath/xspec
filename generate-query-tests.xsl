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
      <xsl:apply-templates select="." mode="x:generate-tests" />
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
      <xsl:variable name="pending" as="node()?" select=".//@focus"/>
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
      <xsl:apply-templates select="x:param" mode="x:decl"/>
      <xsl:apply-templates mode="x:checks">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:text>&#10;</xsl:text>
      <xsl:element name="{ $xspec-prefix }:report"
                   namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:attribute name="date"  select="current-dateTime()"/>
         <xsl:attribute name="query" select="$this/@query"/>
         <xsl:if test="exists($query-at)">
            <xsl:attribute name="query-at" select="$query-at"/>
         </xsl:if>
         <xsl:text> {&#10;</xsl:text>
         <xsl:apply-templates mode="x:calls">
            <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
         </xsl:apply-templates>
         <xsl:text>&#10;}&#10;</xsl:text>
      </xsl:element>
   </xsl:template>

   <!-- *** x:calls *** -->
   <!-- Generates the calls to the templates that perform the tests themselves --> 

   <xsl:template match="x:pending" mode="x:calls">
      <xsl:apply-templates mode="x:calls">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="x:scenario" mode="x:calls">
      <xsl:text>  local:</xsl:text>
      <xsl:value-of select="generate-id()"/>
      <xsl:text>()</xsl:text>
      <xsl:if test="position() ne last()">
         <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <!--
       TODO: Take $pending into accunt (see how the original
       stylesheet, for XSLT, handles that...)
   -->
   <xsl:template match="x:expect" mode="x:calls">
      <xsl:param name="pending" as="node()?" select="()" tunnel="yes"/>
      <xsl:text>      local:</xsl:text>
      <xsl:value-of select="generate-id()"/>
      <xsl:text>($result)</xsl:text>
      <xsl:if test="position() ne last()">
         <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>  

   <xsl:template match="*" mode="x:calls"/>

   <!-- *** x:checks *** -->
   <!-- Generates the templates that perform the tests -->

   <xsl:template match="x:pending" mode="x:checks">
      <xsl:apply-templates mode="x:checks">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="x:scenario" mode="x:checks">
      <xsl:param name="pending" as="node()?" select="()" tunnel="yes"/>
      <xsl:param name="call" as="element(x:call)?" select="()" tunnel="yes"/>
      <xsl:variable name="new-pending" as="node()?" select="
          if ( @focus ) then () else if ( @pending ) then @pending else $pending"/>
      <xsl:variable name="new-call" as="element(x:call)?">
         <xsl:choose>
            <xsl:when test="x:call">
               <xsl:variable name="local-params" as="element(x:param)*"
                             select="x:call/x:param"/>
               <x:call>
                  <xsl:sequence select="$call/@*"/>
                  <xsl:sequence select="x:call/@*"/>
                  <xsl:sequence select="$call/x:param[not(@name = $local-params/@name)], $local-params"/>
               </x:call>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$call"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="$new-call/@template">
         <xsl:message terminate="yes">
            <xsl:text>ERROR in scenario "</xsl:text>
            <xsl:value-of select="x:label(.)"/>
            <xsl:text>": can't call a template from a query</xsl:text>
         </xsl:message>
      </xsl:if>
      <xsl:if test="x:expect and not($new-call)">
         <xsl:message terminate="yes">
            <xsl:text>ERROR in scenario "</xsl:text>
            <xsl:value-of select="x:label(.)"/>
            <xsl:text>": there are tests in this scenario but no call has been given</xsl:text>
         </xsl:message>
      </xsl:if>
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
         <xsl:apply-templates select="$new-call/x:param" mode="x:generate-declarations"/>
         <xsl:text>  let $result := </xsl:text>
         <xsl:value-of select="$new-call/@function"/>
         <xsl:text>(</xsl:text>
         <xsl:for-each select="$new-call/x:param">
            <xsl:sort select="xs:integer(@position)"/>
            <xsl:text>$</xsl:text>
            <xsl:value-of select="( @name, generate-id() )[1]"/>
            <xsl:if test="position() != last()">, </xsl:if>
         </xsl:for-each>
         <xsl:text>)&#10;</xsl:text>
         <xsl:text>    return (&#10;</xsl:text>
         <xsl:text>      test:report-value($result, 'x:result'),&#10;</xsl:text>
         <xsl:apply-templates mode="x:calls">
            <xsl:with-param name="pending" select="$new-pending" tunnel="yes"/>
         </xsl:apply-templates>
         <xsl:text>    )&#10;</xsl:text>
         <xsl:text>      }&#10;</xsl:text>
      </x:scenario>
      <xsl:text>};&#10;</xsl:text>
      <xsl:apply-templates mode="x:checks">
         <xsl:with-param name="pending" select="$new-pending" tunnel="yes"/>
         <xsl:with-param name="call"    select="$new-call"    tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="x:expect" mode="x:checks">
      <xsl:param name="pending" as="node()?" select="()" tunnel="yes"/>
      <xsl:param name="call" as="element(x:call)?" required="yes" tunnel="yes"/>  
      <xsl:text>&#10;declare function local:</xsl:text>
      <xsl:value-of select="generate-id()"/>
      <xsl:text>($</xsl:text>
      <xsl:value-of select="$xspec-prefix"/>
      <xsl:text>:result as item()*)&#10;{&#10;</xsl:text>
      <xsl:text>  let $exp := ( </xsl:text>
      <!-- FIXME: Not correct, the x:expect model is more complex than
           a simple variable... (see how the original stylesheet, for
           XSLT, handles that...) Factorize with the XSLT version...
           The value of $exp depends on x:expect's depends on content,
           @href and @select. -->
      <xsl:value-of select="@select"/>
      <xsl:copy-of select="node()"/>
      <xsl:text> )&#10;</xsl:text>
      <xsl:text>  let $r := ( </xsl:text>
      <xsl:value-of select="@test"/>
      <xsl:text> )&#10;</xsl:text>
      <xsl:text>  let $success := if ( $r instance of xs:boolean ) then&#10;</xsl:text>
      <xsl:text>                    $r&#10;</xsl:text>
      <xsl:text>                  else&#10;</xsl:text>
      <xsl:text>                    test:deep-equal($exp, $r)&#10;</xsl:text>
      <xsl:text>    return&#10;</xsl:text>
      <xsl:text>      </xsl:text>
      <x:test successful="{{ $success }}">
         <xsl:sequence select="x:label(.)"/>
         <xsl:text>&#10;      { if ( $r instance of xs:boolean ) then () else test:report-value($r, 'x:result') }</xsl:text>
         <xsl:text>&#10;      { test:report-value($exp, 'x:expect') }</xsl:text>
      </x:test>
      <xsl:text>&#10;};&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="*" mode="x:checks"/>

   <!-- *** x:decl *** -->
   <!-- Code to generate parameter declarations -->
   <xsl:template match="x:param" mode="x:decl">
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

   <!-- *** x:generate-declarations *** -->
   <!-- Helper code for the tests -->

   <xsl:template match="x:param" mode="x:generate-declarations">
      <xsl:text>  let $</xsl:text>
      <xsl:value-of select="( @name, generate-id() )[1]"/>
      <xsl:text> := </xsl:text>
      <xsl:value-of select="@select"/>
      <xsl:copy-of select="node()"/>
      <xsl:text>&#10;</xsl:text>
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
