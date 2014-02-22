<?xml version='1.0' encoding='UTF-8'?>
<!-- This stylesheet converts a TEI dictionary file
     into the c5 format suitable to be processed
     by 'dictfmt -c5' -->
<!-- $Id: tei2c5.xsl 1289 2014-02-16 19:30:59Z humenda $ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc">

  <xsl:import href="inc/teiheader2txt.xsl"/>
  <xsl:import href="inc/teientry2txt.xsl"/>

  <xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>

  <xsl:strip-space elements="*"/>

  <xsl:variable name="stylesheet-main_svnid">$Id: tei2c5.xsl 1289 2014-02-16 19:30:59Z humenda $</xsl:variable>

  <!-- "main()" function -->
  <xsl:template match="/">
    <xsl:call-template name="t00-database-info"/>
    <xsl:call-template name="t00-database-short"/>
    <xsl:call-template name="t00-database-url"/>
    <xsl:apply-templates select="tei:TEI/tei:text/tei:body//tei:entry" mode="c5"/>
  </xsl:template>

  <xsl:template name="t00-database-info">
    <xsl:text>_____&#x0A;&#x0A;</xsl:text>
    <xsl:text>00-database-info&#x0A;</xsl:text>
    <xsl:apply-templates select="tei:TEI/tei:teiHeader"/>
    <xsl:apply-templates select="tei:TEI/tei:text/tei:front"/>
  </xsl:template>

  <xsl:template name="t00-database-short">
    <xsl:text>_____&#x0A;&#x0A;</xsl:text>
    <xsl:text>00-database-short&#x0A;</xsl:text>
    <xsl:value-of
      select="concat(tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title,
      ' ver. ',tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition)"/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

  <xd:doc>Use either the ref of type='home' or possibly make a mistake and use the first ref under sourceDesc.</xd:doc>
  <xsl:template name="t00-database-url">
    <xsl:variable name="the_url">
      <xsl:value-of
            select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:ref[@type='home']/@target | 
            tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:ref[1]/@target"/>
    </xsl:variable>

    <xsl:if test="string-length($the_url)>0"> <!-- only executed if url present -->
      <xsl:text>_____&#x0A;&#x0A;</xsl:text>
      <xsl:text>00-database-url&#x0A;</xsl:text>
      <xsl:value-of select="$the_url"/>
        <!-- old value-of:
      select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:ref[@type='home']/@target | 
              tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:ref[1]/@target"/>
          -->
      <xsl:text>&#x0A;</xsl:text>
    </xsl:if>
  </xsl:template>


  <xsl:template match="tei:entry" mode="c5">
    <!-- mark start of a new c5 format definition -->
    <xsl:text>_____&#x0A;&#x0A;</xsl:text>

    <!-- take the contents of the orth elements and put them in the c5 headword
	 line. headwords in that line will be put into the .index file by
	 dictfmt. they are separated by %%%, so you will have to call dictfmt
	 as 'dictfmt - -headword-separator %%%'

	 (those two minus signs are separated by a space here, because
	 otherwise an XML parser considers them as sgml comment end. for
	 calling dictfmt you have to omit that space.)  -->
    <xsl:for-each select="tei:form/tei:orth">
      <xsl:if test="1>string-length()">
        <xsl:message>Warning! Empty headword for entry #<xsl:value-of select="position()"/>
        </xsl:message>
      </xsl:if>
      <xsl:value-of select="."/>
      <xsl:if test="not(position()=last())">%%%</xsl:if>
    </xsl:for-each>
    <xsl:text>&#x0A;</xsl:text>

    <!-- output the usual text formatted entry -->
    <xsl:apply-templates select="."/>

    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

<xd:doc>There is nothing special about the '=' characters, it's just a piece of quasi-aesthetic pseudomagic.</xd:doc>
<xsl:template match="tei:front">
  =====================================================================
    <xsl:apply-templates mode="front"/>  
  =====================================================================
</xsl:template>
  
  <xsl:template match="tei:div|tei:table" mode="front">
    <xsl:apply-templates mode="front"/>
  </xsl:template>

<xd:doc>An important note: tables within paragraphs will not render nice at all.</xd:doc>
  <xsl:template match="tei:p" mode="front">
    <xsl:text>&#x0A;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:row" mode="front">
    <xsl:text>| </xsl:text>
    <xsl:apply-templates mode="front"/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:cell" mode="front">
    <xsl:apply-templates/><xsl:text>  </xsl:text>
    <!-- being extremely primitive here... no need for anything fancy -->
  </xsl:template>

</xsl:stylesheet>

