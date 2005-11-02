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

  <xsl:param name="stylesheet-cvsid">$Id: tei2vok.xsl,v 1.8 2005-11-02 22:41:59 micha137 Exp $</xsl:param>

  <!-- ';' and '/' have special meaning in the vok format, so they are
  not allowed in headwords or translations. The 0x2010 HYPHEN character
  is replaced by a simple 0x2d HYPHEN MINUS, othwerwise we get problems
  with the output encoding.

  Some characters with diacritical marks used in Turkish/Kurdish/Croatian
  languages are replaced by base characters without diacritical marks:

  0x103 ă	LATIN SMALL LETTER A WITH BREVE
  0x105 ą	LATIN SMALL LETTER A WITH OGONEK
  0x106 Ć	LATIN CAPITAL LETTER C WITH ACUTE
  0x107 ć	LATIN SMALL LETTER C WITH ACUTE
  0x10c Č	LATIN CAPITAL LETTER C WITH CARON
  0x10d č	LATIN SMALL LETTER C WITH CARON
  0x110 Đ	LATIN CAPITAL LETTER D WITH STROKE
  0x111 đ	LATIN SMALL LETTER D WITH STROKE
  0x113 ē	LATIN SMALL LETTER E WITH MACRON
  0x11e	Ğ	LATIN CAPITAL LETTER G WITH BREVE
  0x11f	ğ	LATIN SMALL LETTER G WITH BREVE
  0x130	İ	LATIN CAPITAL LETTER I WITH DOT ABOVE
  0x131	ı	LATIN SMALL LETTER DOTLESS I
  0x14c Ō	LATIN CAPITAL LETTER O WITH MACRON
  0x14d ō	LATIN SMALL LETTER O WITH MACRON
  0x159	ř	LATIN SMALL LETTER R WITH CARON
  0x15e Ş	LATIN CAPITAL LETTER S WITH CEDILLA
  0x15f	ş	LATIN SMALL LETTER S WITH CEDILLA
  0x16d ŭ	LATIN SMALL LETTER U WITH BREVE
  0x175 ŵ	LATIN SMALL LETTER W WITH CIRCUMFLEX
  0x177 ŷ	LATIN SMALL LETTER Y WITH CIRCUMFLEX
  -->

  <xsl:param name="translate-from">;/&#x2010;ĞğİıŞşćčđřăČąĆĐŭŵŷŌōē</xsl:param>
  <xsl:param name="translate-to">,+-GgIiSsccdraCaCDuwyOoe</xsl:param>

  <!-- These chars are removed:

  0x2d9 ˙	DOT ABOVE
  -->

  <xsl:param name="remove-chars">˙</xsl:param>

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
	  <xsl:call-template name="normalize-word">
	    <xsl:with-param name="word" select="."/>
	  </xsl:call-template>
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

	<xsl:for-each select="$trs[16>position()]">
	  <xsl:call-template name="normalize-word">
	    <xsl:with-param name="word" select="."/>
	  </xsl:call-template>
	  <xsl:if test="position()!=last()">;</xsl:if>
	</xsl:for-each>

	<xsl:text>&#xA;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="normalize-word">
    <xsl:param name="word"/>

    <xsl:variable name="word1">
      <xsl:call-template name="substring-replace">
	<xsl:with-param name="string" select="$word"/>
	<!-- LATIN CAPITAL LIGATURE IJ -->
	<xsl:with-param name="what" select="'&#x132;'"/>
	<xsl:with-param name="by" select="'IJ'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="word2">
      <xsl:call-template name="substring-replace">
	<xsl:with-param name="string" select="$word1"/>
	<!-- LATIN SMALL LIGATURE IJ -->
	<xsl:with-param name="what" select="'&#x133;'"/>
	<xsl:with-param name="by" select="'ij'"/>
      </xsl:call-template>
    </xsl:variable>
    
    <!-- We could warn of semicolons being translated to commas -->	
    <xsl:value-of select="translate(translate(normalize-space($word2), $translate-from, $translate-to), $remove-chars, '')"/>
  </xsl:template>

  <xsl:template name="substring-replace">
    <xsl:param name="string"/>
    <xsl:param name="what"/>
    <xsl:param name="by"/>
    <xsl:if test="string-length($string)>0">
      <xsl:choose>
	<xsl:when test="substring($string,1,string-length($what))=$what">
	  <!-- replace found substring -->
	  <xsl:value-of select="$by"/>
	  <xsl:call-template name="substring-replace">
	    <xsl:with-param name="string" select="substring($string,1+string-length($what))"/>
	    <xsl:with-param name="what" select="$what"/>
	    <xsl:with-param name="by" select="$by"/>
	  </xsl:call-template>

	</xsl:when>
	<xsl:otherwise>
	  <!-- copy current char -->
	  <xsl:value-of select="substring($string,1,1)"/>
	  <xsl:call-template name="substring-replace">
	    <xsl:with-param name="string" select="substring($string,2)"/>
	    <xsl:with-param name="what" select="$what"/>
	    <xsl:with-param name="by" select="$by"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

