<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- Helper functions to manage indentation -->

  <xsl:template name="format">
    <xsl:param name="txt"/> 
    <xsl:param name="width"/> 
    <xsl:param name="start"/>

    <xsl:if test="$txt">
      <xsl:variable name="real-width">
        <xsl:call-template name="formatted-output">
          <xsl:with-param select="$txt" name="txt"/> 
          <xsl:with-param select="$width - $start" name="width"/> 
          <xsl:with-param select="$width" name="def"/> 
          <xsl:with-param select="$start" name="start"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:value-of select="substring($txt, 1, $real-width)"/> 

      <xsl:text>&#10;</xsl:text> 
      <xsl:value-of select="substring('    ',1, $start)"/>

      <xsl:call-template name="format">
        <xsl:with-param select="substring($txt,$real-width + 1)" name="txt"/> 
        <xsl:with-param select="$width" name="width"/> 
      </xsl:call-template>

    </xsl:if>
  </xsl:template>


  <xsl:template name="formatted-output">
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
          <xsl:when test="substring($txt, $width, 1 ) = ' '">
            <xsl:value-of select="$width"/> 
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="tune-width">
              <xsl:with-param select="$txt" name="txt"/> 
              <xsl:with-param select="$width - 1" name="width"/> 
              <xsl:with-param select="$def" name="def"/> 
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>


</xsl:stylesheet>
