<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:tei="http://www.tei-c.org/ns/1.0">

<!-- currently, it takes the first name from the first respStmt, which is error-prone and would change 
in XSLT 2.0, which would return a sequence here; this script is only used by the StarDict component -->
  
<xsl:output method="text"/>

<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="count(TEI.2)"> <!-- P4 dictionaries are in the null namespace -->
      <xsl:value-of select="TEI.2/teiHeader/fileDesc/titleStmt/respStmt/name"/>    
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:name"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>

