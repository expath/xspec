<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:functx="http://www.functx.com"  xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="2.0">

	<xsl:function name="functx:read-document" as="document-node()?">
	  <xsl:sequence select="doc('xspec-result-naming-collision.xml')"/>
	</xsl:function>

</xsl:stylesheet>
