<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:include href="indent.xsl"/> 
  
  <xsl:strip-space elements="form trans def"/>


  <!-- TEI entry specific templates -->
  
  <xsl:template match="orth">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="form">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="pron">
    <xsl:text> [</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
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
    <xsl:text> &gt;</xsl:text>
  </xsl:template>

  <xsl:template match="pos">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>) </xsl:text>
  </xsl:template>

  <xsl:template match="num">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>) </xsl:text>
  </xsl:template>

  <xsl:template match="usg">
    <USG><xsl:apply-templates/></USG>
  </xsl:template>

  <xsl:template match="p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="trans"><xsl:text>&#x0A;  </xsl:text><xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="def">
    <xsl:if test="(node())"><xsl:text>&#x0A;  </xsl:text><xsl:apply-templates/></xsl:if>
  </xsl:template>

  <xsl:template match="tr">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">; </xsl:if>
  </xsl:template>

  <xsl:template match="gen"><xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text> )</xsl:text>
  </xsl:template>

</xsl:stylesheet>
