<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                exclude-result-prefixes="xs test x"
                version="2.0">

   <xsl:import href="generate-query-helper.xsl"/>

   <xsl:preserve-space elements="x:space"/>

   <xsl:output omit-xml-declaration="yes"/>

   <xsl:variable name="xspec-prefix" as="xs:string">
      <xsl:variable name="e" select="/*"/>
      <xsl:variable name="u" select="xs:anyURI('http://www.jenitennison.com/xslt/xspec')"/>
      <xsl:sequence select="
          in-scope-prefixes($e)[namespace-uri-for-prefix(., $e) eq $u][1]"/>
   </xsl:variable>

   <xsl:variable name="query-uri" as="xs:anyURI" select="
       resolve-uri(/x:description/@query, base-uri(/x:description))"/>

   <xsl:variable name="query" as="document-node()" select="doc($query-uri)"/>

   <xsl:template match="x:description">
      <xsl:variable name="all-specs" as="document-node()">
         <xsl:document>
            <xsl:copy>
               <xsl:apply-templates select="." mode="x:copy-namespaces"/>
               <xsl:copy-of select="@*"/>
               <xsl:attribute name="query" select="$query-uri"/>
               <xsl:apply-templates select="x:gather-specs(.)" mode="x:gather-specs"/>
            </xsl:copy>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="unshared-scenarios" as="document-node()">
         <xsl:document>
            <xsl:apply-templates select="$all-specs/*" mode="x:unshare-scenarios"/>
         </xsl:document>
      </xsl:variable>
      <xsl:apply-templates select="$unshared-scenarios/*" mode="x:gen"/>
   </xsl:template>

   <xsl:template match="x:description" mode="x:copy-namespaces">
      <xsl:variable name="e" as="element()" select="."/>
      <xsl:for-each select="in-scope-prefixes($e)">
         <xsl:namespace name="{ . }" select="namespace-uri-for-prefix(., $e)"/>
      </xsl:for-each>
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

   <xsl:function name="x:gather-specs" as="element(x:description)+">
      <xsl:param name="visit" as="element(x:description)+"/>
      <xsl:variable name="imports" as="element(x:import)*"
                    select="$visit/x:import"/>
      <xsl:variable name="imported" as="element(x:description)*"
                    select="document($imports/@href)/x:description"/>
      <xsl:choose>
         <xsl:when test="empty($imported except $visit)">
            <xsl:sequence select="$visit"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="x:gather-specs($visit | $imported)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:template match="x:description" mode="x:gather-specs">
      <xsl:apply-templates mode="x:gather-specs">
         <xsl:with-param name="xslt-version"   tunnel="yes" select="
             ( @xslt-version, '2.0' )[1]"/>
         <xsl:with-param name="preserve-space" tunnel="yes" select="
             for $qname in tokenize(@preserve-space, '\s+') return
               resolve-QName($qname, .)"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="x:scenario" mode="x:gather-specs">
      <xsl:param name="xslt-version" as="xs:string" tunnel="yes" required="yes"/>
      <x:scenario xslt-version="{$xslt-version}">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates mode="x:gather-specs"/>
      </x:scenario>
   </xsl:template>

   <xsl:template match="x:*/@href" mode="x:gather-specs">
      <xsl:attribute name="href" select="resolve-uri(., base-uri(.))"/>
   </xsl:template>

   <xsl:template match="text()[not(normalize-space())]" mode="x:gather-specs">
      <xsl:param name="preserve-space" as="xs:QName*" tunnel="yes" select="()"/>
      <xsl:if test="parent::x:space
                      or ancestor::*[@xml:space][1]/@xml:space = 'preserve'
                      or node-name(parent::*) = $preserve-space">
         <x:space>
            <xsl:value-of select="."/>
         </x:space>
      </xsl:if>
   </xsl:template>

   <xsl:template match="node()|@*" mode="x:gather-specs">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*" mode="x:gather-specs"/>
      </xsl:copy>
   </xsl:template>

   <!-- *** x:unshare-scenarios *** -->
   <!-- This mode resolves all the <like> elements to bring in the scenarios that
        they specify -->

   <xsl:template match="x:description" mode="x:unshare-scenarios">
      <xsl:copy>
         <xsl:apply-templates select="." mode="x:copy-namespaces"/>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="* except x:scenario[@shared = 'yes']"
                              mode="x:unshare-scenarios"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="x:scenario" mode="x:unshare-scenarios">
      <x:scenario>
         <xsl:copy-of select="@* except @shared"/>
         <xsl:apply-templates mode="x:unshare-scenarios"/>
      </x:scenario>
   </xsl:template>

   <xsl:key name="scenarios" match="x:scenario" use="x:label(.)"/>

   <xsl:template match="x:like" mode="x:unshare-scenarios">
      <xsl:apply-templates select="key('scenarios', x:label(.))/*" mode="x:unshare-scenarios"/>
   </xsl:template>

   <xsl:template match="x:pending" mode="x:unshare-scenarios">
      <x:pending>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="* except x:scenario[@shared = 'yes']"
                              mode="x:unshare-scenarios"/>
      </x:pending>
   </xsl:template>

   <xsl:template match="*" mode="x:unshare-scenarios">
      <xsl:copy-of select="."/>
   </xsl:template>

   <!-- *** x:gen *** -->
   <!-- Does the generation of the test stylesheet -->
  
   <xsl:template match="x:description" mode="x:gen">
      <xsl:variable name="pending" as="node()?" select=".//@focus"/>
      <xsl:variable name="this" select="."/>
      <xsl:variable name="prefix" select="
          in-scope-prefixes($this)[
            namespace-uri-for-prefix(., $this) eq xs:anyURI($this/@query)
          ][1]"/>
      <xsl:text>import module namespace </xsl:text>
      <xsl:value-of select="$prefix"/>
      <xsl:text> = "</xsl:text>
      <xsl:value-of select="@query"/>
      <xsl:text>";&#10;</xsl:text>
      <xsl:text>import module namespace test = </xsl:text>
      <xsl:text>"http://www.jenitennison.com/xslt/unit-test"&#10;</xsl:text>
      <xsl:text>  at "</xsl:text>
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
         <xsl:attribute name="query" select="$this/@query"/>
         <xsl:attribute name="date"  select="current-dateTime()"/>
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
         <!--
             FIXME: TODO: Adapt, generate from the test suite... !!!
         -->
         <x:call function="http:send-request">
            <x:param>
               <http-request href="http://localhost:8090/http-client-test/request/method-001"
                             method="options"/>
            </x:param>
         </x:call>
         <xsl:text>      &#10;{&#10;</xsl:text>
         <xsl:apply-templates select="$new-call/x:param" mode="x:gen"/>
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
         <xsl:text>    return (&#10;      </xsl:text>
         <xsl:element name="{ $xspec-prefix }:result"
                      namespace="http://www.jenitennison.com/xslt/xspec">
         </xsl:element>
         <xsl:text>,&#10;</xsl:text>
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
           XSLT, handles that...) -->
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
         <xsl:text>&#10;      { if ( $r instance of xs:boolean ) then () else test:report-value($t:result, 'x:result') }</xsl:text>
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

   <!-- *** x:gen *** -->
   <!-- Helper code for the tests -->

   <xsl:template match="x:param" mode="x:gen">
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
