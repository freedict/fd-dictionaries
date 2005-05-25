<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--

  $Revision: 1.1 $

  This stylesheet sorts the entries of a TEI file using <xsl:sort>.
  
  The sorted dictionary can be further processed by
  `group-homographs-sorted.xsl'

  Limitations:

    * The internal DTD subset gets lost.

  -->

  <!--
  
  Using the doctype-public and doctype-system attributes here is in vain,
  since TEI needs an internal subset to include optional portions of the
  TEI DTD.
  
   -->
  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:template match="text/body">
    <body>
      <xsl:apply-templates select="entry">
        <xsl:sort select="form/orth[1]"/>
      </xsl:apply-templates>
    </body>
  </xsl:template>
  
  <!-- if no other template matches,
       copy the encountered attributes and elements -->
  <xsl:template match='@* | node()'>                                              
    <xsl:copy><xsl:apply-templates select='@* | node()'/></xsl:copy>                
  </xsl:template>

</xsl:stylesheet>
