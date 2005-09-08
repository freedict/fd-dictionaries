<?xml version='1.0' encoding='UTF-8'?>
<!-- This stylesheet converts a TEI dictionary file
     into the vok format suitable to be processed
     by the MakeDict tool (Win32 GUI) available from
     http://www.evolutionary.net/dict-info1.htm

     Limitations:

     * The maximum word length of 128 characters is not checked. Importing a
       .vok file with MakeDict can lead to 'word too long' errors (eg. with
       deu-kur dictionary).

     -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="inc/teiheader2txt.xsl"/>
  
  <!-- MakeDict expects the windows-1252 encoding (without it being documented) -->
  <xsl:output method="text" omit-xml-declaration="yes" encoding="Windows-1252"/>

  <xsl:strip-space elements="entry orth tr"/>

  <!-- The width of PDA displays is limited. This parameter governs
       indendation and wrapping. -->
  <xsl:param name="width" select="25"/>

  <xsl:param name="stylesheet-cvsid">$Id: tei2vok.xsl,v 1.4 2005-09-08 11:54:16 micha137 Exp $</xsl:param>

  <!-- ';' and '/' have special meaning in the vok format, so they are
  not allowed in headwords or translations. The 0x2010 HYPHEN character
  is replaced by a simple 0x2d HYPHEN MINUS, othwerwise we get problems
  with the output encoding.

  Some characters with diacritical marks used in Turkish/Kurdish
  languages are replaced by base characters without diacritical marks:

  0x11e	Ğ	LATIN CAPITAL LETTER G WITH BREVE
  0x11f	ğ	LATIN SMALL LETTER G WITH BREVE
  0x130	İ	LATIN CAPITAL LETTER I WITH DOT ABOVE
  0x131	ı	LATIN SMALL LETTER DOTLESS I
  0x15e Ş	LATIN CAPITAL LETTER S WITH CEDILLA
  0x15f	ş	LATIN SMALL LETTER S WITH CEDILLA
  -->
      
  <xsl:param name="translate-from">;/&#x2010;&#x15f;ĞğİıŞş</xsl:param>
  <xsl:param name="translate-to">,+-sGgIiSs</xsl:param>

  <!-- something like the main function -->
  <xsl:template match="/">
    <xsl:text>[words]&#xA;</xsl:text>
    <xsl:apply-templates select="TEI.2/text//entry"/>
  
    <xsl:text>[phrases]&#xA;</xsl:text>
    <!-- we have no phrases -->
    
    <xsl:text>[notes]&#xA;</xsl:text>
    <xsl:apply-templates select="*//teiHeader"/>

  </xsl:template>

  <xsl:template match="entry">
    <!-- In vok format we have
    
	    word/translated-word
	    
	 Also, we may have ';' characters on either side of the '/'
	 to indicate multiple translations of a word. eg.

	    ability/Faehigkeit;Begabung

         So we take the contents of the orth elements, put them before the '/'
         and take the contents of the tr elements and put them behind the '/' -->

    <xsl:variable name="trs" select=".//tr | .//def"/>
    <xsl:choose>
      <xsl:when test="1>count(form/orth)">
	<xsl:message>Warning: Skipping entry without &lt;orth> children.</xsl:message>
      </xsl:when>
      <xsl:when test="1>count($trs)">
	<xsl:message>Warning: Skipping entry  without &lt;tr> or &lt;def> children:
	  <xsl:value-of select="form/orth"/>
	</xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="form/orth">
	  <xsl:value-of select="translate(normalize-space(.), $translate-from, $translate-to)" />
	  <xsl:if test="not(position()=last())">;</xsl:if>
	</xsl:for-each>

	<xsl:if test="count(gramGrp/pos)>0">
	  <xsl:text> {</xsl:text>
	  <xsl:choose>
	    <xsl:when test="gramGrp/pos='n' and (gramGrp/gen='m' or gramGrp/gen='f' or gramGrp/gen='mf')">
	      <xsl:value-of select="gramGrp/gen"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="gramGrp/pos"/>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:text>}</xsl:text>
	</xsl:if>

	<xsl:text>/</xsl:text>

	<!-- A limitation of the .vok format as expected by the MakeDict tool
	     (and documented in its Online Help File) is that the maximum
	     number of translation equivalents is 16. -->
	<xsl:if test="count($trs)>16">
	  <xsl:message>Warning! Ignoring translation alternatives exceeding 16 for entry:
	    <xsl:value-of select="form/orth"/>
	  </xsl:message>
        </xsl:if>

	<!-- We could as well warn of semicolons being translated to commas... -->	
	<xsl:for-each select="$trs[16>position()]">
	  <xsl:value-of select="translate(normalize-space(.), $translate-from, $translate-to)" />
	  <xsl:if test="position()!=last()">;</xsl:if>
	</xsl:for-each>

	<xsl:text>&#xA;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

