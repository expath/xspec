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
     <xsl:param name="var" as="xs:string" required="yes" />
     <xsl:param name="type" as="xs:string" select="'variable'" />
     <xsl:choose>
       <xsl:when test="node() or @href">
         <variable name="{$var}-doc" as="document-node()">
           <xsl:choose>
             <xsl:when test="@href">
               <xsl:attribute name="select">
                 <xsl:text>doc('</xsl:text>
                 <xsl:value-of select="resolve-uri(@href, base-uri(.))" />
                 <xsl:text>')</xsl:text>
               </xsl:attribute>
             </xsl:when>
             <xsl:otherwise>
               <document>
                 <xsl:apply-templates mode="test:create-xslt-generator" />
               </document>
             </xsl:otherwise>
           </xsl:choose>
         </variable>
         <xsl:element name="xsl:{$type}">
           <xsl:attribute name="name" select="$var" />
           <xsl:attribute name="select"
             select="if (@select) 
                       then concat('$', $var, '-doc/(', @select, ')')
                     else if (@href)
                       then concat('$', $var, '-doc')
                     else concat('$', $var, '-doc/node()')" />
         </xsl:element>
       </xsl:when>
       <xsl:when test="@select">
         <xsl:element name="xsl:{$type}">
           <xsl:attribute name="name" select="$var" />
           <xsl:attribute name="select" select="@select" />
         </xsl:element>
       </xsl:when>
       <xsl:otherwise>
         <xsl:element name="xsl:{$type}">
           <xsl:attribute name="name" select="$var" />
           <xsl:attribute name="select" select="'()'" />
         </xsl:element>
       </xsl:otherwise>
     </xsl:choose>        
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

   <xsl:template match="xsl:*" mode="test:create-xslt-generator">
     <xsl:element name="o:{local-name()}">
       <xsl:copy-of select="@*" />
       <xsl:apply-templates mode="test:create-xslt-generator" />
     </xsl:element>
   </xsl:template>  

   <xsl:template match="text()" mode="test:create-xslt-generator">
     <text><xsl:value-of select="." /></text>
   </xsl:template>  

   <xsl:template match="comment()" mode="test:create-xslt-generator">
     <comment><xsl:value-of select="." /></comment>
   </xsl:template>

   <xsl:template match="processing-instruction()" mode="test:create-xslt-generator">
     <processing-instruction name="{name()}">
       <xsl:value-of select="." />
     </processing-instruction>
   </xsl:template>

   <xsl:function name="test:matching-xslt-elements" as="element()*">
     <xsl:param name="element-kind" as="xs:string" />
     <xsl:param name="element-id" as="item()" />
     <xsl:param name="stylesheet" as="document-node()" />
     <xsl:sequence select="key($element-kind, $element-id, $stylesheet)" />
   </xsl:function>  
  
</xsl:stylesheet>
