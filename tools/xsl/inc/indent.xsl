<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- Helper functions to manage indentation -->

  <!-- You need at least Version 1.0 of Sablotron from August 8, 2003
       (ChangeLog says "fixed a bug of default NS in imported/included templates")
       if you get error messages like:

         Error [code:52] [URI:file:tools/xsl/inc/teiheader2txt.xsl] [line:10]
           [node:element '<xsl:call-template>'] called nonexistent rule 'format'

       This bug appears at least in sabcmd 0.98 (April 7, 2003).
  -->

  <!-- This is the template intended to be called from outside -->
  <xsl:template name="format">
    <!-- The text to be formatted nicely -->
    <xsl:param name="txt"/>
    <!-- A number giving the column width in which txt is to be formatted
    indented by $start spaces -->
    <xsl:param name="width" select="78"/>
    <!-- A number giving the columns the txt is to be indented -->
    <xsl:param name="start" select="0"/>

    <xsl:choose>
      <!-- Last Line -->
      <xsl:when test="string-length($txt) &lt; $width -$start">
	<xsl:value-of select="$txt"/>
	<xsl:text>&#10;</xsl:text>
      </xsl:when>

      <!-- substring() of a NULL string would be bad -->
      <xsl:when test="$txt">
	<!-- Find the word boundary of the last word that completely fits on the current line -->
	<xsl:variable name="real-width">
	  <xsl:call-template name="space-backward">
	    <xsl:with-param select="$txt" name="txt"/>
	    <xsl:with-param select="$width - $start" name="width"/>
	    <xsl:with-param select="$start" name="start"/>
	    <xsl:with-param name="def">
	      <xsl:call-template name="space-forward">
		<xsl:with-param select="$txt" name="txt"/>
		<xsl:with-param select="$width - $start" name="width"/>
		<xsl:with-param select="$start" name="start"/>
	      </xsl:call-template>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:variable>
	<!-- Output current line -->
	<xsl:value-of select="substring($txt, 1, $real-width)"/>
	<xsl:text>&#10;</xsl:text>
	<!-- Indent the next line -->
	<xsl:value-of select="substring('                   ', 1, $start)"/>
	<!-- Recursively call myself -->
	<xsl:call-template name="format">
	  <xsl:with-param select="substring($txt, $real-width + 1)" name="txt"/>
	  <xsl:with-param select="$width" name="width"/>
	  <xsl:with-param select="$start" name="start"/>
	</xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- This template returns a number, (0 <= return value <= $width) or $def.
  It seems to look for the column of the last space in $txt, smaller than $width.
  If no space found, $def is returned. -->
  <xsl:template name="space-backward">
    <xsl:param name="txt"/>
    <xsl:param name="width"/>
    <xsl:param name="def"/>
    <xsl:param name="start"/>
    <xsl:choose>
      <xsl:when test="$width = 0">
        <xsl:value-of select="$def"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="substring($txt, $width, 1) = ' '">
            <xsl:value-of select="$width"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="space-backward">
              <xsl:with-param select="$txt" name="txt"/>
              <xsl:with-param select="$width - 1" name="width"/>
              <xsl:with-param select="$def" name="def"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This template returns a number ($width <= return value <= string-length($txt)).
  It seems to look for the column of the next space in $txt after $width. If no
  space found, string-length($txt) is returned. It does primitive recursion over $width. -->
  <xsl:template name="space-forward">
    <xsl:param name="txt"/>
    <xsl:param name="width"/>
    <xsl:choose>
      <xsl:when test="$width >= string-length($txt)">
	<xsl:value-of select="string-length($txt)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="substring($txt, $width, 1) = ' '">
            <xsl:value-of select="$width"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="space-forward">
              <xsl:with-param select="$txt" name="txt"/>
              <xsl:with-param select="$width + 1" name="width"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Use the 'format' template per default for outputting text nodes -
  <xsl:template match="text()">
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="."/>
      <xsl:with-param name="width" select="70"/>
      <xsl:with-param name="start" select="0"/>
    </xsl:call-template>
  </xsl:template>
  -->

</xsl:stylesheet>

