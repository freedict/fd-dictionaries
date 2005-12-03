<?xml version="1.0"?>

<!--

This stylesheet is an alternative to tei2c5.xsl.  It was written to convert
single entry chunks (or the header chunk) into plain text.  Is is to be used
with 'xmltei2xmldict.pl'.

-->
	
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="inc/teiheader2txt.xsl"/> 
  <xsl:import href="inc/teientry2txt.xsl"/> 
  <xsl:output method="text"/>

</xsl:stylesheet>

