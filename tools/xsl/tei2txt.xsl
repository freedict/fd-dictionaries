<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">


<xsl:output method="text"/>


<!-- using this stylesheet with Sablotron requires a version >=0.95,
     because xsl:strip-space was implemented from that version on -->

<xsl:strip-space elements="form gramGrp entry teiHeader fileDesc titleStmt respStmt editionStmt publicationStmt seriesStmt notesStmt revisionDesc TEI.2 sense"/>


<!-- treat 00-database-short and 00-database-url specially:
     don't generate an empty line between headword and shortname/url.
     otherwise dictd shows empty shortname (url not tested as
     i don't know any project that uses it) -->
     
<xsl:template
  match="entry[form/orth='00-database-short' or form/orth='00-database-url']">
<xsl:value-of select="form/orth"/><xsl:text>
</xsl:text><xsl:value-of select="def"/>
<xsl:text>
</xsl:text>
</xsl:template>


<!-- the main template, matching entry elements -->

<xsl:template match="entry">
<xsl:apply-templates select="form"/>
  <xsl:apply-templates select="gramGrp"/><xsl:text>

</xsl:text>
  <xsl:apply-templates select="sense|trans|def"/>
<xsl:text>
</xsl:text></xsl:template>


<xsl:template match="form">
  <xsl:for-each select="orth"><xsl:value-of select="."/>
    <xsl:if test="not(position()=last())"><xsl:text>, </xsl:text></xsl:if>
  </xsl:for-each>
  <xsl:apply-templates select="*[local-name()!=orth]"/>
</xsl:template>

<xsl:template match="pron">
<xsl:text> </xsl:text>[<xsl:value-of select="."/>]</xsl:template>

<xsl:template match="gramGrp">
  <xsl:text> </xsl:text>&lt;<xsl:for-each select="*"><xsl:value-of select="."/><xsl:text>.</xsl:text>
  <xsl:if test="not(position()=last())"><xsl:text>,</xsl:text></xsl:if>
</xsl:for-each><xsl:text></xsl:text>&gt;</xsl:template>

<xsl:template match="pos|gen">
<!--<xsl:message>parent: <xsl:value-of select="//gramGrp"/></xsl:message> -->
  <xsl:if test="//gramGrp"><xsl:text> </xsl:text> 
<!-- <xsl:message>I'm here!</xsl:message>-->
    </xsl:if>
  <xsl:value-of select="."/><xsl:text>.</xsl:text>
</xsl:template>

<xsl:template match="entry//sense"><xsl:value-of select="position()"/>. <xsl:apply-templates/>

</xsl:template>

<xsl:template match="trans">
  <xsl:for-each select="*"><xsl:apply-templates select="."/>
    <xsl:if test="local-name()='tr' and not(position()=last())">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:for-each>
  <xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="usg">
  <xsl:text>     &quot;</xsl:text><xsl:apply-templates/><xsl:text>&quot;
</xsl:text></xsl:template>

<xsl:template match="def">
<xsl:text>   </xsl:text><xsl:value-of select="."/><xsl:text>
</xsl:text></xsl:template>



<!-- For transforming the teiHeader -->

<xsl:template match="titleStmt"><xsl:value-of select="title"/><xsl:text>

</xsl:text><xsl:value-of select="respStmt/resp"/>: <xsl:value-of select="respStmt/name"/>
  <xsl:text>
  
</xsl:text>
</xsl:template>

<xsl:template match="edition">
Edition: <xsl:apply-templates/><xsl:text>
</xsl:text></xsl:template>


<xsl:template match="publicationStmt">
Published by: <xsl:value-of select="./publisher"/>, <xsl:value-of select="./date"/><xsl:text>
    
Published at: </xsl:text><xsl:value-of select="./pubPlace"/><xsl:text>
</xsl:text>  
</xsl:template>

<xsl:template match="availability">
Availability: <xsl:value-of select="."/><xsl:text>
</xsl:text></xsl:template>

<xsl:template match="seriesStmt">
Series: <xsl:value-of select="./title"/><xsl:text>
</xsl:text></xsl:template>

<xsl:template match="notesStmt">
Notes:
<xsl:apply-templates/><xsl:text>
</xsl:text></xsl:template>

<xsl:template match="note"> * <xsl:value-of select="."/><!-- todo: indentation --></xsl:template>


<xsl:template match="sourceDesc">
Source: <xsl:value-of select="."/><xsl:text>
</xsl:text></xsl:template>

<xsl:template match="projectDesc">
The Project: <xsl:value-of select="."/><xsl:text>

</xsl:text></xsl:template>

<xsl:template match="revisionDesc">Changelog:
<xsl:apply-templates select="change"/>

</xsl:template>

<xsl:template match="change"> * <xsl:value-of select="./date"/><xsl:text> </xsl:text>
    <xsl:value-of select="./respStmt/name"/>: <xsl:value-of select="./item"/><!-- todo: indentation --><xsl:text>
</xsl:text></xsl:template>

</xsl:stylesheet>
