<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                exclude-result-prefixes="xs test x"
                version="2.0">

   <xsl:preserve-space elements="x:space"/>

   <xsl:template match="/" mode="x:generate-tests">
      <xsl:variable name="all-specs" as="document-node()">
         <xsl:document>
            <x:description>
               <xsl:apply-templates select="x:description" mode="x:copy-namespaces"/>
               <xsl:copy-of select="x:description/@*"/>
               <xsl:apply-templates select="x:gather-specs(x:description)" mode="x:gather-specs"/>
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
