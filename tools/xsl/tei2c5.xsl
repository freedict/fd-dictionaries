<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output  method="text" omit-xml-declaration="yes" encoding="UTF-8"/>

  <xsl:strip-space elements="form trans def entry"/>

  <!-- Helper functions -->


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


  <xsl:template match="teiHeader">
  </xsl:template>

  <xsl:template match="orth">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="form"><xsl:apply-templates/></xsl:template>


  <xsl:template match="pron">
    <xsl:text> [</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="gramGrp">
    <xsl:text> &lt;</xsl:text>
<!-- if gender exists, do not print pos element (must be a noun then)-->
    <xsl:choose>
      <xsl:when test="gen">
        <xsl:apply-templates select="gen"/>
      </xsl:when>
      <xsl:when test="num">
        <xsl:apply-templates select="num"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="pos"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> &gt;</xsl:text>
  </xsl:template>

  <xsl:template match="pos">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>) </xsl:text>
  </xsl:template>

  <xsl:template match="num">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>) </xsl:text>
  </xsl:template>


  <xsl:template match="entry"><xsl:text>&#x0A;_____&#x0A;&#x0A;</xsl:text><xsl:value-of select="form/orth"/><xsl:text>&#x0A;</xsl:text><xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="usg">
    <USG><xsl:apply-templates/></USG>
  </xsl:template>

  <xsl:template match="p">
    <xsl:apply-templates/>
  </xsl:template>



  <xsl:template match="trans"><xsl:text>&#x0A;  </xsl:text><xsl:apply-templates/>
  </xsl:template>

<xsl:template match="def">
  <xsl:if test="(node())"><xsl:text>&#x0A;  </xsl:text><xsl:apply-templates/></xsl:if>
</xsl:template>

  <xsl:template match="tr">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">; </xsl:if>
  </xsl:template>



  <xsl:template match="gen"><xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text> )</xsl:text>
  </xsl:template>

</xsl:stylesheet>
