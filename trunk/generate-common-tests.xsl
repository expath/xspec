<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                exclude-result-prefixes="xs test x"
                version="2.0">

   <xsl:preserve-space elements="x:space"/>

   <!--
       Drive the overall compilation of a suite.  Apply template on
       the x:description element, in the mode
   -->
   <xsl:template name="x:generate-tests">
      <xsl:variable name="this" select="." as="document-node(element(x:description))"/>
      <xsl:variable name="all-specs" as="document-node(element(x:description))">
         <xsl:document>
            <x:description>
               <xsl:apply-templates select="$this/x:description" mode="x:copy-namespaces"/>
               <xsl:copy-of select="$this/x:description/@*"/>
               <xsl:apply-templates select="x:gather-specs($this/x:description)"
                                    mode="x:gather-specs"/>
            </x:description>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="unshared-scenarios" as="document-node()">
         <xsl:document>
            <xsl:apply-templates select="$all-specs/*" mode="x:unshare-scenarios"/>
         </xsl:document>
      </xsl:variable>
      <xsl:apply-templates select="$unshared-scenarios/*" mode="x:generate-tests"/>
   </xsl:template>

   <xsl:template match="x:description" mode="x:copy-namespaces">
      <xsl:variable name="e" as="element()" select="."/>
      <xsl:for-each select="in-scope-prefixes($e)">
         <xsl:namespace name="{ . }" select="namespace-uri-for-prefix(., $e)"/>
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

   <!--
       Drive the compilation of scenarios to generate call
       instructions (the scenarios are compiled to an XSLT named
       template or an XQuery function, which must have the
       corresponding call instruction at some point).
   -->
   <xsl:template name="x:call-scenarios">
      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:sequence select="
             error(
                 xs:QName('x:XSPEC006'),
                 concat('$this must be a description or a scenario, but is: ', name(.))
               )"/>
      </xsl:if>
      <xsl:apply-templates select="$this/(x:scenario|x:expect)" mode="x:generate-calls">
         <xsl:with-param name="pending" select="$this//@focus" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       Default rule for that mode generates an error.
   -->
   <xsl:template match="@*|node()" mode="x:generate-calls">
      <xsl:sequence select="
          error(
              xs:QName('x:XSPEC001'),
              concat('Unhandled node in x:generate-calls mode: ', name(.))
            )"/>
   </xsl:template>

   <!--
       At x:pending elements, we switch the $pending tunnel param
       value for children.
   -->
   <xsl:template match="x:pending" mode="x:generate-calls">
      <xsl:apply-templates mode="x:generate-calls">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       A scenario is called by the name { generate-id() }.
   -->
   <xsl:template match="x:scenario" mode="x:generate-calls">
      <xsl:call-template name="x:output-call">
         <xsl:with-param name="name" select="generate-id()"/>
      </xsl:call-template>
   </xsl:template>

   <!--
       An expectation is called by the name { generate-id() }.
   -->
   <xsl:template match="x:expect" mode="x:generate-calls">
      <xsl:param name="pending" as="node()?" select="()" tunnel="yes"/>
      <xsl:call-template name="x:output-call">
         <xsl:with-param name="name" select="generate-id()"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:if test="empty($pending) and not(ancestor::x:scenario/@pending)">
               <param name="x:result" select="$x:result"/>
            </xsl:if>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
       Drive the compilation of test suite params (aka global params).
   -->
   <xsl:template name="x:compile-params">
      <xsl:variable name="this" select="." as="element(x:description)"/>
      <xsl:apply-templates select="$this/x:param" mode="x:generate-declarations"/>
   </xsl:template>

   <!--
       Drive the compilation of scenarios to either XSLT named
       templates or XQuery functions.
   -->
   <xsl:template name="x:compile-scenarios">
      <xsl:param name="pending" as="node()?" select=".//@focus" tunnel="yes"/>
      <xsl:variable name="this" select="." as="element()"/>
      <xsl:if test="empty($this[self::x:description|self::x:scenario])">
         <xsl:sequence select="
             error(
                 xs:QName('x:XSPEC007'),
                 concat('$this must be a description or a scenario, but is: ', name(.))
               )"/>
      </xsl:if>
      <xsl:apply-templates select="$this/*" mode="x:compile">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       At x:pending elements, we switch the $pending tunnel param
       value for children.
   -->
   <xsl:template match="x:pending" mode="x:compile">
      <xsl:apply-templates mode="x:compile">
         <xsl:with-param name="pending" select="x:label(.)" tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>

   <!--
       Compile a scenario.
   -->
   <xsl:template match="x:scenario" mode="x:compile">
      <xsl:param name="pending" select="()" tunnel="yes" as="node()?"/>
      <xsl:param name="context" select="()" tunnel="yes" as="element(x:context)?"/>
      <xsl:param name="call"    select="()" tunnel="yes" as="element(x:call)?"/>
      <!-- the new $pending -->
      <xsl:variable name="new-pending" as="node()?" select="
          if ( @focus ) then
            ()
          else if ( @pending ) then
            @pending
          else
            $pending"/>
      <!-- the new context -->
      <xsl:variable name="new-context" as="element(x:context)?">
         <xsl:choose>
            <xsl:when test="x:context">
               <xsl:variable name="local-params" as="element(x:param)*" select="x:context/x:param"/>
               <x:context>
                  <xsl:sequence select="$context/@*"/>
                  <xsl:sequence select="x:context/@*"/>
                  <xsl:sequence select="
                      $context/x:param[not(@name = $local-params/@name)],
                      $local-params"/>
                  <xsl:sequence select="
                      if ( x:context/(node() except x:param) ) then
                        x:context/(node() except x:param)
                      else
                        $context/(node() except x:param)"/>
               </x:context>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$context"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!-- the new context -->
      <xsl:variable name="new-call" as="element(x:call)?">
         <xsl:choose>
            <xsl:when test="x:call">
               <xsl:variable name="local-params" as="element(x:param)*" select="x:call/x:param"/>
               <x:call>
                  <xsl:sequence select="$call/@*"/>
                  <xsl:sequence select="x:call/@*"/>
                  <xsl:sequence select="
                      $call/x:param[not(@name = $local-params/@name)],
                      $local-params"/>
               </x:call>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="$call"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!-- call the serializing template (for XSLT or XQuery) -->
      <xsl:call-template name="x:output-scenario">
         <xsl:with-param name="pending" select="$new-pending" tunnel="yes"/>
         <xsl:with-param name="context" select="$new-context" tunnel="yes"/>
         <xsl:with-param name="call"    select="$new-call"    tunnel="yes"/>
      </xsl:call-template>
   </xsl:template>

   <!--
       Compile an expectation.
   -->
   <xsl:template match="x:expect" mode="x:compile">
      <xsl:param name="pending" select="()"    tunnel="yes" as="node()?"/>
      <xsl:param name="context" required="yes" tunnel="yes" as="element(x:context)?"/>
      <xsl:param name="call"    required="yes" tunnel="yes" as="element(x:call)?"/>
      <!-- call the serializing template (for XSLT or XQuery) -->
      <xsl:call-template name="x:output-expect">
         <xsl:with-param name="pending" select="$pending" tunnel="yes"/>
         <xsl:with-param name="context" select="$context" tunnel="yes"/>
         <xsl:with-param name="call"    select="$call"    tunnel="yes"/>
         <xsl:with-param name="params" as="element(param)*">
            <xsl:if test="empty($pending) and not(ancestor::x:scenario/@pending)">
               <param name="x:result" required="yes"/>
            </xsl:if>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!--
       x:description/x:param and x:call elements are ignored in this mode.
   -->
   <xsl:template match="x:description/x:param|x:call" mode="x:compile"/>

   <!--
       x:param elements generate actual call param's variable.
   -->
   <xsl:template match="x:param" mode="x:compile">
      <xsl:apply-templates select="." mode="test:generate-variable-declarations">
         <xsl:with-param name="var"  select="( @name, generate-id() )[1]" />
         <xsl:with-param name="type" select="'variable'" />
      </xsl:apply-templates>
   </xsl:template>

   <!--
       Default rule for that mode generates an error.
   -->
   <xsl:template match="@*|node()" mode="x:compile">
      <xsl:sequence select="
          error(
              xs:QName('x:XSPEC002'),
              concat('Unhandled node in x:compile mode: ', name(.))
            )"/>
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

</xsl:stylesheet>
