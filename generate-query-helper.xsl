<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                extension-element-prefixes="test"
                exclude-result-prefixes="xs xhtml"
                version="2.0">
  
   <xsl:key name="functions" 
            match="xsl:function" 
            use="resolve-QName(@name, .)"/>

   <xsl:key name="named-templates" 
            match="xsl:template[@name]"
            use="if ( contains(@name, ':') ) then
                   resolve-QName(@name, .)
                 else
                   QName('', @name)"/>

   <xsl:key name="matching-templates" 
            match="xsl:template[@match]" 
            use="concat('match=', normalize-space(@match), '+',
                        'mode=', normalize-space(@mode))"/>

   <xsl:template match="*" mode="test:generate-variable-declarations">
      <xsl:param name="var" as="xs:string" required="yes"/>
      <xsl:text>  let $</xsl:text>
      <xsl:value-of select="$var"/>
      <xsl:if test="@as">
         <xsl:text> as </xsl:text>
         <xsl:value-of select="@as"/>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="@href">
            <xsl:text> := doc('</xsl:text>
            <xsl:value-of select="resolve-uri(@href, base-uri(.))"/>
            <xsl:text>')</xsl:text>
            <xsl:if test="@select">/( <xsl:value-of select="@select"/> )</xsl:if>
         </xsl:when>
         <xsl:when test="node()">
            <xsl:text> := ( </xsl:text>
            <xsl:copy-of select="node()"/>
            <xsl:text> )</xsl:text>
            <xsl:if test="@select">/( <xsl:value-of select="@select"/> )</xsl:if>
         </xsl:when>
         <xsl:when test="@select">
            <xsl:text> := </xsl:text>
            <xsl:value-of select="@select"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text> := ()</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <xsl:template match="*" mode="test:create-xslt-generator">
     <xsl:copy>
       <!-- -fgeorges: Do NOT escape '{' and '}'... -->
       <xsl:copy-of select="@*"/>
       <!--xsl:for-each select="@*">
         <xsl:attribute name="{name()}" namespace="{namespace-uri()}"
           select="replace(., '(\{|\})', '$1$1')" />
       </xsl:for-each-->
       <xsl:apply-templates mode="test:create-xslt-generator" />
     </xsl:copy>
   </xsl:template>  

   <xsl:template match="text()" mode="test:create-xslt-generator">
      <!--xsl:text>text { </xsl:text-->
      <xsl:value-of select="."/>
      <!--xsl:text> }</xsl:text-->
   </xsl:template>  

   <xsl:template match="comment()" mode="test:create-xslt-generator">
      <xsl:text>comment { </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:template match="processing-instruction()" mode="test:create-xslt-generator">
      <xsl:text>processing-instruction { </xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:text> } { </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:function name="test:matching-xslt-elements" as="element()*">
     <xsl:param name="element-kind" as="xs:string" />
     <xsl:param name="element-id" as="item()" />
     <xsl:param name="stylesheet" as="document-node()" />
     <xsl:sequence select="key($element-kind, $element-id, $stylesheet)" />
   </xsl:function>  
  
</xsl:stylesheet>
