<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output  method="xml" omit-xml-declaration="yes" encoding="UTF-8"/>


  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>


  <xsl:template match="teiHeader">
  </xsl:template>

  <xsl:template match="orth">
    <xsl:apply-templates/>
  </xsl:template>



<xsl:template match="tei.2">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="text">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="body">
<xsl:apply-templates/>
</xsl:template>


<xsl:template match="entry"><xsl:text>&#x0A;_____&#x0A;&#x0A;</xsl:text><xsl:value-of select="form/orth"/>&#x0A;
<xsl:text>&#x0A;&#x0A;</xsl:text><entry><xsl:apply-templates select='@* | node()'/></entry>
</xsl:template>



<xsl:template match='@* | node()'>
<xsl:copy><xsl:apply-templates select='@* | node()'/></xsl:copy>
</xsl:template>



</xsl:stylesheet>
