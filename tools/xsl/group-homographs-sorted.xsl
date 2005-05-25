<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--

  $Revision: 1.1 $

  This stylesheet converts a TEI dictionary where homographs are not
  necessarily grouped with <hom> elements into a TEI file, where this
  grouping exists. Grouped homographs are required for conversion to
  bedic format, where multiple headwords that are equal are not allowed.

  Grouping is done with the <hom> element and not the <superEntry> element,
  so the structure could be translated more directly into the bedic format
  by the SAX event handlers in `tei2dic.py'.

  This variant employs expects the entries sorted in any order as long as
  entries where the first orth elements compare equal, are next to each
  other. The <xsl:sort> element can be used for that (see `sort.xsl').
  By processing a sorted dictionary we are trying to be faster by not
  having to look more than one entry backward for homographs.
  This variant is worlds faster than the variant without sorting.

  <gramGrp> elements become children of the respective <hom> elements.  

  Limitations:

    * entries with multiple <orth> elements are not supported
    * <pron> elements of all but the first homograph are discarded
    * What happens to preexistent <hom> elements?

  -->

  <!--
  
  Using the doctype-public and doctype-system attributes here is in vain,
  since TEI needs an internal subset to include optional portions of the
  TEI DTD
  
   -->
  <xsl:output method="xml" encoding="UTF-8"/>
  
  <!--
 
  Since XSL provides no way of outputting an internal DTD subset, we use
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
        
    <xsl:choose>

      <!--
      
      If an entry has a preceding homograph, skip it,
      as it has already been processed. In this place, since
      the entry node list is sorted, it is enough to check
      just the first preceding entry.
      
      We use the preceding/following-sibling axises here.d
      Note that they refer to the entries of the document in
      document order. If we did the sorting in this stylesheet,
      we would require a means to refer to the sorted list.
      We would have to refer to the preceding/following nodes in the
      context node list. Unfortunately, there are no such things
      as context node list axises or a function to access the
      context node list.

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

        <!--
    
        For a huge dictionary, the following is very inefficient.
        But I didn't see another way to do it in XSLT. Actually,
        it would be enough to look forward until we came across
        the first non-homograph.

        XXX Maybe there is a solution involving recursivity?

        -->
        <xsl:variable name="myfollowing" select="following-sibling::entry"/>
        <xsl:variable name="myfollowinghomographs" select="$myfollowing[form/orth = $myorth]"/>
      
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
	    <xsl:message terminate="no">
	      <xsl:text>Warning: Can't handle multiple &lt;orth> elements: </xsl:text>
	      <xsl:for-each select="$myorth">
		'<xsl:value-of select="."/>'<xsl:text> </xsl:text>
	      </xsl:for-each>- Results undefined. They should be separated into their own entries.
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
      </xsl:otherwise>


    </xsl:choose>
  </xsl:template>

  <!-- if no other template matches, copy the encountered attributes and elements -->
  <xsl:template match='@* | node()'>                                              
    <xsl:copy><xsl:apply-templates select='@* | node()'/></xsl:copy>                
  </xsl:template>

</xsl:stylesheet>
