<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- using this stylesheet with Sablotron requires a version >=0.95,
     because xsl:strip-space was implemented from that version on -->

<xsl:strip-space elements="teiHeader fileDesc titleStmt respStmt editionStmt publicationStmt seriesStmt notesStmt revisionDesc TEI.2 p sourceDesc availability encodingDesc"/>


<!-- For transforming the teiHeader -->

<xsl:template match="p"><xsl:text>  </xsl:text><xsl:apply-templates/><xsl:text>

</xsl:text></xsl:template>

<xsl:template match="xptr">
  <xsl:value-of select="@url"/>
</xsl:template>

<xsl:template match="extent">  Size: <xsl:value-of select="."/><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="note[@type='status']"> * Database Status: <xsl:value-of
   select="."/> (could be 'stable', 'low-quality' etc.)
</xsl:template>

<xsl:template match="titleStmt">
  <xsl:value-of select="title"/>
  <xsl:if test="respStmt">
  <xsl:text>

</xsl:text><xsl:value-of select="respStmt/resp"/>: <xsl:value-of select="respStmt/name"/>
</xsl:if>  
  <xsl:text>
  
</xsl:text>
</xsl:template>

<xsl:template match="edition">  Edition: <xsl:apply-templates/><xsl:text>
</xsl:text></xsl:template>


<xsl:template match="publicationStmt">  Published by: <xsl:value-of
   select="./publisher"/>, <xsl:value-of select="./date"/><xsl:text>
            at: </xsl:text><xsl:value-of select="./pubPlace"/>
	    
Availability:
	  
<xsl:apply-templates select="availability/*"/><xsl:text>
</xsl:text>  
</xsl:template>

<xsl:template match="availability">
Availability: <xsl:value-of select="."/><xsl:text>
</xsl:text></xsl:template>

<xsl:template match="seriesStmt">
Series: <xsl:value-of select="./title"/><xsl:text>
</xsl:text></xsl:template>

<xsl:template match="notesStmt">Notes:
  
<xsl:apply-templates/><xsl:text>

</xsl:text></xsl:template>

<xsl:template match="note"> * <xsl:value-of select="."/><!-- todo: indentation
  of wrapped lines --></xsl:template>


<xsl:template match="sourceDesc">Source(s):
  
<xsl:apply-templates/><xsl:text>
</xsl:text></xsl:template>

<xsl:template match="projectDesc">The Project:
<xsl:value-of select="."/><xsl:text>

</xsl:text></xsl:template>

<xsl:template match="revisionDesc">Changelog:
  
<xsl:apply-templates select="change"/>

</xsl:template>

<xsl:template match="change"> * <xsl:value-of select="./date"/><xsl:text> </xsl:text>
    <xsl:value-of select="./respStmt/name"/>:

             <xsl:value-of select="./item"/><!-- todo: indentation --><xsl:text>
	
</xsl:text></xsl:template>

</xsl:stylesheet>
