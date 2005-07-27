<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:include href="indent.xsl"/> 
  
  <xsl:strip-space elements="form trans def usg tr"/>


  <!-- TEI entry specific templates -->
  
  <xsl:template match="form">
    <xsl:for-each select="orth">
      <xsl:value-of select="."/>
      <xsl:if test="position() != last()">
	<xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates select="pron"/>
  </xsl:template>

  <xsl:template match="pron">
    <xsl:text> /</xsl:text><xsl:apply-templates/><xsl:text>/</xsl:text>
  </xsl:template>

  <xsl:template match="gramGrp">
    <xsl:text> &lt;</xsl:text>
    <!-- if gender exists, do not print pos element (must be a noun then) -->
    <xsl:choose>
      <xsl:when test="gen">
        <xsl:apply-templates select="gen"/>
      </xsl:when>
      <xsl:when test="num">
        <xsl:apply-templates select="num"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="pos"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>></xsl:text>
  </xsl:template>

  <xsl:template match="sense">
    <xsl:if test="not(last()=1)">
      <xsl:number value="position()"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="eg">
    <xsl:text>&#x0A;      &quot;</xsl:text>
    <xsl:apply-templates select="q"/>
    <xsl:text>&quot;</xsl:text>
    <xsl:if test="trans">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="trans/tr"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="usg[@type]">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>.] </xsl:text>
  </xsl:template>
  
  <xsl:template match="entry//p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="trans">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="def">
    <xsl:if test="(node())">
      <xsl:text>&#x0A;  </xsl:text>
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tr">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="entry//note">
    <xsl:choose>
      <xsl:when test="@resp='translator'">
	<xsl:text>&#x0A;         Entry edited by: </xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>&#x0A;</xsl:text>
      </xsl:when>
      <xsl:when test="text()">
	<xsl:text>&#x0A;         Note: </xsl:text>
	<xsl:value-of select="text()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xr">
    &#xa;<xsl:value-of select="@type"/>: {<xsl:value-of select="ref"/>}
  </xsl:template>

</xsl:stylesheet>

