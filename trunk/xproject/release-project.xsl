<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:proj="http://expath.org/ns/project"
                xmlns:zip="http://expath.org/ns/zip"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="http://expath.org/ns/project/release.xsl"/>

   <!-- The overload point. -->
   <xsl:template match="zip:file" mode="proj:modify-release">
      <xsl:apply-templates select="." mode="add-readme"/>
   </xsl:template>

   <!-- Copy everything... -->
   <xsl:template match="node()" mode="add-readme">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="node()" mode="add-readme"/>
      </xsl:copy>
   </xsl:template>

   <!-- ...and add the README file. -->
   <xsl:template match="zip:file/zip:dir" mode="add-readme">
      <xsl:copy>
         <!-- copy the existing -->
         <xsl:copy-of select="@*"/>
         <!-- add the README file -->
         <zip:entry src="{ resolve-uri('README', $proj:project) }"/>
         <!-- copy the existing -->
         <xsl:apply-templates select="node()" mode="add-readme"/>
      </xsl:copy>
   </xsl:template>

</xsl:stylesheet>
