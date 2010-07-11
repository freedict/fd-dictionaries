<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0">

  <xsl:include href="indent.xsl"/>
   <!--<xsl:variable name="stylesheet-cvsid">
     $Id: teientry2txt.xsl,v 1.15 2009/11/09 03:47:52 bansp Exp $
     </xsl:variable>
   added the variable but then uncommented it, because it would get priority 
   over the one defined in the header module; not sure if that was indended -->

<!-- the addition of P5 stuff relies on the absolute complementarity between
     null-spaced elements (P4) and elements in the TEI namespace (P5) -->

    <xsl:strip-space elements="*"/>

<!-- I am fully aware of introducing some project-specific features into the P5 mode,
     but let this stuff reside here for a while until we come up with a clean way to 
     import project-dependent overrides from the individual project directories... 13-apr-09-->

  <!-- TEI entry specific templates -->
  <xsl:template match="entry | tei:entry">
    <xsl:apply-templates select="form | tei:form"/> 
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="sense | tei:sense"/>
</xsl:template>

<xsl:template match="form">
	<xsl:apply-templates select="orth"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="lbl"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="pos"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="gen"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="number"/>
  <!--    form[@type='infl'] ? -->
</xsl:template>

<xsl:template match="sense">
	<xsl:apply-templates select="usg"/>
	<xsl:apply-templates select="lbl"/>
	<xsl:apply-templates select="cit[@type='translation']"/>
	<xsl:text>&#xa;</xsl:text>
	<xsl:apply-templates select="cit[@type='example']"/>
	<xsl:text>&#xa;</xsl:text>
  </xsl:template>

<xsl:template match="lbl">
	<xsl:text>(</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>) </xsl:text>
</xsl:template>

<xsl:template match="cit[@type='example']">
	<xsl:text>     ● </xsl:text>
	<xsl:apply-templates select="usg"/>
	<xsl:apply-templates select="quote"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="cit[@type='translation']"/>
	<xsl:text>&#xa;</xsl:text>
</xsl:template>

<xsl:template match="cit[@type='translation']">
	<xsl:text>  ↪ </xsl:text>
	<xsl:apply-templates select="quote"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="lbl"/>
	<xsl:apply-templates select="pos"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="gen"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="number"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="form[@type]"/>
	<xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="usg">
	<xsl:text>[</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>] </xsl:text>
</xsl:template>

<xsl:template match="quote">
<!--		<xsl:value-of select="."/> -->
		<xsl:apply-templates /> <!-- select="form[@type='infl']"/>-->
</xsl:template>
<!-- template-->
<xsl:template match="form[@type='infl'] | pos | number | gen | form[@type='plur'] | form[@type='pastp']| form[@type='sing']">
	<xsl:copy>
	   <xsl:for-each select="node()">
		<xsl:text> </xsl:text>
		<xsl:value-of select="."/>
	   </xsl:for-each>
	</xsl:copy>
</xsl:template>


<xsl:template match="form[@type='infl'] | lbl">
	<xsl:text>(</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>)</xsl:text>
</xsl:template>


<!-- caractères spéciaux — - ― • ◊ ● ○ ♦ -->

</xsl:stylesheet>

