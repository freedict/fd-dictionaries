<?xml version='1.0' encoding='UTF-8'?>
<!--

  This stylesheet converts a TEI dictionary file from the format "used in
  Ergane Import 2006" into the format "used in Ergane Import 2001".  Such
  conversion is useful for comparing a dictionary imported in 2006 with its
  predecessor from 2001.

  The conversion comprises of these two changes:

    * drop <gramGrp> - the Ergane import of 2001 did not feature
      part of speech
    * drop all <sense> tags, but keep / "unwrap" their contents -
      the 2001 import didn't use this element

  -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- "unwrap" <sense> contents -->
  <xsl:template match="sense">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- drop <gramGrp> -->
  <xsl:template match="gramGrp">
  </xsl:template>

  <!-- copy everything else -->
  <xsl:template match='@* | node()'>
    <xsl:copy><xsl:apply-templates select='@* | node()'/></xsl:copy>
  </xsl:template>

</xsl:stylesheet>

