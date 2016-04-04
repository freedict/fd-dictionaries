<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns="http://www.tei-c.org/ns/1.0" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"   exclude-result-prefixes="xs xd">
<!-- JMdict_e to Freedict TEI only ! -->
<xsl:output 
	method="xml" 
	version="1.0" 
	encoding="UTF-8" 
	indent="yes" 
	doctype-system="freedict-P5.dtd"	
	/>
	
<xd:doc type="stylesheet">
    <xd:short>Transformation file to convert the JMdict into TEI P5 Freedict file</xd:short>
    <xd:detail>
      <p>The Japanese Multilingual Dictionary (jmdict) is a free xml database by Jim Breens et al.
	  (http://www.edrdg.org/jmdict/j_jmdict.html)</p>
	  <p>This stylesheet aims to convert this multilingual resource into a bilingual Freedict file. 
	  JMdict and TEI P5 DTD are quite different, so the xml elements of JMdict have been turned into TEI elements.
	  Following the pretty good JMdict DTD comments, here is how I tried to fit the TEI pattern 
	  (http://www.tei-c.org/release/doc/tei-p5-doc/fr/html/DI.html): <list>
			<item>ant => ref type="ant"</item>
			<item>dial => usg type="geo"</item>
			<item>field => usg type="dom"</item>
			<item>gloss => cit type="trans"/quote</item>
			<item>k_ele => form type="k_ele"</item>
			<item>keb => orth</item>
			<item>ke_inf => lbl type="ke_inf"</item>
			<item>ke_pri =>  usg type="pri"</item>
			<item>lsource => lang</item>
			<item>misc => note</item>
			<item>pos => note type="pos"</item>
			<item>pri => pri</item>
			<item>reb => orth</item>
			<item>r_ele => form type="r_ele</item>
			<item>re_inf => lbl typ="re_inf"</item>
			<item>re_nokanji => type="re_nokanji"</item>
			<item>re_pri => usg type="pri"</item>
			<item>re_restr => lbl type="re_restr"</item>
			<item>s_inf => note type="sense"</item>
			<item>stagk => note type="stagk"</item>
			<item>stagr => note type="stagr"</item>
			<item>xref => ref</item>
		 </list>
	  </p>
    </xd:detail>
    <xd:author>Denis ARNAUD</xd:author>
    <xd:copyright>the author(s), 2016; license: GPL v3 or any later version
      (http://www.gnu.org/licenses/gpl.html).</xd:copyright>
 </xd:doc>
	
<!-- template JMdict -->
<xsl:template match="JMdict">
<TEI xmlns="http://www.tei-c.org/ns/1.0" version="5.0">
<text><body><xsl:text>&#xa;</xsl:text>
	<xsl:for-each select="entry">	
				<entry xml:id='a{ent_seq}'>
					<xsl:apply-templates select="k_ele"/>
					<xsl:apply-templates select="r_ele"/>
					<xsl:apply-templates select="info"/>
					<xsl:apply-templates select="sense"/>
				</entry><xsl:text>&#xa;</xsl:text>
	</xsl:for-each>  	
 </body>
 </text></TEI>
</xsl:template>

<!--template K_ELE -->
<xsl:template match="k_ele"><form type="k_ele"><xsl:apply-templates/></form><xsl:text>&#xa;</xsl:text></xsl:template>	

<!--template R_ELE -->
<xsl:template match="r_ele"><form type="r_ele"><xsl:apply-templates/></form></xsl:template>

<!--template SENSE -->
<xsl:template match="sense">
			<sense><xsl:apply-templates/></sense>
</xsl:template>

<!--template POS -->
<xsl:template match="pos"><note type="pos"><xsl:value-of select="."/></note></xsl:template>	

<!--template XREF -->
<xsl:template match="xref">
	<ref><xsl:value-of select="."/></ref>
</xsl:template>	
	
<!--template ANT -->
<xsl:template match="ant">
	<ref type="ant"><xsl:value-of select="."/></ref>
</xsl:template>

<!--template GLOSS -->
<xsl:template match="gloss">
		<xsl:element name="cit">
			<xsl:attribute name="type">
				<xsl:text>trans</xsl:text>
			</xsl:attribute>
			<quote><xsl:apply-templates/></quote>
			<xsl:if test="@g_gend">
				<xsl:element name="gen"><xsl:value-of select="@g_gend" /></xsl:element>			
			</xsl:if>			
		</xsl:element>
</xsl:template>

<!--template RE_NOKANJI -->
<xsl:template match="re_nokanji"><lbl type="re_nokanji"><xsl:value-of select="."/></lbl></xsl:template>

<!--template RE_PRI -->
<xsl:template match="re_pri"><usg type="re_pri"><xsl:value-of select="."/></usg></xsl:template>

<!--template RE_INF -->
<xsl:template match="re_inf"><lbl type="re_inf"><xsl:value-of select="."/></lbl></xsl:template>

<!--template RE_RESTR -->
<xsl:template match="re_restr"><lbl type="re_restr"><xsl:value-of select="."/></lbl></xsl:template>

<!--template KE_INF -->
<xsl:template match="ke_inf"><lbl type="ke_inf"><xsl:value-of select="."/></lbl></xsl:template>
<!--template KE_PRI -->
<xsl:template match="ke_pri"><usg type="pri"><xsl:value-of select="."/></usg></xsl:template>
<!--template KEB -->
<xsl:template match="keb"><orth><xsl:value-of select="."/></orth></xsl:template>	
<!--template REB -->
<xsl:template match="reb"><orth><xsl:value-of select="."/></orth></xsl:template>	
<!--template STAGK -->
<xsl:template match="stagk"><note type="stagk"><xsl:value-of select="."/></note></xsl:template>	
<!--template STAGR -->
<xsl:template match="stagr"><note type="stagr"><xsl:value-of select="."/></note></xsl:template>	
<!--template FIELD -->
<xsl:template match="field"><usg type="dom"><xsl:value-of select="."/></usg></xsl:template>	
<!--template MISC -->
<xsl:template match="misc"><note><xsl:value-of select="."/></note></xsl:template>
<!--template DIAL -->
<xsl:template match="dial"><usg type="geo"><xsl:value-of select="."/></usg></xsl:template>
<!--template PRI -->
<xsl:template match="pri"><pri><xsl:value-of select="."/></pri></xsl:template>
<!--template S_INF -->
<xsl:template match="s_inf"><note type="sense"><xsl:value-of select="."/></note></xsl:template>

<!--template LSOURCE -->
<xsl:template match="lsource">
	<xsl:element name="lang">
		<xsl:if test="@xml:lang">
			<xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang" /></xsl:attribute>			
		</xsl:if>
		<xsl:if test="@ls_type">
			<xsl:attribute name="split"><xsl:value-of select="@ls_type" /></xsl:attribute>			
		</xsl:if>
		<xsl:if test="@ls_wasei">
			<xsl:attribute name="orig">ls_wasei</xsl:attribute>			
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:element>		
</xsl:template>

   <!--Divers caractères : — - ― • ◊ ● ○ ♦  -->
</xsl:stylesheet>
