<?xml version='1.0' encoding='UTF-8'?>

<!--

  This stylesheet converts a TEI dictionary into the format expected by
  the `xerox' tool of libbedic from http://bedic.sf.net.
  The expected TEI input needs all homographs grouped in <hom>
  elements. The support for the bedic format 0.9.6 is complete.

  For an overview of the context where this stylesheet is used see the
  FreeDict HOWTO.

  Limitations:

      * multiple <orth> elements are not supported

      * cross references are typeless and contain the english language
        specific "see also" instead of "synonyms:", "antonym(s):" etc.
        (typing could be added easily)

      *	 We don't have an escaping mechanism for literal backslashes.


  V0.1 Horst Eyermann 2002

	* This stylesheet was named tei2bedic.xsl, but not used
	  in favor of `tei2dic.py'.

	* A limitation of XML is that it cannot represent NUL characters
	  (NULL bytes). Even in XSLT/XPath no function to that end exists.
	  So this stylesheet was essentially worthless and `tei2dic.py' was
	  used to convert TEI files into the .dic format used by libbedic.


  V0.2 Michael Bunk 2005-May-25

	* This stylesheet is designed to supersede `tei2dic.py'.

	* The output of has to be filtered by small perl
          script. We should have done that from V0.1:

	  perl -pi -e 's/\\0/\x00/gm; s/\\e/\e/gm;' <input.escapes >output.dic

          Due to the limitation of XML 1.0 not to be able to represent NUL and
	  ESC characters and due to XSLT/XPath/EXSLT providing no function
	  to output them, the perl code has to do the following translations
	  (XML 1.1 allows ESC. But then xsltproc using libxml 20510
	  doesn't support XML 1.1 yet):

	  <\><0> -> <NUL>
	  <\><e> -> <ESC>

  V0.3 Michael Bunk 2005-Jun-18

        * <trans> elements with multiple <tr> children are handled now,
	  even though their usage is usually not in compliance with the
	  TEI Guidelines.

	* Skipping of malformed entries that consist only of the headword,
	  ie. that have only a single child and that is <form>.

  V0.4 Michael Bunk 2005-Jul-03

        * TEI <usg type="dom"> (domain) will be translated into
          bedic {ct} (category).

        * In case no char-precedence exists for a language, the
	  Wikipedia-char-precedence coming with libbedic 0.9.6
	  is used, modified by having the non-accented lowercase
	  characters in their own equivalence classes preceding
	  the uppercase characters. Another modification is that
	  some characters 81-9f were removed.

  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates select="TEI.2/teiHeader"/>
    <xsl:apply-templates select="TEI.2/text/body/entry"/>
  </xsl:template>

  <xsl:variable name="version" select="0.4"/>

  <xsl:template name="new-line">
    <!-- To directly create bedic escaped newlines is not possible here,
         as ESC may not be represented in XML 1.0:
	 <xsl:text>&#27;n</xsl:text>

	 So we output "\en". The "\e" will have to be transformed
	 into a real ESC char, eg. by a perl script. Then <ESC><n>
         will be a correctly encoded newline in the bedic format.

	 To be complete, we should have an escaping mechanism for
	 literal backslashes in place. But we do not.
    -->
    <xsl:text>\en</xsl:text>
  </xsl:template>

  <!-- Counter for commentXX. Has to be a global variable,
       so we can bind more frequently -->
  <xsl:variable name="n" select="2"/>

  <xsl:template match="/TEI.2/teiHeader">
    <!-- Output required Properties -->
    <xsl:text>id=</xsl:text>
    <xsl:value-of select="substring-before(fileDesc/titleStmt/title, ' ')"/>
    <xsl:text>&#10;</xsl:text>

    <!-- The used char-precedence depends on the language of the dictionary -->
    <xsl:text>char-precedence=</xsl:text>
    <xsl:choose>
      <xsl:when test="starts-with(fileDesc/titleStmt/title, 'German')">
	<xsl:text>{ -,!/.()?}{a}{AäÄ}{b}{B}{c}{C}</xsl:text>
	<xsl:text>{d}{D}{e}{E}{f}{F}{g}{G}{h}{H}{i}{I}{j}{J}{k}{K}</xsl:text>
        <xsl:text>{l}{L}{m}{M}{n}{N}{o}{OöÖ}{p}{P}{q}{Q}{r}{R}{s}{Sß}</xsl:text>
	<xsl:text>{t}{T}{u}{UüÜ}{v}{V}{w}{W}{x}{X}{y}{Y}{z}{Z}&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<!-- The warning is wrong for 'Serbo-Croat', as that contains a '-' -->
	<xsl:message>Warning: No preset char-precedence for <xsl:value-of
	    select="substring-before(fileDesc/titleStmt/title, '-')"/> language.
	 Using modified Wikipedia char-precedence.</xsl:message>
	<xsl:text>{a}{AäâàáåãæÀÁÂÃÄÅÆ}{b}{B}{c}{CçÇ}{d}{DðÐ}{e}{EèéêëÈÉÊ}</xsl:text>
	<xsl:text>{f}{F}{g}{G}{hH}{i}{IíîìïÍÎ}{j}{J}{k}{K}{l}{L£}{m}{Mµ}</xsl:text>
	<xsl:text>{n}{NñÑ}{o}{OôøòõóöÓÔÕÖ}{p}{P}{q}{Q}{r}{R}{s}{Sß}{t}{T}</xsl:text>
	<xsl:text>{u}{UüùúûÙÚÜ}{v}{V}{w}{W}{x}{X}{y}{Yýÿ}{z}{Z}0123456789</xsl:text>
	<xsl:text>-,;:!?/.`~'()}@$*\&amp;%=×ØÞ­´¸§°·²½±¡³ºª»«þ¼¿</xsl:text>
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
    <xsl:text> Year: </xsl:text>
    <xsl:value-of select="fileDesc/publicationStmt/date"/>
    <xsl:text> Place: </xsl:text>
    <xsl:value-of select="fileDesc/publicationStmt/pubPlace"/>
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
    <xsl:text>comment02=Stylesheet used for TEI->bedic conversion: V</xsl:text>
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

    <!-- End Mark of Header Section. This \0 has to be translated into
         NUL by a perl one-liner. -->
    <xsl:text>\0</xsl:text>
  </xsl:template>

  <!-- Templates to transform entries -->
  <xsl:template match="entry">
    <!-- Headword -->
    <xsl:choose>
      <xsl:when test="normalize-space(form/orth)=''">
	<xsl:message>Warning: Skipping entry without or with empty orth element(s).</xsl:message>
      </xsl:when>
      <xsl:when test="1 > count(*[name() != 'form'])">
	<xsl:message>Warning: Skipping entry with only form child(ren). form contents: '<xsl:value-of select='form'/>'</xsl:message>
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
	<xsl:text>\0</xsl:text>
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
    <xsl:text>{ct}</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>.{/ct} </xsl:text>
  </xsl:template>

  <xsl:template match="trans">
    <!-- We have to handle multiple <tr> inside trans, because the old
         style encoded TEI files have this. Actually <trans> is meant only
	   to group information related to a single translation eqivalent,
	   while each translation equivalent should reside inside its own
	   <trans>.
    -->
    <xsl:for-each select="tr">
      <xsl:value-of select="."/>
      <xsl:if test="not(position()=last())">, </xsl:if>
    </xsl:for-each>

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

