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
     
<!-- Entrées dont il faut vérifier la conversion :
 korr- pour le tag <def>, brulu pour le subtype litt, azgwerzh pour le <sense><cit>, 

-->
  <!-- TEI entry specific templates -->
  <xsl:template match="tei:entry">
    <xsl:apply-templates select="tei:form"/> 
    <xsl:apply-templates select="tei:sense"/>
</xsl:template>

<xsl:template match="tei:form">
	<xsl:apply-templates select="tei:orth"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="tei:lbl"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="tei:pos"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="tei:gen"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="tei:number"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="tei:form"/>
  <!--    form[@type='infl'] ? -->
</xsl:template>

<xsl:template match="tei:sense">
    <xsl:text>&#xa;</xsl:text>
	<xsl:apply-templates select="tei:usg"/>
	<xsl:apply-templates select="tei:lbl"/>
	<xsl:apply-templates select="tei:def"/>
	<xsl:apply-templates select="tei:cit"/><!--
	<xsl:apply-templates select="tei:cit[@type='translation']"/>
	<xsl:text>&#xa;</xsl:text>
	<xsl:apply-templates select="tei:cit[@type='example']"/>
	<xsl:text>&#xa;</xsl:text>-->
  </xsl:template>

<xsl:template match="tei:cit">
	<xsl:choose>
		<xsl:when test="@type ='translation'">	<xsl:apply-templates select="tei:cit[@type='translation']"/><xsl:text>&#xa;</xsl:text></xsl:when>
		<xsl:when test="@type ='example'">	<xsl:apply-templates select="tei:cit[@type='example']"/><xsl:text>&#xa;</xsl:text></xsl:when>
		<xsl:otherwise>	
					<xsl:apply-templates select="tei:quote"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="tei:lbl"/>
					<xsl:apply-templates select="tei:pos"/>
					<xsl:text> </xsl:text><xsl:apply-templates select="tei:gen"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="tei:number"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="tei:cit[@type='translation']"/>
		
		
		
		
		
			<!--<xsl:value-of select="."/>	<xsl:text> </xsl:text> -->
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="tei:cit[@type='example']">
	<xsl:text>&#xa;</xsl:text>	<xsl:text>     ● </xsl:text>
	<xsl:apply-templates select="tei:usg"/>
	<xsl:apply-templates select="tei:quote"/>
	<xsl:text> </xsl:text>
	<xsl:apply-templates select="tei:cit[@type='translation']"/>

</xsl:template>

<xsl:template match="tei:cit[@type='translation']">
   <xsl:choose>
      <xsl:when test="@subtype != 0">
				<xsl:text>  litt. </xsl:text>
			<xsl:apply-templates select="tei:quote"/>
      </xsl:when>
      <xsl:otherwise>
		<xsl:text>  ↪ </xsl:text>
		<xsl:apply-templates select="tei:quote"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="tei:lbl"/>
		<xsl:apply-templates select="tei:pos"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="tei:gen"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="tei:number"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="tei:form[@type]"/>
		<xsl:text> </xsl:text>
     </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="tei:lbl">
	<xsl:text>(</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>) </xsl:text>
</xsl:template>

<xsl:template match="tei:def">
	<xsl:value-of select="."/>
	<xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="tei:usg">
	<xsl:text>[</xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>] </xsl:text>
</xsl:template>

<xsl:template match="tei:quote">
<!--		<xsl:value-of select="."/> -->
		<xsl:apply-templates /> <!-- select="tei:form[@type='infl']"/>-->
</xsl:template>
<!-- template-->
<xsl:template match="tei:form[@type='infl'] | tei:pos | tei:number | tei:gen | tei:form[@type='plur'] | tei:form[@type='pastp']| tei:form[@type='sing']">
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

