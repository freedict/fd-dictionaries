<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--

  $Revision$

  This stylesheet converts a TEI dictionary where homographs are not
  necessarily grouped with <hom> elements into a TEI file, where this
  grouping exists. Grouped homographs are required for conversion to
  bedic format, where multiple entries with headwords that are equal
  are not allowed.

  Grouping is done with the <hom> element and not the <superEntry> element,
  so the structure could be translated more directly into the bedic format
  by the SAX event handlers in `tei2dic.py'.

  This variant expects the entries sorted in any order, as long as
  entries where the first <orth> elements compare equal, are next to each
  other. The <xsl:sort> element can be used for that (see `sort.xsl').
  By processing a sorted dictionary we are trying to be faster by not
  having to look more than one entry backward for homographs.
  This variant is worlds faster than the variant without sorting.

  <gramGrp> elements become children of the respective <hom> elements.

  Limitations:

    * entries with multiple <orth> elements are not supported
    * <pron> elements of all but the first homograph are discarded
    * the <pron> element of the first homograph will apply for all homographs
    * fate of preexistent <hom> elements undefined

  If you process the output of this stylesheet further into the bedic format,
  the xerox tool of bedic might give warnings about duplicate headwords. These
  may be caused by characters from the "search-ignore-chars" property in bedic
  appearing in headwords, eg. an entry with headword "ba" and one with headword
  "ba-" compare equal, causing a warning about them to be emitted.

  Another cause of duplicate warnings from xerox is capitalization eg. english
  "turkey" (the bird) and "Turkey" (the country) compare equal according to the
  default "char-precedence" property.

  Those warnings are no source of concern. To avoid them you could adjust the
  respective properties for the cost of loosing flexibility in word lookup.

  -->

  <!--

  Using the doctype-public and doctype-system attributes here is in vain,
  since TEI needs an internal subset to include optional portions of the
  TEI DTD

   -->
  <xsl:output method="xml" encoding="UTF-8"/>

  <!--

  Since XSLT 1.1 provides no way of outputting an internal DTD subset, we use
  a wrapper script as suggested in the XSLT Recommendation,
  16.1 XML Output Method. The wrapper contains the FreeDict default of an
  internal subset and will try to include the output of this stylesheet
  via an entity reference. The output of this file has to be saved in a
  file called `sorted.tei'. For the wrapper to work we have to:

    1. Do not output the TEI.2 element. If we output it, the wrapper would
       have leave it out, which would make him non-well formed.
    2. The wrapper and the output of this stylesheet are then used together.
    3. Optionally, unwrapping to a single file can be done like this
       (replace each + by minus signs):

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

  <xsl:template match="text/body">
    <body>
      <xsl:apply-templates select="entry">
        <xsl:sort select="form/orth[1]"/>
      </xsl:apply-templates>
    </body>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:variable name="myorth" select="form/orth"/>

    <!-- Progress message every 100 entries, if verbose mode -->
    <xsl:if test="$verbose and (position() mod 100)=0">
      <xsl:message terminate="no">Processing entry <xsl:value-of select="position()"/></xsl:message>
    </xsl:if>

    <xsl:choose>

      <!--

      If an entry has a preceding homograph, skip it,
      as it has already been processed. In this place, since
      the entry node list is sorted, it is enough to check
      just the first preceding entry.

      We use the preceding/following-sibling axises here.
      Note that they refer to the entries of the document in
      document order. If we did the sorting in this stylesheet,
      we would require a means to refer to the sorted list.
      We would have to refer to the preceding/following nodes in the
      context node list. Unfortunately, there are no such things
      as context node list axises or a function to access the
      context node list in XSLT 1.1.

      -->
      <xsl:when test="preceding-sibling::entry[1]/form/orth = $myorth">
        <xsl:if test="$verbose">
	  <xsl:message terminate="no">
	    <xsl:text>	Skipping already handled homograph '</xsl:text>
	    <xsl:value-of select="$myorth"/>
	    <xsl:text>'.</xsl:text>
	  </xsl:message>
	</xsl:if>
      </xsl:when>

      <!--

      If the immediately following entry is not a homograph, then
      the current entry has no homographs and can be copied.

      -->
      <xsl:when test="following-sibling::entry[1]/form/orth != $myorth">
	<entry>
	<xsl:apply-templates/>
        </entry>
      </xsl:when>

      <!-- This entry has homographs after it. Group them using the <hom> element -->
      <xsl:otherwise>

	<entry><xsl:text>&#xa;</xsl:text>
	  <xsl:text>&#xa;        </xsl:text>

          <xsl:if test="$verbose">
	    <xsl:message terminate="no">
	      <xsl:text>Transforming using &lt;hom>: '</xsl:text>
	      <xsl:value-of select="$myorth"/>
	      <xsl:text>' has </xsl:text>
	      <!--xsl:value-of select="1+count($myfollowinghomographs)"/-->
	      <xsl:text>? homographs.</xsl:text>
	    </xsl:message>
	  </xsl:if>

	  <xsl:if test="count($myorth) > 1">
	    <xsl:message terminate="no">
	      <xsl:text>Warning: Can't handle multiple &lt;orth> elements: </xsl:text>
	      <xsl:for-each select="$myorth">
		'<xsl:value-of select="."/>'<xsl:text> </xsl:text>
	      </xsl:for-each>- Results undefined. They should be separated into their own entries.
	    </xsl:message>
	  </xsl:if>

	  <!-- XXX we should remove the <pron> from the first <form> -->
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
	  <xsl:call-template name="recursive-following-homograps-into-hom">
	    <xsl:with-param name="orth-of-first-homograph" select="$myorth"/>
	    <xsl:with-param name="current" select="."/>
	  </xsl:call-template>

	  <xsl:text>&#xa;      </xsl:text>
	</entry>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="recursive-following-homograps-into-hom">
    <xsl:param name="orth-of-first-homograph"/>
    <xsl:param name="current" value="."/>

    <xsl:variable name="next" select="$current/following-sibling::entry[1]"/>

    <xsl:if test="$next/form/orth = $orth-of-first-homograph">
      <xsl:text>&#xa;        </xsl:text>
      <hom>
	<xsl:text>&#xa;        </xsl:text>
	<xsl:apply-templates select="$next/*[name(.) != 'form']"/>
	<xsl:text>&#xa;        </xsl:text>
      </hom>
      <xsl:text>&#xa;        </xsl:text>

      <!-- Look forward recursively until we came across the first non-homograph

      eng-spa, 5910 entries

      Unrecursive:
      real    2m33.495s
      user    1m41.348s
      sys     0m0.431s

      Recursive:
      real    0m10.815s
      user    0m7.035s
      sys     0m0.388s

      -->
      <xsl:call-template name="recursive-following-homograps-into-hom">
	<xsl:with-param name="orth-of-first-homograph" select="$orth-of-first-homograph"/>
	<xsl:with-param name="current" select="$next"/>
      </xsl:call-template>

    </xsl:if>
  </xsl:template>

  <!-- if no other template matches, copy the encountered attributes and elements -->
  <xsl:template match='@* | node()'>
    <xsl:copy><xsl:apply-templates select='@* | node()'/></xsl:copy>
  </xsl:template>

</xsl:stylesheet>

