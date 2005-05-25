<?xml version='1.0' encoding='UTF-8'?>

<!--

  This stylesheet converts a TEI dictionary into the format expected by
  the `xerox' tool of libbedic from http://bedic.sf.net.
  The expected TEI input needs all homographs to be grouped in <hom>
  elements. The support for the bedic format 0.9.4 is complete.

  Limitations:

      * multiple <orth> elements are not supported
      * we cannot generate multi-line bedic properties with XSLT
        (maybe we should employ perl for this?)


  V0.1 Horst Eyermann 2002

	* This stylesheet was named tei2bedic.xsl, but not used
	  in favor of `tei2dic.py'.
	
	* A limitation of XML is that it cannot represent NUL characters
	  (NULL bytes). Even in XSLT/XPath no function to that end exists.
	  So this stylesheet was essentially worthless and `tei2dic.py' was
	  used to convert TEI files into the .dic format used by libbedic.


  V0.2 Michael Bunk 2005-May-25

	* The `xerox' tool of libbedic now supports an input format that uses
	  two newlines instead of the NUL bytes. This stylesheet is designed to
	  supersede `tei2dic.py'.

	  Note: It seems xerox doesn't support that double-newline format.
	        But some perl code can do that conversion easily. We should
		have done that from the beginning:
		
                perl -e '@ii=<>; $i=join "",@ii; $i=~s/\n\n/\x00/gm; \
		print $i' <input.newlines.dic >output.dic
 
        * The same limitation of XML/XSLT/XPath as above, ie. not being able
	  to represent ESC characters prevents us from generating multi-line
       	  properties.

  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates select="TEI.2/teiHeader"/>
    <xsl:apply-templates select="TEI.2/text/body/entry"/>
  </xsl:template>

  <xsl:variable name="version" select="0.2"/>

  <!-- Counter for commentXX. Has to be a global variable,
       so we can bind more frequently --> 
  <xsl:variable name="n" select="2"/>

  <xsl:template match="/TEI.2/teiHeader">
    <!-- Output required Properties -->
    <xsl:text>id=</xsl:text>
    <xsl:value-of select="substring-before(fileDesc/titleStmt/title, ' ')"/>
    <xsl:text>&#10;</xsl:text>

    <!-- The used char-precedence depends on the language of the dictionary -->
    <xsl:choose>
      <xsl:when test="starts-with(fileDesc/titleStmt/title, 'German')">
	<xsl:text>char-precedence={ -,!/.()?}{aAäÄ}{bB}{cC}{dD}{eE}{fF}{gG}{hH}{iI}{jJ}{kK}{lL}{mM}{nN}{oOöÖ}{pP}{qQ}{rR}{sSß}{tT}{uUüÜ}{vV}{wW}{xX}{yY}{zZ}&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<!-- The error message is wrong for 'Serbo-Croat', as that contains a '-' -->
	<xsl:message>Warning: No preset char-precedence for <xsl:value-of
	    select="substring-before(fileDesc/titleStmt/title, '-')"/> language.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:text>description=</xsl:text>
    <xsl:value-of select="fileDesc/titleStmt/title"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="fileDesc/editionStmt/edition"/>
    <xsl:text>&#10;</xsl:text>

    <xsl:text>maintainer=</xsl:text>
    <xsl:value-of select="fileDesc/titleStmt/respStmt/name[../resp='Maintainer']"/>
    <xsl:text>&#10;</xsl:text>
 
    <xsl:text>copyright=Publisher: </xsl:text>
    <xsl:value-of select="fileDesc/publicationStmt/publisher"/>
    <!-- To created bedic escaped newlines is not possible here,
         as ESC may not be represented in XML --> 
    <!--
    <xsl:text>&#27;n</xsl:text>
    -->
    <xsl:text> -- Year: </xsl:text>
    <xsl:value-of select="fileDesc/publicationStmt/date"/>
    <xsl:text> -- Place: </xsl:text>
    <xsl:value-of select="fileDesc/publicationStmt/pubPlace"/>
    <xsl:text> -- </xsl:text>
    <!-- replace newlines with spaces and normalize space -->
    <xsl:value-of select="normalize-space(translate(fileDesc/publicationStmt/availability, '&#10;', ' '))"/>
    <xsl:text>&#10;</xsl:text>

    <!-- Fill the commentXX properties with some additional information -->
    <xsl:text>comment00=Dictionary Source URL: </xsl:text>
    <xsl:value-of select="fileDesc/sourceDesc//xptr/@url"/>
    <xsl:text>&#10;</xsl:text>

    <xsl:text>comment01=XSLT processor used for TEI->bedic conversion: </xsl:text>
    <xsl:value-of select="system-property('xsl:vendor')"/>
    <xsl:text>&#10;</xsl:text>
    <xsl:text>comment02=Version of Stylesheet used for TEI->bedic conversion: </xsl:text>
    <xsl:value-of select="$version"/>
    <xsl:text>&#10;</xsl:text>
    
    <xsl:for-each select="fileDesc/notesStmt/note">
      <xsl:text>comment</xsl:text>
      <xsl:value-of select="format-number($n+position(), '00')"/>
      <xsl:text>=Note: </xsl:text>
      <xsl:value-of select="normalize-space(translate(.,'&#10;', ' '))"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
    <xsl:variable name="n" select="$n+count(fileDesc/notesStmt/note)"/>
    
    <!-- Changelog -->
    <xsl:for-each select="revisionDesc/change">
      <xsl:text>comment</xsl:text>
      <xsl:value-of select="format-number($n + position(), '00')"/>
      <xsl:text>=ChangLog: </xsl:text>
      <xsl:value-of select="date"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="respStmt/name"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="normalize-space(translate(item,'&#10;', ' '))"/>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
   
    <!-- End Mark of Header Section -->
    <xsl:text>&#10;&#10;</xsl:text>
  </xsl:template>

  <!-- Templates to transform entries -->
  <xsl:template match="entry">
    <!-- Headword -->
    <xsl:choose>
      <xsl:when test="normalize-space(form/orth)=''">
	<xsl:message>Warning: Skipping entry without or with empty orth element(s).</xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:if test="count(form/orth)>1">
	  <xsl:message>Warning: Ignoring additional orth elements in entry '<xsl:value-of
	      select="form/orth"/><xsl:text>'.</xsl:text>
	  </xsl:message>
	</xsl:if>
	<xsl:value-of select="form/orth[1]"/>
	<xsl:text>&#10;</xsl:text>

	<xsl:apply-templates select="hom"/>

	<!-- for entries without grouped senses (old-style FreeDict)
	     as well as entries without <hom> --> 
        <xsl:if test="count(gramGrp | sense | trans | def | eg | xr | note)>0">
	  <xsl:call-template name="format-homograph">
	    <xsl:with-param name="input" select="form | gramGrp | sense | trans | def | eg | xr | note"/>
	  </xsl:call-template>
	</xsl:if>

	<!-- End Mark of entry -->
	<xsl:text>&#10;&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="hom">
    <xsl:call-template name="format-homograph">
      <xsl:with-param name="input" select="*"/>
    </xsl:call-template>
  </xsl:template>

  <!-- The parameter 'input' contains all child nodes
       to be formatted like inside a <hom> element -->
  <xsl:template name="format-homograph">
    <xsl:param name="input" select="*"/>
    <xsl:choose>
      <xsl:when test="1>count($input)">
	<xsl:message>Stylesheet assertion failed: Template 'format-homograph' called without input</xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>{s}</xsl:text>
	<xsl:apply-templates select="$input[name()='gramGrp']"/>
    
	<xsl:apply-templates select="$input/pron"/>

	<!-- for entries with grouped senses -->
	<xsl:apply-templates select="$input[name()='sense']"/>

	<!-- for entries without grouped senses (old-style FreeDict) -->
	<xsl:call-template name="format-sense">
	  <xsl:with-param name="input" select="$input[name()='trans' or name()='def' or name()='eg' or name()='xr' or name()='note']"/>
	</xsl:call-template>

	<xsl:text>{/s}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="gramGrp">
    <xsl:text>{ps}</xsl:text>
    <xsl:value-of select="pos"/>
    <xsl:if test="gen">
      <xsl:text> </xsl:text>
      <xsl:value-of select="gen"/>
    </xsl:if>
    <xsl:if test="num">
      <xsl:text> </xsl:text>
      <xsl:value-of select="num"/>
    </xsl:if>
    <xsl:text>{/ps}</xsl:text>
  </xsl:template>

  <xsl:template match="pron">
    <xsl:text>{pr}</xsl:text><xsl:apply-templates/><xsl:text>{/pr}</xsl:text>
  </xsl:template>
 
  <xsl:template match="sense">
    <xsl:call-template name="format-sense">
      <xsl:with-param name="input" select="*"/>
    </xsl:call-template>
  </xsl:template>

  <!-- The parameter 'input' contains all child nodes
       to be formatted like inside a <sense> element -->
  <xsl:template name="format-sense">
    <xsl:param name="input" select="*"/>
    <xsl:if test="$input[name()='usg' or name()='trans' or name()='def' or name()='eg' or name()='xr' or name()='note']">
      <xsl:text>{ss}</xsl:text>
      
      <xsl:apply-templates select="$input[name()='usg']"/>
      
      <xsl:apply-templates select="$input[name()='trans' or name()='def']"/>
      
      <xsl:apply-templates select="$input[name()='note']"/>
      
      <xsl:if test="$input[name()='eg']">
	<xsl:text> -- </xsl:text>
        <xsl:apply-templates select="$input[name()='eg']"/>
      </xsl:if>
    
      <xsl:if test="count($input[name()='xr'])>0">
	<xsl:text> -- See also: </xsl:text>
	<xsl:for-each select="$input[name()='xr']">
	  <xsl:apply-templates select="."/>
	  <xsl:if test="position()!=last()">
	    <xsl:text>, </xsl:text>
	  </xsl:if>
	</xsl:for-each>
      </xsl:if>
      
      <xsl:text>{/ss}</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="usg[@type='dom']">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>] </xsl:text>
  </xsl:template>

  <xsl:template match="trans">
    <xsl:value-of select="tr"/>
    <!-- the gender of nouns in the destination language might be of interest
         (not in English, but in German, French etc.) -->
    <xsl:if test="gen"> (<xsl:value-of select="gen"/>)</xsl:if>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="def">
    <xsl:value-of select="normalize-space(translate(., '&#10;', ' '))"/>
  </xsl:template>

  <xsl:template match="note">
    <!-- we don't want the timestamp of the last translator to appear
         I don't know why we have to use string(). I only know that
	 without it, the test evaluates to true. -->
    <xsl:if test="string(@resp) != 'translator'">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="normalize-space(translate(., '&#10;', ' '))"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="eg">
    <xsl:text>{ex}"</xsl:text>
    <xsl:choose>
      <xsl:when test="contains(q,ancestor::entry/form/orth[1])">
	<!-- substitute headword in example by {hw/}
	     goes wrong if
		* headword is capitalized eg. because it
                  starts the example
	        * headword is very short and is contained in
	 	  other words eg. 'and' is contained in 'hand'
	  -->
	<xsl:value-of select="substring-before(q,ancestor::entry/form/orth[1])"/>
	<xsl:text>{hw/}</xsl:text>
	<xsl:value-of select="substring-after(q,ancestor::entry/form/orth[1])"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="q"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>"</xsl:text>
    
    <xsl:if test="trans">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="trans/tr"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:text>{/ex}</xsl:text>
  </xsl:template>

  <xsl:template match="xr">
    <xsl:text>{sa}</xsl:text>
    <xsl:value-of select="ref"/>
    <xsl:text>{/sa}</xsl:text>
  </xsl:template>
    
</xsl:stylesheet>

