<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.pnp-software.com/XSLTdoc" exclude-result-prefixes="tei xd">

  <xd:doc type="stylesheet">
    <xd:short>Stylesheet for quick dictionary visualisation.</xd:short>
    <xd:detail>
      <p>This is an XSLT 1.0 stylesheet that gets triggered when a dictionary is viewed in a web
        browser. It may be used for smaller dictionaries as a quick configurable working view, an
        alternative to the static CSS view. The way to trigger this is by putting <blockquote>
          <code><?xml-stylesheet type="text/xsl" href="freedict-dictionary.xsl"?></code>
        </blockquote>
        at the top of the file.</p>
        
        <p>Note: different browsers will behave differently, Firefox and newer IE should work well.</p>
      <p>This initial version is extremely simple, not to say simplistic: it was whipped up in few
        minutes for the purpose of teaching FreeDict and XML to students at the University of
        Warsaw. Corrections/extensions are welcome. The way it was written is due to the fact that
        it served as basis for introducing XSLT. The comments will be internationalized at some point, perhaps.</p>
      <p>Distributor: FreeDict.org (<a href="http://freedict.org/">http://freedict.org/</a>)</p>      
    </xd:detail>
    <xd:author>Piotr Bański</xd:author>
    <xd:copyright>the author(s), 2010; license: GPL v3 or any later version (http://www.gnu.org/licenses/gpl.html).</xd:copyright>
    <xd:svnId>$Id:$</xd:svnId>
  </xd:doc>

 <xsl:output encoding="UTF-8" method="html" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
    doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>

  <xsl:template match="/">
    <xsl:apply-templates select="tei:TEI/tei:text"/>
  </xsl:template>

  <xsl:template match="tei:text">
    <html>
      <head>
        <title>
          <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
        </title>
      </head>
      <body>
        <!-- wstaw tekst znajdujący się w miejscu wskazanym przez XPath -->
        <h1>
          <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
        </h1>
        <xsl:apply-templates select="tei:body"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="tei:body">
    <table cellspacing="5" cellpadding="2" border="1">
      <thead>
        <tr style="font-weight: bold">
<!--          <td>Hasło</td>
          <td>Inf. gram.</td>
          <td>Odpowiednik(i)</td>-->
          <td>Headword</td>
          <td>Properties</td>
          <td>Equivalents</td>
        </tr>
      </thead>
      <xsl:apply-templates select="tei:entry"/>
      <!-- zastosuj szablony do elementów tei:entry (o ile takie szablony znajdziesz) -->
    </table>
  </xsl:template>

  <xsl:template match="tei:entry">
    <tr style="margin-top: 1em" valign="middle">
      <td style="font-weight: bold">
        <xsl:for-each select="tei:form/tei:orth">
          <xsl:value-of select="."/>
          <br/>          
        </xsl:for-each>

      </td>
      <td style="font-weight: bold; color: blue;">
        <xsl:apply-templates select="tei:gramGrp"/> <!-- pierwsze wywołanie gramGrp -->  
      </td>
      <td>
        <xsl:for-each select="tei:sense">

          <xsl:for-each select="tei:cit">
              <xsl:value-of select="tei:quote[1]"/> <!-- tak naprawdę to może być kilka <quote> wewnątrz <cit>, ale to zignorujemy i poprosimy tylko o pierwszy z nich, za pomocą predykatu [1] -->
            <xsl:if test="tei:gramGrp"><span style="color:green"> (<xsl:apply-templates select="tei:gramGrp"/>)</span></xsl:if>
            <!-- drugie wywołanie gramGrp, tym razem jest to opis ekwiwalentu -->
              <br/>
              <!-- nowa linia -->
          </xsl:for-each>

        </xsl:for-each>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="tei:gramGrp">
<!-- stwórz ciąg wartości zawartych wewnątrz gramGrp -->
    <!-- w tym miejscu zacząłem bardzo żałować, że nie piszę arkusza XSLT 2.0, 
      ale przeglądarki rozumieją jedynie XSLT 1.0, niestety -->
    <xsl:for-each select="tei:*">
      <xsl:value-of select="."/> <!-- wypluj wartość tekstową obecnego elementu -->
      <xsl:if test="following-sibling::tei:*">, </xsl:if>
      <!-- jeśli jest za nami jakiś element, wydrukuj ", " -->
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>