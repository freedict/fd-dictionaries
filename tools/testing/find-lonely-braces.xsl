<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!--

  $Revision$

  This stylesheet looks for orth, pron, tr, note and p elements from a TEI XML
  dictionary, which have an opening or closing brace without a matching closing
  or opening counterpart.

  It can thus identify some entries which were imported incorrectly from another data
  format. It is similar to the sanity check "unbalanced braces" in FreeDict-Editor,
  but not as comprehensive, since it does not check the correct nesting of different
  brace types. But this disadvantage might be of theoretic nature only.

  Since xsltproc and Sablotron don't support xmlns:regexp, we can't just use
  regular expressions here. We could try to use ECMA-Script with
  Sablotron, since that language includes regexp support.

  But on the other hand, with much effort the checking can be done with
  substring-before() / substring-after() in plain XSLT/XPath.

  Please keep in mind that all kinds of braces should be avoided in TEI XML
  dictionaries.  Usually their use is a sign of inappropriate data encoding.

  The output of this stylesheet should be a valid TEI XML file.

  Michael Bunk, Aug 2005

  -->

  <!-- BTW, xsltproc compiled against libxml 20510, libxslt 10032 and libexslt 721
  does not honour the 'indent' attribute (or my strip/preserve-space understanding lacks
  something. But Sablotron 1.02 _does_ indentation! -->
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:strip-space elements="body entry form gramGrp sense trans"/>
  
  <xsl:param name="verbose" select="false()"/>

  <!-- Generate a FreeDict standard TEI DOCTYPE declaration -->
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE TEI.2
  PUBLIC "-//TEI P4//DTD Main DTD Driver File//EN"
  "http://www.tei-c.org/P4X/DTD/tei2.dtd" [
&lt;!ENTITY % TEI.XML          "INCLUDE" >
&lt;!ENTITY % TEI.dictionaries "INCLUDE" > 
&lt;!ENTITY % TEI.linking      "INCLUDE" >
&lt;!ATTLIST xptr url CDATA #IMPLIED >
&lt;!ATTLIST xref url CDATA #IMPLIED >
]>
</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="entry">
    <xsl:if test="(position() mod 50) = 0">
      <xsl:message>Processed <xsl:value-of select="position()"/></xsl:message>
    </xsl:if>
    <!-- This is like a function call -->
    <xsl:variable name="lonely">
      <xsl:call-template name="check-lonely-nodeset">
        <xsl:with-param name="nodes" select=".//orth | .//pron | .//tr | .//note | .//p"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:if test="$verbose">
      <xsl:message>check-lonely-nodeset returned <xsl:value-of select="$lonely"/>.
      </xsl:message>
    </xsl:if>

    <!-- If there are lonely braces, copy this entry for output -->
    <xsl:if test="$lonely='true'">
      <entry>
	<xsl:apply-templates select="@* | *"/>
      </entry>
    </xsl:if>
  </xsl:template>	    

  <!-- This template is a function returning true() or false(), converted into
  a string. It handles all nodes of a nodeset sequentially. -->
  <xsl:template name="check-lonely-nodeset">
    <xsl:param name="nodes"/>

    <xsl:choose>
      <!-- We can't count($nodes) when $nodes is an empty nodeset -->
      <xsl:when test="$nodes = ''">false</xsl:when>
      <xsl:otherwise>
	<xsl:variable name="n" select="count($nodes)"/>

        <xsl:if test="$verbose">
	  <xsl:message> check-lonely-nodeset with <xsl:value-of select="$n"/> nodes called.</xsl:message>
	</xsl:if>  
	<xsl:choose>
	  <!-- Recursively process more than 2 nodes -->
	  <xsl:when test="$n>=2">
	    <!-- Check first node, the variable contains either the string 'true'
	    or the string 'false' -->
	    <xsl:variable name="node1-lonely">
	      <xsl:call-template name="check-lonely-node">
		<xsl:with-param name="node" select="$nodes[1]"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <!-- Check second node -->
	    <xsl:variable name="node2-lonely">
	      <xsl:call-template name="check-lonely-node">
		<xsl:with-param name="node" select="$nodes[2]"/>
	      </xsl:call-template>
	    </xsl:variable>
	    <!-- Turn strings into booleans and 'or' them -->
	    <xsl:variable name="ored" select="$node1-lonely='true' or $node2-lonely='true'"/>
	    <xsl:choose>
	      <!-- When one of them is lonely, no need to do recursion -->
	      <xsl:when test="$ored">true</xsl:when>
	      <xsl:otherwise>
		<!-- Do recursion -->
		<xsl:call-template name="check-lonely-nodeset">
		  <xsl:with-param name="nodes" select="$nodes[position()>2]"/>
		</xsl:call-template>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <!-- Base case: Only one node to process -->
	  <xsl:otherwise>
	    <xsl:call-template name="check-lonely-node">
	      <xsl:with-param name="node" select="$nodes[1]"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This template is a function taking a string in $node as argument
  returning 'true' if a lonely brace is seen or 'false' otherwise.  Templates
  can only return strings (and result tree fragments), watch out!  It checks
  the string value of $node for lonelinesses of different brace types. -->
  <xsl:template name="check-lonely-node">
    <xsl:param name="node"/>

    <xsl:variable name="type1result">
      <xsl:call-template name="check-lonely-node-for-bracetype">
        <xsl:with-param name="node" select="$node"/>
	<xsl:with-param name="co" select="'('"/>
	<xsl:with-param name="cc" select="')'"/>
      </xsl:call-template> 
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$type1result = 'true'">true</xsl:when>
      <xsl:otherwise>
	<xsl:variable name="type2result">
	  <xsl:call-template name="check-lonely-node-for-bracetype">
            <xsl:with-param name="node" select="$node"/>
	    <xsl:with-param name="co" select="'{'"/>
	    <xsl:with-param name="cc" select="'}'"/>
	  </xsl:call-template> 
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="$type2result = 'true'">true</xsl:when>
	  <xsl:otherwise>
	    <xsl:variable name="type3result">
	      <xsl:call-template name="check-lonely-node-for-bracetype">
                <xsl:with-param name="node" select="$node"/>
		<xsl:with-param name="co" select="'['"/>
		<xsl:with-param name="cc" select="']'"/>
	      </xsl:call-template> 
	    </xsl:variable>
	    <xsl:choose>
	      <xsl:when test="$type3result = 'true'">true</xsl:when>
	      <xsl:otherwise>
		<xsl:variable name="type4result">
		  <xsl:call-template name="check-lonely-node-for-bracetype">
	            <xsl:with-param name="node" select="$node"/>
	            <xsl:with-param name="co" select="'&lt;'"/>
		    <xsl:with-param name="cc" select="'>'"/>
		  </xsl:call-template> 
		</xsl:variable>
		<xsl:choose>
		  <xsl:when test="$type4result = 'true'">true</xsl:when>
		  <xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This template is a function taking a string in $node as argument
  returning 'true' if a lonely brace is seen and 'false' otherwise. -->
  <xsl:template name="check-lonely-node-for-bracetype">
    <xsl:param name="node"/>
    <xsl:param name="open-braces" select="0"/>
    <!-- The charactes that should be treated as corresponding opening/closing
    braces -->
    <xsl:param name="co" select="'('"/>
    <xsl:param name="cc" select="')'"/>
    
    <xsl:if test="$verbose">
      <xsl:message>  check-lonely-node-for-bracetype with node='<xsl:value-of select="$node"/>' and
        open-braces=<xsl:value-of select="$open-braces"/> char-open='<xsl:value-of select="$co"/>' called.</xsl:message>
    </xsl:if>
    <xsl:variable name="pos-opening-brace" select="string-length(substring-before($node, $co))"/>
    <xsl:variable name="pos-closing-brace" select="string-length(substring-before($node, $cc))"/>
    <xsl:choose>
      <!-- There are no braces -->
      <xsl:when test="not(contains($node, $co)) and not(contains($node, $cc))">false</xsl:when>
      <!-- Only a closing brace -->
      <xsl:when test="not(contains($node, $co))">
	<xsl:choose>
	  <!-- No corresponding opening brace seen -->
	  <xsl:when test="$open-braces = 0">true</xsl:when>
	  <xsl:otherwise>
	    <!-- Recursively check remaining string -->
	    <xsl:call-template name="check-lonely-node-for-bracetype">
	      <xsl:with-param name="open-braces" select="$open-braces - 1"/>
	      <xsl:with-param name="node" select="substring-after($node, $cc)"/>
	      <xsl:with-param name="co" select="$co"/>
	      <xsl:with-param name="cc" select="$cc"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- Only an opening brace -->
      <xsl:when test="not(contains($node, $cc))">true</xsl:when>
      <!-- Both appear, closing brace comes first -->
      <xsl:when test="$pos-opening-brace > $pos-closing-brace">
	<xsl:choose>
	  <!-- No corresponding opening brace seen -->
	  <xsl:when test="$open-braces = 0">true</xsl:when>
	  <xsl:otherwise>
	    <!-- Recursively check remaining string -->
	    <xsl:call-template name="check-lonely-node-for-bracetype">
	      <xsl:with-param name="open-braces" select="$open-braces - 1"/>
	      <xsl:with-param name="node" select="substring-after($node, $cc)"/>
	      <xsl:with-param name="co" select="$co"/>
	      <xsl:with-param name="cc" select="$cc"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- Both appear, opening brace comes first -->
      <xsl:otherwise>
	<!-- Recursively check remaining string -->
	<xsl:call-template name="check-lonely-node-for-bracetype">
	  <xsl:with-param name="open-braces" select="$open-braces + 1"/>
	  <xsl:with-param name="node" select="substring-after($node, $co)"/>
	  <xsl:with-param name="co" select="$co"/>
	  <xsl:with-param name="cc" select="$cc"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
  <!-- If no other template matches, copy the encountered attributes and elements -->
  <xsl:template match='@* | node()'>
    <xsl:copy><xsl:apply-templates select='@* | node()'/></xsl:copy>
  </xsl:template>

</xsl:stylesheet>

