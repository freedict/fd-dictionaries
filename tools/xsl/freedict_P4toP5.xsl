<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  exclude-result-prefixes="xs xd">

  <xsl:import href="../../../../TEI/Stylesheets/profiles/default/p4/from.xsl"/>
<!--  <xsl:output method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>
-->
  <xd:doc type="stylesheet">
    <xd:short>Converter for FreeDict.org databases: from P4 to P5</xd:short>
    <xd:detail>
      <p>The input dictionaries vary in some details, so expect to tweak this script. In some cases
        the tweaks may be worth porting back to the project, in some cases you will probably judge
        them as specific to the dictionary at hand. In general, this is going to be a one-time
        script: it should do most of the conversion work for you, and you will be left with the remaining details,
        hopefully only within the header. Please make sure to indicate in the revisionDesc that
        conversion has taken place! And then check if the FreeDict build system converts your TEI source to c5 properly.</p>
      <p>It presupposes that your working copy of Freedict starts at (SVN/)freedict/trunk/ (you
        really don't need the other directories besides the trunk/) and that there is a copy of 
        <a href="http://tei.svn.sourceforge.net/viewvc/tei/trunk/Stylesheets/">Sebastian Rahtz's TEI
          Stylesheets</a> located in (SVN/)TEI/Stylesheets/ (this is only relevant for the xsl:import
        statement; but without that statement this script won't do its job).</p>
    </xd:detail>
    <xd:author>Piotr Bański</xd:author>
    <xd:copyright>the author(s), 2010; license: GPL v3 or any later version
      (http://www.gnu.org/licenses/gpl.html).</xd:copyright>
    <xd:svnId>$Id$</xd:svnId>
  </xd:doc>

  <xsl:template match="eg">
    <cit type="dicteg">
      <xsl:for-each select="q">
        <quote><xsl:apply-templates select="text()"/></quote>
      </xsl:for-each>
      <xsl:for-each select="trans">
        <xsl:apply-templates select="tr"/>
      </xsl:for-each>
    </cit>
  </xsl:template>

<xd:doc>Convert trans to as many (sense/)cit as there are tr elements inside it. If the original dictionary has no sense elements under entry, create them around each old trans.</xd:doc>
  <xsl:template match="trans">
    <xsl:choose>
      <xsl:when test="parent::eg"/>    <!-- die here, we'll pull you elsewhere -->
      <xsl:when test="parent::sense">
        <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
      </xsl:when>
      <xsl:otherwise>
        <sense>
          <xsl:if test="preceding-sibling::trans or following-sibling::trans">
            <xsl:attribute name="n"
              select="if (not(preceding-sibling::trans)) then 1 else count(preceding-sibling::trans)+1"
            />
          </xsl:if>
          <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </sense>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tr">
    <cit type="trans">
      <quote>
        <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
      </quote>
      <xsl:apply-templates mode="horiz" select="following-sibling::*[1][self::gen or self::pos]"/>
    </cit>
  </xsl:template>

  <xsl:template match="trans/gen | trans/pos"/>

<xd:doc>Convert gen elements *inside* trans. Be careful: this is a very specific case and you may have to tweak this template for your database (probably by removing the gramGrp layer)</xd:doc>
  <xsl:template match="trans/gen" mode="horiz">
    <gramGrp>
<!--      <pos>N</pos> this is fully recoverable -->
      <gen>
        <xsl:value-of select="."/>
      </gen>
    </gramGrp>
  </xsl:template>
  
  <xd:doc>Convert pos elements *inside* trans. Be careful: this is a very specific case and you may have to tweak this template for your database (possibly by removing the gramGrp layer; mind also the template for trans/gen - if more such elements occur in a trans, it might be better to group them in a more nifty way)</xd:doc>
  <xsl:template match="trans/pos" mode="horiz">
    <gramGrp>
      <pos>
        <xsl:value-of select="."/>
      </pos>
    </gramGrp>
  </xsl:template>
  
  
  <xsl:template match="revisionDesc">
    <xsl:variable name="date" select="format-dateTime(current-dateTime(), '[Y]-[M01]-[D01]')"
      as="xs:string"/>
    <revisionDesc>
      <change when="{$date}">
        <date><xsl:value-of select="$date"/></date>
        <name>YOUR_NAME_HERE</name>: Conversion of TEI P4 source into P5 via tools/xsl/freedict_P4toP5.xsl; manual clean-up.</change>
      <xsl:apply-templates
        select="@*|*|comment()|processing-instruction()"/>
    </revisionDesc>
  </xsl:template>
  
  <xsl:template match="pubPlace">
    <pubPlace><ref target="http://freedict.org/">http://freedict.org/</ref></pubPlace>
  </xsl:template>

  <xsl:template match="projectDesc">
    <projectDesc>
      <p>This dictionary comes to you through nice people making it available for free and for good. It is part of the FreeDict project, <ref
          target="http://freedict.org/">http://freedict.org/</ref>. This project aims to make translating dictionaries available for free. Your contributions are
        welcome!</p>
    </projectDesc>
  </xsl:template>

  <xsl:template match="titleStmt/respStmt">
    <respStmt >
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()"/>
    </respStmt>
    <respStmt>
      <xsl:comment>for the freedict database</xsl:comment>
      <resp>Maintainer</resp>
      <name>[up for grabs]</name>
    </respStmt>
  </xsl:template>

  <xsl:template match="publicationStmt">
    <publicationStmt>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()"/>
      <idno type="svn"><xsl:text>$Id</xsl:text><xsl:text>:$</xsl:text></idno>
    </publicationStmt>
  </xsl:template>

  <xsl:template match="publicationStmt/date"/>
  
  <xsl:template match="div0">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="availability">
    <availability status="free">
      <p>Copyright (C) 1999-2010 by various authors listed below.</p>
      <p>Available under the terms of the <ref target="http://www.gnu.org/licenses/gpl.html">GNU General Public License</ref> ver. 2.0 and any later version.</p>
      <p>This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
        Foundation; either version 2 of the License, or (at your option) any later version.</p>
      <p>This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
        PARTICULAR PURPOSE. See the GNU General Public License for more details.</p>
      <p>You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place
        - Suite 330, Boston, MA 02111-1307, USA.</p>
    </availability>
  </xsl:template>
  
  <!-- note: this one is introduced late, to handle some robust @resp attributes that I don't want hashed -->
  <xsl:template match="@resp">
    <xsl:attribute name="resp" select="translate(.,' []():;''','_')"/>
  </xsl:template>
  
    <xd:doc>eat the default or unnecessary attributes </xd:doc>
  <xsl:template match="note/@anchored[.='yes'] | entry/@type[.='main'] | orth/@extent[. = 'full'] | pron/@extent[. = 'full']"
  />

</xsl:stylesheet>