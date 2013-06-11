<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc">

  <xsl:import href="indent.xsl"/>

  <!-- Width of display, so indendation can be done nicely -->
  <xsl:param name="width" select="75"/>
  <!-- Has to come from the shell, as XSLT/XPath 1.0 provide no
  function to get current time/date -->
  <xsl:param name="current-date"/>
  <xsl:variable name="stylesheet-header_svnid">$Id: teiheader2txt.xsl 1095 2011-01-06 14:57:17Z bansp$</xsl:variable>

  <!-- Using this stylesheet with Sablotron requires a version >=0.95,
  because xsl:strip-space was implemented from that version on -->
  <!--<xsl:strip-space elements="teiHeader fileDesc titleStmt respStmt editionStmt publicationStmt seriesStmt notesStmt revisionDesc TEI.2 TEI p sourceDesc availability encodingDesc"/>-->
  <xsl:strip-space elements="*"/>

  <!-- the addition of P5 stuff relies on the absolute complementarity between
    null-spaced elements (P4) and elements in the TEI namespace (P5) -->

  <!-- For transforming the teiHeader -->

  <xsl:template match="tei:titleStmt">
    <xsl:value-of select="tei:title"/>
    <xsl:text>&#xa;&#xa;</xsl:text>
    <xsl:for-each select="tei:respStmt">
      <xsl:value-of select="tei:resp"/>: <xsl:value-of select="tei:name"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <!-- editionStmt consists of <edition/> followed by (respStmt)* -->
  <xsl:template match="tei:editionStmt">
    <xsl:text>Edition: </xsl:text>
    <xsl:apply-templates select="tei:edition"/>
    <xsl:text>&#xa;</xsl:text>

    <xsl:if test="tei:respStmt">
      <xsl:for-each select="tei:respStmt">
        <xsl:call-template name="format">
          <xsl:with-param name="txt" select="normalize-space(concat(tei:name, ': ', tei:resp))"/>
          <xsl:with-param name="width" select="$width"/>
          <xsl:with-param name="start" select="string-length(tei:name) + 3"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:extent">
    <xsl:text>Size: </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xd:doc>I understand this is needed for cases where we merely redistribute stuff.</xd:doc>
  <xsl:template match="tei:publisher">
    <xsl:value-of select="concat('Publisher: ',.,'.&#xa;')"/>
  </xsl:template>
  
  <xd:doc>For upstream publishers, I guess.</xd:doc>
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:value-of select="concat('Publication date: ',.,'.&#xa;')"/>
  </xsl:template>

  <xd:doc>Shouldn't this always be the FreeDict URL?</xd:doc>
  <xsl:template match="tei:pubPlace">
    <xsl:value-of select="concat('Published at: ',tei:ref,'&#xa;')"/>
  </xsl:template>

  <xd:doc>Id #, currently we only use the SVN Id.</xd:doc>
  <xsl:template match="tei:idno">
    <xsl:value-of select="concat('ID# (',@type,'): ',.,'&#xa;')"/>
  </xsl:template>


  <xsl:template match="tei:availability">
    <xsl:variable name="spaced_ps">
      <xsl:for-each select="tei:p">
        <xsl:value-of select="concat(.,' ')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>&#xa;&#xa;Availability:&#xa;&#xa;  </xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space($spaced_ps)"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="2"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:publicationStmt">
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:seriesStmt">
    <xsl:text>Series: </xsl:text>
    <xsl:value-of select="tei:title"/>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:notesStmt">
    <xsl:text>Notes:&#xa;&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:teiHeader//tei:note">
    <xsl:text> * </xsl:text>
    <xsl:if test="@type and (@type = 'status')">
      <xsl:text>Database Status: </xsl:text>
    </xsl:if>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space()"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="3"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:sourceDesc">
    <xsl:text>Source(s):&#xa;&#xa;  </xsl:text>
    <xsl:variable name="sdtext">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space($sdtext)"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="2"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:p">
    <xsl:text>  </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:ptr">
    <xsl:value-of select="@target"/>
  </xsl:template>

  <xsl:template match="tei:projectDesc">
    <xsl:text>The Project:&#xa;&#xa;  </xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space()"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="2"/>
    </xsl:call-template>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:revisionDesc">
    <xsl:text>Changelog:&#xa;&#xa;</xsl:text>
    <xsl:if test="string-length($current-date)>0">
      <!-- Add conversion timestamp -->
      <xsl:text> * </xsl:text>
      <xsl:value-of select="$current-date"/>
      <xsl:text>: Conversion of the TEI source file into c5 format.</xsl:text>
      <xsl:text>&#xa;   Stylesheet ID: </xsl:text>
      <xsl:value-of select="$stylesheet-header_svnid"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:change">
    <xsl:variable name="when">
      <xsl:choose>
        <xsl:when test="tei:date">
          <xsl:value-of select="tei:date"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@when"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="who">
      <xsl:choose>
        <xsl:when test="tei:name">
          <xsl:value-of select="tei:name[1]"/>
        </xsl:when>
        <xsl:when test="@who">
          <xsl:variable name="who-attr" select="@who"/>
          <xsl:variable name="name-elem"
            select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt/tei:name[@xml:id = substring-after($who-attr,'#')]"/>
          <xsl:choose>
            <xsl:when test="$name-elem">
              <xsl:value-of select="$name-elem"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$who-attr"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat(' * ',$when,' ',$who)"/>

    <!-- this is for the version information -->
    <xsl:if test="@n">
      <xsl:text> </xsl:text>
      <xsl:value-of select="concat('ver. ',@n)"/>
    </xsl:if>
    <xsl:text>:&#xa;</xsl:text>
    <xsl:apply-templates mode="changelog"/>

  </xsl:template>

  <!-- we pull these in separately -->
  <xsl:template mode="changelog" match="tei:*[1][local-name() = 'date']"/>
  <xsl:template mode="changelog" match="tei:name[1]"/>

  <xsl:template mode="changelog" match="text()[string-length(normalize-space()) > 0]">
    <xsl:variable name="stuff">
      <xsl:choose>
        <xsl:when test="substring(.,1,2)=': '">
          <xsl:value-of select="substring-after(.,': ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="concat('   ',normalize-space($stuff))"/>
      <xsl:with-param name="width" select="$width"/>
      <xsl:with-param name="start" select="3"/>
    </xsl:call-template>
  </xsl:template>

  <!-- this is a horribly unreadable template that should definitely be rewritten -->
<!-- if the <change> element has all three attrs: @n, @who and @when set, do not process <head> -->
  <xsl:template match="tei:list" mode="changelog">
    <xsl:variable name="indent" select="count(ancestor-or-self::tei:list)*3"/>
    <xsl:if test="tei:head and not(string-length(ancestor::tei:change[1]/@n) &gt; 0 and
                                  string-length(ancestor::tei:change[1]/@who) &gt; 0 and
                                  string-length(ancestor::tei:change[1]/@when) &gt; 0)">
      <xsl:call-template name="format">
        <xsl:with-param name="txt" select="concat('   ',normalize-space(tei:head))"/>
        <xsl:with-param name="width" select="$width"/>
        <xsl:with-param name="start" select="$indent"/>
      </xsl:call-template>
      <!--<xsl:text>&#xa;</xsl:text>-->
    </xsl:if>
    <xsl:for-each select="tei:item">
      <xsl:variable name="item-content">
        <xsl:choose>
          <xsl:when test="tei:list">
            <xsl:apply-templates select="tei:list/preceding-sibling::tei:*|text()"/>
            <!-- this is obviously a kludge: I assume that a nested <list/> is always the last element in an <item/> -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="tei:*|text()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="format">
        <xsl:with-param name="txt"
          select="concat(substring('                   ', 1, $indent),'* ',normalize-space($item-content))"/>
        <xsl:with-param name="width" select="$width"/>
        <xsl:with-param name="start" select="$indent+2"/>
      </xsl:call-template>
      <!--<xsl:text>&#xa;</xsl:text>-->
      <xsl:if test="tei:list">
        <xsl:apply-templates select="tei:list"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
