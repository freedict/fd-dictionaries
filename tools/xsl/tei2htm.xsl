<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--  xmlns="http://www.w3.org/TR/REC-html40" -->


<xsl:output method="html"/>

<xsl:template match="/TEI.2">
  <html>
    <head>
      <meta http-equiv="Content-Type" CONTENT="text/html; charset=utf-8"/>
    </head>
    <body>
      <ul>
	<xsl:apply-templates/>
      </ul>
    </body>
  </html>
</xsl:template>

<xsl:template match="entry">
  <p>
    <xsl:apply-templates select="form|gramGrp"/>
    <xsl:apply-templates select="sense|trans"/>
  </p>
</xsl:template>

<xsl:template match="orth">
  <b><xsl:apply-templates/></b>
</xsl:template>

<xsl:template match="pron">
  [<xsl:apply-templates/>]
</xsl:template>

<xsl:template match="gramGrp">
  <i><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="pos|gen|num">
  <xsl:value-of select="."/><xsl:text>. </xsl:text>
</xsl:template>

<xsl:template match="tr">
  <xsl:value-of select="."/>
  <xsl:if test="not(position()=last())">
   <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sense">
  <blockquote>
    <xsl:if test="not(last()=1)">
      <xsl:number value="position()" format="1. "/>
    </xsl:if>
    <xsl:apply-templates select="usg"/>

    <!-- all trans, comma separated; then the def(s), semicolon separated -->
    <xsl:apply-templates select="trans"/>
    
    <xsl:if test="trans and def">
      <xsl:text>; </xsl:text>
    </xsl:if>
    
    <xsl:apply-templates select="def"/>
  
    <xsl:apply-templates select="note|eg"/>

    <xsl:if test="xr">
      <br/>See also: 
      <xsl:apply-templates select="xr"/>
    </xsl:if>
  </blockquote> 
</xsl:template>

<xsl:template match="usg[@type='dom']">
  <i><xsl:value-of select="."/>. </i>
</xsl:template>

<xsl:template match="trans">
  <xsl:apply-templates/>
  <xsl:if test="not(position()=last())">, </xsl:if>
</xsl:template>

<xsl:template match="note">
  (<xsl:apply-templates/>)
</xsl:template>

<xsl:template match="eg">
  <br/><xsl:apply-templates select="q | trans/tr"/>
</xsl:template>

<xsl:template match="q">
  &quot;<xsl:apply-templates/>&quot;
</xsl:template>

<xsl:template match="eg/trans/tr">
  = &quot;<xsl:value-of select="."/>&quot;
</xsl:template>

<xsl:template match="xr">
  <a href="{ref}"><xsl:value-of select="ref"/></a>
  <xsl:if test="not(position()=last())">, </xsl:if>
</xsl:template>

</xsl:stylesheet>

