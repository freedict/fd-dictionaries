<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>

  <xsl:include href="inc/teiheader2txt.xsl"/>
  <xsl:include href="inc/teientry2txt.xsl"/>
  
  <xsl:strip-space elements="entry"/>

       
  <xsl:template match="entry">
    <!-- mark start of a new c5 format definition -->
    <xsl:text>_____&#x0A;&#x0A;</xsl:text>
    
    <!-- for generating a reverse index, take the contents of the tr elements
         and put them in the c5 headword line. headwords in that line will be
	 put into the .index file by dictfmt. they are separated by %%%, so you
	 will have to call dictfmt as 'dictfmt - -headword-separator %%%'
	 
	 (those two minus signs are separated by a space here, because otherwise
	 my sabcmd considers them as sgml comment end. for calling dictfmt you have
	 to omit that space.)  -->
    <xsl:for-each select=".//tr">
      <xsl:value-of select="." />
      <xsl:if test="not(position()=last())">%%%</xsl:if>
    </xsl:for-each>	 
    <xsl:text>&#x0A;</xsl:text>
    
    <!-- output the usual text formatted entry -->
    <xsl:apply-templates/>
    
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
