<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:my="http://example.org/ns/my"
                exclude-result-prefixes="xs"
                version="2.0">

   <xsl:function name="my:square" as="xs:integer">
      <xsl:param name="n" as="xs:integer"/>
      <xsl:sequence select="$n * $n"/>
   </xsl:function>

   <xsl:template match="rule">
      <transformed/>
   </xsl:template>

</xsl:stylesheet>
