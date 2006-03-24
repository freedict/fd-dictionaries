<?xml version='1.0' encoding='UTF-8'?>
<!-- This stylesheet converts a TEI dictionary file
     into the ding format that ding.tu-chenitz.de
     first used.
     
     You can use this format with ding clients and
     it is used for importing into
     http://www.ego4u.de/de/lingodict.
  -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>

  <!--xsl:strip-space elements="entry orth tr"/-->

  <xsl:param name="stylesheet-cvsid">$Id: tei2ding.xsl,v 1.1 2006-03-24 22:00:20 micha137 Exp $</xsl:param>

  <!-- something like the main function -->
  <xsl:template match="/">
    <xsl:apply-templates select="TEI.2/text//entry"/>
  </xsl:template>

  <xsl:template match="entry">
    <!-- The format layout is (split to two lines for readability):
    
    headword1 {pos | gen for nouns}, headword2 :: \
    translated-word1, translated-word2 [domain.]
	    
     -->

     <xsl:variable name="trs" select=".//tr[not(../../../eg)] | .//def"/>
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

	  <!-- Output part-of-speech or genus for nouns -->
	  <xsl:if test="count(../../gramGrp/pos)>0">
	    <xsl:text> {</xsl:text>
	    <xsl:choose>
	      <xsl:when test="../../gramGrp/pos='n' and (../../gramGrp/gen='m' or ../../gramGrp/gen='f' or ../../gramGrp/gen='mf')">
		<xsl:value-of select="../../gramGrp/gen"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="../../gramGrp/pos"/>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:text>}</xsl:text>
	  </xsl:if>

	  <xsl:if test="not(position()=last())">; </xsl:if>
	</xsl:for-each>
	
	<xsl:text> :: </xsl:text>

	<xsl:for-each select="$trs">
	  <xsl:call-template name="normalize-word">
	    <xsl:with-param name="word" select="."/>
	  </xsl:call-template>
	  <xsl:if test="count(../../usg[@type='dom'])">
	    <xsl:text> [</xsl:text>
	    <xsl:value-of select="../../usg[@type='dom']"/>
	    <xsl:text>.]</xsl:text>
	  </xsl:if>
	  <xsl:if test="position()!=last()">; </xsl:if>
	</xsl:for-each>

	<xsl:text>&#xA;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="normalize-word">
    <xsl:param name="word"/>

    <xsl:variable name="normalized" select="normalize-space($word)"/>

    <xsl:if test="contains($normalized, ' :: ')">
      <xsl:message>Warning: Word contains languages separator (' :: '):
        <xsl:value-of select="$word"/>
      </xsl:message>
    </xsl:if>

    <xsl:variable name="translated" select="translate($normalized, ';', ',')"/>

    <xsl:if test="$normalized != $translated">
      <xsl:message>Warning: Word contained semicolon:
        <xsl:value-of select="$word"/>
Result:
        <xsl:value-of select="$translated"/>
      </xsl:message>
    </xsl:if>

    <xsl:value-of select="$translated"/>
  </xsl:template>

</xsl:stylesheet>

