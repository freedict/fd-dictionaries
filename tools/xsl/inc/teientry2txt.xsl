<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:include href="indent.xsl" /> 
  
  <xsl:strip-space elements="form trans def usg tr" />


  <!-- TEI entry specific templates -->
  
  <xsl:template match="orth">
    <xsl:apply-templates />
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

  <xsl:template match="usg[not(@type)]">
    <xsl:text>&#x0A;      &quot;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&quot;&#x0A;</xsl:text>
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
    <xsl:text>&#x0A;  </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="def">
    <xsl:if test="(node())">
      <xsl:text>&#x0A;  </xsl:text>
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tr">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">; </xsl:if>
  </xsl:template>

  <xsl:template match="gen">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text> )</xsl:text>
  </xsl:template>

  <xsl:template match="entry//note">
    <xsl:if test="text()">
      <xsl:text>&#x0A;         Note: </xsl:text>
      <xsl:value-of select="text()" />
    </xsl:if>
    <xsl:if test="@resp">
      <xsl:text>&#x0A;         Entry edited by: </xsl:text>
      <xsl:value-of select="@resp" />
      <xsl:text>&#x0A;</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
