<?xml version='1.0' encoding='UTF-8'?>

<!--
     This stylesheet converts a TEI file into
     the dic format used by libbedic.

     In FreeDict, tei2dic.py is poreferred for this purpose presently.

  -->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output  method="xml" omit-xml-declaration="yes" encoding="UTF-8"/>

<xsl:template match="teiHeader">
</xsl:template>

  <xsl:template match="orth">
    <HW><xsl:apply-templates/></HW>
  </xsl:template>

  <xsl:template match="pron">
    <xsl:text>{pr}</xsl:text><xsl:apply-templates/><xsl:text>{pr}</xsl:text>
  </xsl:template>

  <xsl:template match="gramGrp">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="pos">
    <xsl:text>{ps}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>{/ps}</xsl:text>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="usg">
    <USG><xsl:apply-templates/></USG>
  </xsl:template>

  <xsl:template match="p">
    <xsl:apply-templates/>
  </xsl:template>



  <xsl:template match="trans">
    <DEF><xsl:apply-templates/></DEF>
  </xsl:template>

  <xsl:template match="def">
    <xsl:if test="(node())">
      <DEF><xsl:apply-templates/></DEF>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tr"><xsl:apply-templates/><xsl:if test="not(position()=last())">; </xsl:if></xsl:template>

  <xsl:template match="gen"><xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text> )</xsl:text>
  </xsl:template>

</xsl:stylesheet>
