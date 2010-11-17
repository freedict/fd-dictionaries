<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- This xslt file aimes to turn the Geriadur tomaz (modified) into an html file.
Somes options will be explore :
Display only the headword where something has been added. The added element have the 'who' attribute.entries, senses, examples and translation can have been added.
Display only the headword which have to be reviewed, attribute rev has been added.

-->
<xsl:output
method="html"
encoding="UTF-8"
doctype-public="-//W3C//DTD HTML 4.01//EN"
doctype-system="http://www.w3.org/TR/html4/strict.dtd"
indent="yes" />

<!--template -->
<xsl:template match="teiHeader"><title><xsl:text>Entrées ajoutées/modifiées par Denis au Geriadur Tomaz</xsl:text></title>	</xsl:template>

<!-- template -->
<xsl:template match="body">
 <html><head><link rel="stylesheet" href="tei.css" type="text/css" /></head>
 <body>
	<xsl:for-each select="entry">
			<entry><xsl:apply-templates select="form | sense"/><!--<xsl:apply-templates select="sense"/>--> </entry><xsl:text>&#xa;</xsl:text>
	
	
			
<!--		<xsl:if  test="*//@who != 0 or @who !=0">
			<entry>
				<xsl:apply-templates select="form"/>
				<xsl:apply-templates select="sense"/> 		
			</entry><br/>
		</xsl:if>-->
	</xsl:for-each>  	
 </body>
 </html>
</xsl:template>

<!-- template FORM -->
<xsl:template match="form">
	<form><xsl:apply-templates select="orth"/><xsl:apply-templates select="pos"/><xsl:apply-templates select="gen"/><xsl:apply-templates select="number"/><xsl:apply-templates select="form[@type]"/><xsl:apply-templates select="lbl"/></form>
</xsl:template>	

<!--template SENSE -->
<xsl:template match="sense">
	<sense><xsl:apply-templates select="cit[@type='translation']"/><xsl:apply-templates select="def"/><xsl:apply-templates select="lbl"/><xsl:apply-templates select="usg"/><xsl:apply-templates select="cit[@type='example']"/></sense>
</xsl:template>	

<!--template ORTH -->
<xsl:template match="orth">
	<orth><xsl:value-of select="."/></orth>
</xsl:template>	

<!--template POS -->
<xsl:template match="pos">
	<pos><xsl:value-of select="."/></pos>
</xsl:template>		

<!--template GEN -->
<xsl:template match="gen">
	<gen><xsl:value-of select="."/>	</gen>
</xsl:template>

<!--template NUMBER -->
<xsl:template match="number">
	<number><xsl:value-of select="."/></number>
</xsl:template>

<!--template LBL -->
<xsl:template match="lbl">
	<lbl><xsl:value-of select="."/></lbl>
</xsl:template>

<!--template DEF -->
<xsl:template match="def">
	<def><xsl:value-of select="."/></def>
</xsl:template>

<!--template QUOTE -->
<xsl:template match="quote">
	<quote><xsl:apply-templates/></quote>
</xsl:template>

<xsl:template match="cit[@type='example']">
	<cit type="example">		<xsl:apply-templates select="quote"/>		<xsl:apply-templates select="cit[@type='translation']"/>		<xsl:apply-templates select="def"/><xsl:apply-templates select="usg"/>	</cit>
</xsl:template>

<xsl:template match="cit[@type='translation']">
   <xsl:choose>
      <xsl:when test="@subtype != 0">
		<cit type="translation" subtype="literal">
			<xsl:apply-templates select="quote"/>
		</cit>
      </xsl:when>
      <xsl:otherwise>
	    <cit type="translation">
			<xsl:apply-templates select="quote"/>
			<xsl:apply-templates select="lbl"/>
			<xsl:apply-templates select="pos"/>
			<xsl:apply-templates select="gen"/>
			<xsl:apply-templates select="number"/>
			<xsl:apply-templates select="form[@type]"/>
			<xsl:apply-templates select="usg"/>
		</cit>
      </xsl:otherwise>
    </xsl:choose>

</xsl:template>

<!--template USG -->
<xsl:template match="usg">
	<usg><xsl:apply-templates/></usg>
</xsl:template>

<!--template FORM -->
<xsl:template match="form[@type]">
	<xsl:choose>
		<xsl:when test="@type='plur'">
			<form type="plur"><xsl:apply-templates/></form>
		</xsl:when>
		<xsl:when test="@type='sing'">
		<!---->
		<xsl:choose>
			<xsl:when test="orth='-enn'">
				<form type="sing"><orth><xsl:value-of select="preceding-sibling::orth"/>enn</orth></form>
			</xsl:when>
			<xsl:otherwise> 
				<form type="sing"><xsl:apply-templates/></form>	
			</xsl:otherwise>
		</xsl:choose>
		<!---->	

		</xsl:when>
		<xsl:when test="@type='dual'">
			<form type="dual"><xsl:apply-templates/></form>
		</xsl:when>
		<xsl:when test="@type='pastp'">
			<form type="pastp"><xsl:apply-templates/></form>
		</xsl:when>
		<xsl:when test="@type='infl'">
		<!----><xsl:choose>
				<xsl:when test="orth='ioù'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ioù</orth></form>
				</xsl:when>
				<xsl:when test="orth='où'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>où</orth></form>
				</xsl:when>
				<xsl:when test="orth='ed'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ed</orth></form>
				</xsl:when>
				<xsl:when test="orth='ien'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ien</orth></form>
				</xsl:when>
				<xsl:when test="orth='ezed'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ezed</orth></form>
				</xsl:when>
				<xsl:when test="orth='où/i'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>où</orth></form><form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>i</orth></form>
				</xsl:when>
				<xsl:when test="orth='où/ioù'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>où</orth></form><form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ioù</orth></form>
				</xsl:when>
				<xsl:when test="orth='ed/ien'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ed</orth></form><form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ien</orth></form>
				</xsl:when>
				<xsl:when test="orth='ed/i'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ed</orth></form><form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>i</orth></form>
				</xsl:when>
				<xsl:when test="orth='-eien'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>eien</orth></form>
				</xsl:when>
				<xsl:when test="orth='ez'">
					<form type="plur"><orth><xsl:value-of select="preceding-sibling::orth"/>ez</orth></form>
				</xsl:when>
		<xsl:otherwise>
			<form type="infl"><xsl:apply-templates/></form>
		</xsl:otherwise>
		<!----></xsl:choose>
	
		</xsl:when>
		<xsl:otherwise>
			<form type="infl"><xsl:apply-templates/></form>
		</xsl:otherwise>
		
		
	</xsl:choose>

</xsl:template>

<!-- -->

	
	
<!--
   Divers caractères : — - ― • ◊ ● ○ ♦
 -->
</xsl:stylesheet>
