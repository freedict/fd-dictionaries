<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- this stylesheet is somewhat competitive for tei2c5.xsl.
	it was written to convert single entry chunks (or the header chunk)
	into plain text. is was to be used with xmltei2xmldict.pl -->
	
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="inc/teiheader2txt.xsl" /> 
<xsl:import href="inc/teientry2txt.xsl" /> 

<xsl:output method="text" />

<!-- using this stylesheet with Sablotron requires a version >=0.95,
     because xsl:strip-space was implemented from that version on -->

<xsl:strip-space elements="form gramGrp entry teiHeader fileDesc titleStmt respStmt editionStmt publicationStmt seriesStmt notesStmt revisionDesc TEI.2 sense p sourceDesc availability encodingDesc" />

<!-- treat 00-database-short and 00-database-url specially:
     don't generate an empty line between headword and shortname/url.
     otherwise dictd shows empty shortname (url not tested as
     i don't know any project that uses it) -->
     
<xsl:template
  match="entry[form/orth='00-database-short' or form/orth='00-database-url']">
  <xsl:value-of select="form/orth" />
  <xsl:text>&#x0A;</xsl:text>
  <xsl:value-of select="def" />
  <xsl:text>&#x0A;</xsl:text>
</xsl:template>


<!-- the main template, matching entry elements -->

<xsl:template match="entry">
  <xsl:apply-templates select="form" />
  <xsl:apply-templates select="gramGrp" />
  <xsl:text>&#x0A;&#x0A;</xsl:text>
  <xsl:apply-templates select="sense|trans|def|note" />
  <xsl:text>&#x0A;</xsl:text>
</xsl:template>

<!-- here we overwrite some templates from inc/teientry2txt.xsl
     might not be required mostly -->

<xsl:template match="form">
  <xsl:for-each select="orth">
    <xsl:value-of select="."/>
    <xsl:if test="not(position()=last())">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:for-each>
  <!-- XXX better write 'orth' -->
  <xsl:apply-templates select="*[local-name()!=orth]" />
</xsl:template>

<xsl:template match="pron">
  <xsl:text> [</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="gramGrp">
  <xsl:text> &lt;</xsl:text>
  <xsl:for-each select="*">
    <xsl:value-of select="." />
    <xsl:text>.</xsl:text>
    <xsl:if test="not(position()=last())">
      <xsl:text>,</xsl:text>
    </xsl:if>
  </xsl:for-each>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="pos|gen">
  <xsl:if test="//gramGrp">
    <xsl:text> </xsl:text> 
  </xsl:if>
  <xsl:value-of select="."/>
  <xsl:text>.</xsl:text>
</xsl:template>

<xsl:template match="entry//sense">
  <xsl:value-of select="position()" />
  <xsl:text>. </xsl:text>
  <xsl:apply-templates />
  <xsl:text>&#x0A;&#x0A;</xsl:text>
</xsl:template>

<xsl:template match="trans">
  <xsl:for-each select="*">
    <xsl:apply-templates select="." />
    <xsl:if test="local-name()='tr' and not(position()=last())">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:for-each>
  <xsl:text>&#x0A;</xsl:text>
</xsl:template>

<xsl:template match="usg[not(@type)]">
  <xsl:text>     &quot;</xsl:text>
  <xsl:apply-templates />
  <xsl:text>&quot;&#x0A;</xsl:text>
</xsl:template>

<xsl:template match="def">
  <xsl:text>   </xsl:text>
  <xsl:value-of select="." />
  <xsl:text>&#x0A;</xsl:text>
</xsl:template>

</xsl:stylesheet>

