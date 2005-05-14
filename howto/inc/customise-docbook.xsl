<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'
                xmlns="http://www.w3.org/TR/xhtml1/transitional"
                exclude-result-prefixes="#default">

<!-- Makes <programlisting> (but not <literallayout>) have a shade -->
<xsl:param name="shade.verbatim" select="1"/>

<!-- Images for warnings, notes etc. -->
<xsl:param name="admon.graphics" select="1"/>

<xsl:param name="toc.max.depth" select="2"/>

<xsl:param name="make.valid.html" select="1"/>

<!-- a serifless font is set in the stylesheet -->
<xsl:param name="html.stylesheet" select="'style.css'"></xsl:param>

<!--

  Control generation of tables of contents.
  The original value for the <book> elements was:

    book      toc,title,figure,table,example,equation

  So we turned of the lists of figures and examples here.

  -->
<xsl:param name="generate.toc">
appendix  toc,title
article/appendix  nop
article   toc,title
book      toc,title,table,equation
chapter   toc,title
part      toc,title
preface   toc,title
qandadiv  toc
qandaset  toc
reference toc,title
sect1     toc
sect2     toc
sect3     toc
sect4     toc
sect5     toc
section   toc
set       toc,title
</xsl:param>

<!-- Depth to which sections should be chunked -->
<xsl:param name="chunk.section.depth" select="0"></xsl:param>

</xsl:stylesheet>
