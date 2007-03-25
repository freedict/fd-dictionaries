<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output  method="text" omit-xml-declaration="yes" encoding="UTF-8"/>

  <xsl:strip-space elements="*"/>


  <xsl:variable name="CR">NEWLINE
</xsl:variable>
  <xsl:variable name="Separate">::</xsl:variable>



  <xsl:template name="format">
    <xsl:param name="txt"/>
    <xsl:param name="width"/>
    <xsl:param name="start"/>

    <xsl:if test="$txt">
      <xsl:variable name="real-width">
        <xsl:call-template name="tune-width">
          <xsl:with-param select="$txt" name="txt"/>
          <xsl:with-param select="($width - $start)" name="width"/>
          <xsl:with-param select="($width - $start)" name="def"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:value-of select="substring('                                                    ', 1, $start)"/>
      <xsl:value-of select="substring($txt, 1, $real-width)"/>

      <xsl:text>&#10;</xsl:text>

      <xsl:call-template name="format">
        <xsl:with-param select="substring($txt,$real-width + 1)" name="txt"/>
        <xsl:with-param select="$width" name="width"/>
        <xsl:with-param select="$start" name="start"/>
      </xsl:call-template>

    </xsl:if>
  </xsl:template>


  <xsl:template name="tune-width">
    <xsl:param name="txt"/>
    <xsl:param name="width"/>


    <xsl:param name="def"/>

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
    <xsl:param name="start"/>
    <xsl:call-template name="format">
      <xsl:with-param select="." name="txt"/>
      <xsl:with-param name="width">40</xsl:with-param>
      <xsl:with-param name="start">0</xsl:with-param>
    </xsl:call-template>
  </xsl:template>



  <xsl:template match="teiHeader">
  </xsl:template>

  <xsl:template match="body/text()">
  </xsl:template>

  <xsl:template match="teiHeader">
  </xsl:template>

  <xsl:template match="orth">
    <xsl:param name="start"/>
    <xsl:apply-templates>
      <xsl:with-param select="$start" name="start"/>
    </xsl:apply-templates>
    <xsl:text>  </xsl:text>
    <xsl:value-of select='$Separate'/>
  </xsl:template>

  <xsl:template match="form">
    <xsl:param name="start"/>

    <xsl:apply-templates>
      <xsl:with-param select="$start" name="start"/>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="pron">
    <xsl:text> [</xsl:text><xsl:apply-templates/><xsl:text>] </xsl:text>
  </xsl:template>

  <xsl:template match="gramGrp">
    <xsl:param name="start"/>

    <xsl:apply-templates>
      <xsl:with-param select="$start" name="start"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="pos">
    <xsl:param name="start"/>
    <xsl:text> (</xsl:text>

    <xsl:apply-templates>
      <xsl:with-param select="$start" name="start"/>
    </xsl:apply-templates>
    <xsl:text>) </xsl:text>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:value-of select='$CR'/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="usg">
    <xsl:param name="start"/>

    <xsl:apply-templates>
      <xsl:with-param select="$start" name="start"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="p">
    <xsl:param name="start"/>

    <xsl:apply-templates>
      <xsl:with-param select="$start" name="start"/>
    </xsl:apply-templates>
  </xsl:template>



  <xsl:template match="trans">
    <xsl:variable name="content"
      select="."/>
    <!-- if there are any nodes in that list -->
    <xsl:if test="$content">
      <!-- output a paragraph -->
      <P>
        <!-- with a copy of those nodes as the content -->
        <xsl:apply-templates select="$content"/>
      </P>
    </xsl:if>

  <xsl:apply-templates>
      <xsl:with-param select="." name="txt"/>
      <xsl:with-param name="width">40</xsl:with-param>
      <xsl:with-param name="start">2</xsl:with-param>
    </xsl:apply-templates>
    <xsl:if test="not(position()=last())">
      <xsl:text>&#9;  *</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="def">
    <xsl:if test="(node())">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tr">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gen"><xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text> )</xsl:text>
  </xsl:template>

</xsl:stylesheet>
