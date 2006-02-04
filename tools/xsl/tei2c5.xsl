<?xml version='1.0' encoding='UTF-8'?>
<!-- This stylesheet converts a TEI dictionary file
     into the c5 format suitable to be processed
     by 'dictfmt -c5' -->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="inc/teiheader2txt.xsl"/>
  <xsl:import href="inc/teientry2txt.xsl"/>  
  
  <xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>

  <xsl:strip-space elements="entry"/>

  <!-- "main()" function -->
  <xsl:template match="/">
    <xsl:call-template name="t00-database-info"/>
    <xsl:call-template name="t00-database-short"/>
    <xsl:call-template name="t00-database-url"/>
    <xsl:apply-templates select="//entry" mode="c5"/>
  </xsl:template>

  <xsl:template name="t00-database-info">
    <xsl:text>_____&#x0A;&#x0A;</xsl:text>
    <xsl:text>00-database-info&#x0A;</xsl:text>
    <xsl:apply-templates select="TEI.2/teiHeader"/>
  </xsl:template>

  <xsl:template name="t00-database-short">
    <xsl:text>_____&#x0A;&#x0A;</xsl:text>
    <xsl:text>00-database-short&#x0A;</xsl:text>
    <xsl:value-of select="TEI.2/teiHeader/fileDesc/titleStmt/title"/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template name="t00-database-url">
    <xsl:text>_____&#x0A;&#x0A;</xsl:text>
    <xsl:text>00-database-url&#x0A;</xsl:text>
    <xsl:value-of select="TEI.2/teiHeader/fileDesc/sourceDesc//xptr/@url"/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>


  <xsl:template match="entry" mode="c5">
    <!-- mark start of a new c5 format definition -->
    <xsl:text>_____&#x0A;&#x0A;</xsl:text>

    <!-- take the contents of the orth elements and put them in the c5 headword
	 line. headwords in that line will be put into the .index file by
	 dictfmt. they are separated by %%%, so you will have to call dictfmt
	 as 'dictfmt - -headword-separator %%%'
         
	 (those two minus signs are separated by a space here, because
	 otherwise an XML parser considers them as sgml comment end. for
	 calling dictfmt you have to omit that space.)  -->
    <xsl:for-each select="form/orth">
      <xsl:if test="1>string-length()">
	<xsl:message>Warning! Empty headword for entry #<xsl:value-of select="position(../..)"/>
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

</xsl:stylesheet>

