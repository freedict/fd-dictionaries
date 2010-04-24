<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--

  $Revision$

  This stylesheet converts a TEI file where homographs are not necessarily
  grouped by using the 'hom' element into a TEI file, where this grouping exists.

  It is required for conversion to bedic format.

  Grouping is done with the 'hom' element instead of the 'superEntry' element, so
  the structure can be translated more directly into the bedic-format by the SAX event
  handlers in tei2dic.py.

  Limitations:

    * entries with multiple orth elements are not supported
    * very slow, the xsl:sort element might be a solution
    * pron elements of all but the first homograph are discarded

  -->


  <!-- Using the doctype-public and doctype-system properties here is in vain,
       since TEI needs an internal subset to include optional portions of the TEI DTD -->
  <xsl:output method="xml" encoding="UTF-8"/>

  <!--

  Since XSL provides no way of outputting an internal DTD subset, we use a wrapper script
  as suggested in the XSLT Recommendation, 16.1 XML Output Method, which contains the
  default internal subset and includes the output of this stylesheet via an entity reference:

  1. Do not output the TEI.2 element. If we output it, the wrapper would have leave it out,
     which would make him non-well formed.
  2. The wrapper and the output of this stylesheet are then used together.
  2. Optionally, unwrapping to a single file can be done like this (replace each + by minus signs):

          xmllint ++noent tei-wrapper.xml >unwrapped.tei

  -->

  <!--

    The 'verbose' parameter determines, whether to output informational messages
    or not. It is off by default. To switch it on using Sablotron, use:

      sabcmd group-homographs.xsl infile.tei >grouped.tei '$verbose=1'

    Though not required, you can explicitly switch it off for example by calling
    the stylesheet with the Sablotron XSLT processor this way:

        sabcmd group-homographs.xsl infile.tei >grouped.tei '$verbose='

    As the parameter is always handed over as a string, only the empty string will
    be interpreted as a boolean 'false'.

  -->
  <xsl:param name="verbose" select="''"/>

  <!-- Do no output the TEI.2 element -->
  <xsl:template match="/TEI.2">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:variable name="myorth" select="form/orth"/>
    <xsl:variable name="myfollowing" select="following-sibling::entry"/>
    <xsl:variable name="myfollowinghomographs" select="$myfollowing[form/orth = $myorth]"/>
    <xsl:choose>

      <!-- if an entry has preceding homographs, skip it,
           as it has already been processed -->
      <xsl:when test="preceding-sibling::entry/form/orth = $myorth">
        <xsl:if test="$verbose">
	  <xsl:message terminate="no">
	    Skipping already handled homograph '<xsl:value-of select="$myorth"/>'.
	  </xsl:message>
	</xsl:if>
      </xsl:when>

      <!-- if this entry has homographs after it, group them using the
           hom element -->
      <xsl:when test="count($myfollowinghomographs) > 0">
	<entry><xsl:text>&#xa;</xsl:text>
	  <xsl:text>&#xa;        </xsl:text>

          <xsl:if test="$verbose">
	    <xsl:message terminate="no">
	      <xsl:text>Transforming using &lt;hom>: '</xsl:text>
	      <xsl:value-of select="$myorth"/>
	      <xsl:text>' has </xsl:text>
	      <xsl:value-of select="1+count($myfollowinghomographs)"/>
	      <xsl:text> homographs.</xsl:text>
	    </xsl:message>
	  </xsl:if>

	  <xsl:if test="count($myorth) > 1">
	    <xsl:message terminate="yes">
	      <xsl:text>Can't handle multiple &lt;orth> elements (yet?): </xsl:text>
	      <xsl:for-each select="$myorth">
		'<xsl:value-of select="."/>'<xsl:text> </xsl:text>
	      </xsl:for-each>- They should be separated into their own entries.
	    </xsl:message>
	  </xsl:if>

	  <xsl:apply-templates select="form"/>
	  <xsl:text>&#xa;</xsl:text>

	  <!-- copy the first homograph -->
	  <xsl:text>&#xa;        </xsl:text>
	  <hom>
	    <xsl:text>&#xa;        </xsl:text>
	    <xsl:apply-templates select="*[name(.) != 'form']"/>
	    <xsl:text>&#xa;        </xsl:text>
	  </hom>
	  <xsl:text>&#xa;        </xsl:text>

	  <!-- copy the following homographs -->
	  <xsl:for-each select="$myfollowinghomographs">
	    <xsl:text>&#xa;        </xsl:text>
	    <hom>
	      <xsl:text>&#xa;        </xsl:text>
	      <xsl:apply-templates select="*[name(.) != 'form']"/>
	      <xsl:text>&#xa;        </xsl:text>
	    </hom>
	    <xsl:text>&#xa;        </xsl:text>
	  </xsl:for-each>
	  <xsl:text>&#xa;      </xsl:text>
	</entry>
      </xsl:when>

      <!-- otherwise is has no homograps and it can be copied -->
      <xsl:otherwise>
	<entry>
	<xsl:apply-templates/>
        </entry>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <!-- if no other template matches, copy the encountered attributes and elements -->
  <xsl:template match='@* | node()'>
    <xsl:copy><xsl:apply-templates select='@* | node()'/></xsl:copy>
  </xsl:template>

</xsl:stylesheet>

