<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:include href="indent.xsl"/>

  <xsl:strip-space elements="entry form gramGrp sense trans eg"/>

  <!-- TEI entry specific templates -->
  <xsl:template match="entry">
    <xsl:apply-templates select="form | gramGrp"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="sense"/>

    <!-- For simple entries without separate senses and old FreeDict databases -->
    <xsl:for-each select="trans | def | note">
      <xsl:text> </xsl:text>
      <xsl:if test="not(last()=1)">
	<xsl:number value="position()"/>
	<xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="form">
    <xsl:for-each select="orth">
      <xsl:value-of select="."/>
      <xsl:if test="position() != last()">
	<xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates select="pron"/>
  </xsl:template>

  <xsl:template match="pron">
    <xsl:text> /</xsl:text><xsl:apply-templates/><xsl:text>/</xsl:text>
  </xsl:template>

  <xsl:template match="gramGrp">
    <xsl:text> &lt;</xsl:text>
    <!-- if gender exists, do not print pos element (must be a noun then) -->
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
    <xsl:text>></xsl:text>
  </xsl:template>

  <xsl:template match="sense">
    <xsl:text> </xsl:text>
    <xsl:if test="not(last()=1)">
      <xsl:number value="position()"/>
      <xsl:text>. </xsl:text>
    </xsl:if>

    <xsl:if test="count(usg | trans | def)>0">
      <xsl:apply-templates select="usg | trans | def"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>

    <xsl:if test="count(eg)>0">
      <xsl:text>    </xsl:text>
      <xsl:apply-templates select="eg"/>
    </xsl:if>

    <xsl:if test="count(xr)>0">
      <xsl:text>    </xsl:text>
      <xsl:apply-templates select="xr"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>

    <xsl:apply-templates select="*[name() != 'usg' and name() != 'trans' and name() != 'def' and name() != 'eg' and name() != 'xr']"/>

  </xsl:template>

  <xsl:template match="usg[@type]">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>.] </xsl:text>
  </xsl:template>

  <xsl:template match="trans">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="tr">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="def">
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space()"/>
      <xsl:with-param name="width" select="75"/>
      <xsl:with-param name="start" select="4"/>
    </xsl:call-template>
    <xsl:if test="not(position()=last())">&#xa;     </xsl:if>
  </xsl:template>

  <xsl:template match="eg">
    <xsl:text>&quot;</xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="concat(normalize-space(q), '&quot;')"/>
      <xsl:with-param name="width" select="75"/>
      <xsl:with-param name="start" select="4"/>
    </xsl:call-template>

    <xsl:if test="trans">
      <xsl:text>    (</xsl:text>
      <xsl:value-of select="trans/tr"/>
      <xsl:text>)&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xr">
    <xsl:choose>
      <xsl:when test="not(@type)">
        <xsl:text>See also</xsl:text>
      </xsl:when>
      <xsl:when test="@type='syn'">
        <xsl:text>Synonym</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@type"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>: {</xsl:text>
    <xsl:value-of select="ref"/>
    <xsl:text>}</xsl:text>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="entry//p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="entry//note">
    <xsl:choose>
      <xsl:when test="@resp='translator'">
	<xsl:text>&#xa;         Entry edited by: </xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>&#xa;</xsl:text>
      </xsl:when>
      <xsl:when test="text()">
	<xsl:text>&#xa;         Note: </xsl:text>
	<xsl:value-of select="text()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

