<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc" exclude-result-prefixes="xd">

<xd:doc type="stylesheet">
    <xd:short>Source XML reformatter</xd:short>
    <xd:detail>
      <p>This is just an indentity transform with an added instruction to reformat the source 
        and add the XML declaration. Small and silly, but useful.</p>
      <p>Distributor: FreeDict.org (<a href="http://freedict.org/">http://freedict.org/</a>)</p>      
    </xd:detail>
    <xd:copyright>public domain</xd:copyright>
    <xd:svnId>$Id:$</xd:svnId>
  </xd:doc>

  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>