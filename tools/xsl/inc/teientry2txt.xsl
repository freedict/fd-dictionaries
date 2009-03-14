<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0">

  <xsl:include href="indent.xsl"/>
   <!--<xsl:variable name="stylesheet-cvsid">
     $Id: teientry2txt.xsl,v 1.12 2009-03-14 01:45:54 bansp Exp $
     </xsl:variable>
   added the variable but then uncommented it, because it would get priority 
   over the one defined in the header module; not sure if that was indended -->

<!-- the addition of P5 stuff relies on the absolute complementarity between
     null-spaced elements (P4) and elements in the TEI namespace (P5) -->

    <xsl:strip-space elements="*"/>

  <!-- TEI entry specific templates -->
  <xsl:template match="entry | tei:entry">
    <xsl:apply-templates select="form | tei:form"/> <!-- force form before gramGrp -->
    <xsl:apply-templates select="gramGrp | tei:gramGrp"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="sense | tei:sense"/>

    <!-- For simple entries without separate senses and old FreeDict databases -->
      <!-- assume that such ultraflat structure will not be used in P5  -->
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

  <xsl:template match="form | tei:form">
      <xsl:variable name="paren" select="count(parent::form) = 1 or count(parent::tei:form) = 1 or @type='infl'"/>
    <!-- parenthesised if nested or (ad hoc) if @type="infl" -->
    <xsl:if test="$paren">
      <xsl:text> (</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="usg | tei:usg"/>     <!-- added to handle usg info in nested <form>s -->
    <xsl:for-each select="orth | tei:orth">
      <xsl:value-of select="."/>
      <xsl:if test="position() != last()">
	<xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates select="pron | tei:pron"/>
  <xsl:if test="$paren">
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="form | tei:form"/>
    <xsl:if test="following-sibling::form and following-sibling::form[1][not(@type='infl')]">
      <xsl:text>, </xsl:text>
      <!-- cosmetics: no comma before parens  -->
    </xsl:if>
      <xsl:if test="following-sibling::tei:form and following-sibling::tei:form[1][not(@type='infl')]">
          <xsl:text>, </xsl:text>
          <!-- I know, this could be a choice/when, I hope it's temporary  -->
      </xsl:if>
  </xsl:template>

  <xsl:template match="orth | tei:orth">
    <xsl:value-of select="."/>
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="pron | tei:pron"/>
  </xsl:template>


  <xsl:template match="pron | tei:pron">
    <xsl:text> /</xsl:text><xsl:apply-templates/><xsl:text>/</xsl:text>
  </xsl:template>

    <xsl:template match="gramGrp | tei:gramGrp">
        <xsl:text> &lt;</xsl:text>
        <xsl:for-each select="pos | tei:pos | num | tei:num | gen | tei:gen">
            <xsl:apply-templates select="."/>
            <xsl:if test="position()!=last()">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>></xsl:text>
    </xsl:template>

  <xsl:template match="sense | tei:sense">
    <xsl:text> </xsl:text>
    <xsl:if test="not(last()=1)">
      <xsl:number value="position()"/>
      <xsl:text>. </xsl:text>
    </xsl:if>

      <xsl:if test="count(usg | trans | def | tei:usg | tei:def)>0">
         <xsl:apply-templates select="usg | tei:usg | trans | def | tei:def"/>
         <xsl:text>&#xa;</xsl:text>
      </xsl:if>

    <xsl:if test="count(eg)>0"> <!-- P4 -->
      <xsl:text>    </xsl:text>
      <xsl:apply-templates select="eg"/>
    </xsl:if>

      <xsl:if test="count(xr | tei:xr)>0">
         <xsl:text>    </xsl:text>
         <xsl:apply-templates select="xr | tei:xr"/>
         <xsl:text>&#xa;</xsl:text>
      </xsl:if>

    <xsl:apply-templates select="*[local-name() != 'usg' and name() != 'trans' and local-name() != 'def' and name() != 'eg' and local-name() != 'xr']"/>

  </xsl:template>

   <xsl:template match="usg[@type] | tei:usg[@type]">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>.] </xsl:text>
  </xsl:template>

  <xsl:template match="trans"> <!-- P4 -->
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="tr"> <!-- P4 -->
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="def | tei:def">
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

  <xsl:template match="xr | tei:xr">
    <xsl:choose>
      <xsl:when test="not(@type) or type='cf'">
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
    <xsl:value-of select="ref | tei:ref"/>
    <xsl:text>}</xsl:text>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

   <xsl:template match="entry//p | tei:entry//tei:p">
    <xsl:apply-templates/>
  </xsl:template>

   <xsl:template match="entry//note | tei:entry//tei:note">
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

