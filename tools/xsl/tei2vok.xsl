<?xml version='1.0' encoding='UTF-8'?>
<!-- this stylesheet converts a TEI dictionary file
     into the vok format suitable to be processed
     by the MakeDict.exe tool available from
     http://www.evolutionary.net/dict-info1.htm -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="inc/teiheader2txt.xsl"/>
  <!-- xsl:import href="inc/teientry2txt.xsl"/ -->  
  
  <!-- MakeDict expects the windows-1252 encoding (without it being documented) -->
  <xsl:output method="text" omit-xml-declaration="yes" encoding="Windows-1252"/>

  <xsl:strip-space elements="entry orth tr"/>

  <!-- something like the main function -->
  <xsl:template match="/">
    <xsl:text>[words]&#x0A;</xsl:text>
    <xsl:apply-templates select="//entry" />
  
    <xsl:text>[phrases]&#x0A;</xsl:text>
    <!-- we have no phrases -->
    
    <xsl:text>[notes]&#x0A;</xsl:text>
    <xsl:apply-templates select="*//teiHeader" />

  </xsl:template>

  <xsl:template match="entry">
    <!-- in vok format we have the simple format
    
	    word/translated-word
	    
	 Also, we may have ';' characters on either side of the '/'
	 to indicate multiple translations of a word. eg.

	    ability/Faehigkeit;Begabung

         So we take the contents of the orth elements, put them before the '/'
         and take the contents of the tr elements and put them behind the '/' -->

    <xsl:for-each select="form/orth">
      <xsl:value-of select="." />
      <xsl:if test="not(position()=last())">;</xsl:if>
    </xsl:for-each>

    <xsl:text>/</xsl:text>

    <!-- what about semicolons inside headwords? -->
    <xsl:for-each select=".//tr">
      <xsl:value-of select="translate(normalize-space(.), ';/', ',+')" />
      <xsl:if test="not(position()=last())">;</xsl:if>
    </xsl:for-each>
    
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
