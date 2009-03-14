<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0">

  <xsl:import href="indent.xsl"/>

  <!-- Width of display, so indendation can be done nicely -->
  <xsl:param name="width" select="75"/>
  <!-- Has to come from the shell, as XSLT/XPath 1.0 provide no
  function to get current time/date -->
  <xsl:param name="current-date"/>
  <xsl:variable name="stylesheet-cvsid">$Id: teiheader2txt.xsl,v 1.8 2009-03-14 01:46:21 bansp Exp $</xsl:variable>

  <!-- Using this stylesheet with Sablotron requires a version >=0.95,
  because xsl:strip-space was implemented from that version on -->
  <!--<xsl:strip-space elements="teiHeader fileDesc titleStmt respStmt editionStmt publicationStmt seriesStmt notesStmt revisionDesc TEI.2 TEI p sourceDesc availability encodingDesc"/>-->
  <xsl:strip-space elements="*"/>
  
  <!-- the addition of P5 stuff relies on the absolute complementarity between
    null-spaced elements (P4) and elements in the TEI namespace (P5) -->

  <!-- For transforming the teiHeader -->

  <xsl:template match="titleStmt | tei:titleStmt">
    <xsl:value-of select="title | tei:title"/>
    <xsl:text>&#xa;&#xa;</xsl:text>
    <xsl:for-each select="respStmt | tei:respStmt">
      <xsl:value-of select="resp | tei:resp"/>: <xsl:value-of select="name | tei:name"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="edition | tei:edition">
    <xsl:text>Edition: </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="extent | tei:extent">
    <xsl:text>Size: </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>


  <xsl:template match="publicationStmt | tei:publicationStmt">
    <xsl:text>Published by: </xsl:text>
    <xsl:value-of select="./publisher  | ./tei:publisher"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="./date  | ./tei:date"/>
    <xsl:text>&#xa;at: </xsl:text>
    <xsl:value-of select="./pubPlace  | ./tei:pubPlace"/>

    <xsl:text>&#xa;&#xa;Availability:&#xa;&#xa;  </xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space(availability | tei:availability)"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="2"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="seriesStmt | tei:seriesStmt">
    <xsl:text>Series: </xsl:text>
    <xsl:value-of select="./title | ./tei:title"/>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="notesStmt | tei:notesStmt">
    <xsl:text>Notes:&#xa;&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="teiHeader//note  | tei:teiHeader//tei:note">
    <xsl:text> * </xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space()"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="3"/>
    </xsl:call-template>
  </xsl:template>

  <!-- This template must follow the previous one, otherwise
it will never be instantiated. -->
  <xsl:template match="teiHeader//note[@type='status'] | tei:teiHeader//tei:note[@type='status']">
    <xsl:text> * Database Status: </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="sourceDesc | tei:sourceDesc">
    <xsl:text>Source(s):&#xa;&#xa;  </xsl:text>
    <xsl:variable name="sdtext">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space($sdtext)"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="2"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="p | tei:p">
    <xsl:text>  </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="xptr">
    <xsl:value-of select="@url"/>
  </xsl:template>
  
  <xsl:template match="tei:ptr">
    <xsl:value-of select="@target"/>
  </xsl:template>

  <xsl:template match="projectDesc | tei:projectDesc">
    <xsl:text>The Project:&#xa;&#xa;  </xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space()"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="2"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="revisionDesc | tei:revisionDesc">
    <xsl:text>Changelog:&#xa;&#xa;</xsl:text>
    <xsl:if test="string-length($current-date)>0">
      <!-- Add conversion timestamp -->
      <xsl:text> * </xsl:text>
      <xsl:value-of select="$current-date"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$stylesheet-cvsid"/>
      <xsl:text>:&#xa;   Converted TEI file into text format&#xa;&#xa;</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="change | tei:change">
    <xsl:text> * </xsl:text>
    <xsl:value-of select="date | tei:date"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="respStmt/name | tei:respStmt/tei:name"/>
    <xsl:text>:&#xa;   </xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space(item | tei:item)"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="3"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
