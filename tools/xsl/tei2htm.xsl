<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--  xmlns="http://www.w3.org/TR/REC-html40" -->


<xsl:output method="html"/>

<xsl:template match="/TEI.2">
<html>
  <body>
   <ul>
   <xsl:apply-templates/>
   </ul>
  </body>
</html>

</xsl:template>

<xsl:template match="entry">
 <p><xsl:apply-templates/>
 </p>
</xsl:template>

<xsl:template match="orth">
 <b><xsl:value-of select="."/></b>
</xsl:template>

<xsl:template match="gramGrp">
  &lt;<xsl:for-each select="*"><xsl:apply-templates/>
  <xsl:if test="not(position()=last())">
    <xsl:text>,</xsl:text>
  </xsl:if>
</xsl:for-each><xsl:text></xsl:text>&gt;
</xsl:template>

<xsl:template match="pos|gen">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="trans">
  <xsl:for-each select="*"><xsl:apply-templates/>
    <xsl:if test="not(position()=last())">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>


