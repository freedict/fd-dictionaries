<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0">

  <xsl:include href="indent.xsl"/>
   <!--<xsl:variable name="stylesheet-cvsid">
     $Id$
     </xsl:variable>
   added the variable but then uncommented it, because it would get priority 
   over the one defined in the header module; not sure if that was indended -->

<!-- the addition of P5 stuff relies on the absolute complementarity between
     null-spaced elements (P4) and elements in the TEI namespace (P5) -->

    <xsl:strip-space elements="*"/>

<!-- I am fully aware of introducing some project-specific features into the P5 mode,
     but let this stuff reside here for a while until we come up with a clean way to 
     import project-dependent overrides from the individual project directories... 13-apr-09-->

  <!-- TEI entry specific templates -->
  <xsl:template match="entry | tei:entry">
    <xsl:apply-templates select="form | tei:form"/> <!-- force form before gramGrp -->
    <xsl:apply-templates select="gramGrp | tei:gramGrp"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="sense | tei:sense"/>

    <!-- For simple entries without separate senses and old FreeDict databases -->
      <!-- assume that such ultraflat structure will not be used in P5  -->
    <xsl:for-each select="trans | def | note">
      <xsl:text> </xsl:text>
      <xsl:if test="not(last()=1)">
	<xsl:number value="position()"/>
	<xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="form | tei:form">
    <xsl:variable name="paren" select="count(parent::form) = 1 or count(parent::tei:form) = 1 or @type='infl'"/>
    <!-- parenthesised if nested or (ad hoc) if @type="infl" -->
    <xsl:if test="$paren">
      <xsl:text> (</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="usg | tei:usg"/>
    <!-- added to handle usg info in nested <form>s -->
    <xsl:for-each select="orth | tei:orth">
      <xsl:choose>
        <!-- values from the TEI Guidelines -->
        <xsl:when test="count(@extent)=0 or @extent='full'">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:when test="@extent='pref'">
          <xsl:value-of select="concat(.,'-')"/>
        </xsl:when>
        <xsl:when test="@extent='suff'">
          <xsl:value-of select="concat('-',.)"/>
        </xsl:when>
        <xsl:when test="@extent='part'">
          <xsl:value-of select="concat('-',.,'-')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="position() != last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates select="pron | tei:pron"/>
    <xsl:if test="$paren">
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="form | tei:form"/>
    <xsl:if test="(following-sibling::form and following-sibling::form[1][not(@type='infl')]) or
            (following-sibling::tei:form and following-sibling::tei:form[1][not(@type='infl')])">
      <xsl:text>, </xsl:text>
      <!-- cosmetics: no comma before parens  -->
    </xsl:if>
  </xsl:template>

<!-- can't see when this template may be active; see above for enhancement (pref, suff), if necessary -->
  <xsl:template match="orth | tei:orth">
    <xsl:value-of select="."/>
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="pron | tei:pron"/>
  </xsl:template>

  <xsl:template match="pron | tei:pron">
    <xsl:value-of select="concat(' /',.,'/')"/>
    <!--<xsl:text> /</xsl:text><xsl:apply-templates/><xsl:text>/</xsl:text>-->
  </xsl:template>

<!-- allow for empty <pos/>; make it a condition for the presence of angled brackets, too 
  the weird "(self::gramGrp or count(tei:pos/text())" 
      means "you're either P4 or <pos> in P5 is non-empty"
-->
  <xsl:template match="gramGrp | tei:gramGrp">
    <xsl:if test="count(ancestor::tei:gramGrp)=0 and (self::gramGrp or count(tei:pos/text()))"><xsl:text> &lt;</xsl:text></xsl:if>
    <xsl:for-each select="pos | tei:pos[text()] | subc | tei:subc | num | tei:num | gen | tei:gen | tei:gramGrp | tei:iType | tei:gram">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="count(ancestor::tei:gramGrp)=0 and (self::gramGrp or count(tei:pos/text()))"><xsl:text>></xsl:text></xsl:if>

    <!-- <xr> elements are not allowed inside <form> or <gramGrp>, so reach out and grab them... -->
    <xsl:if test="count(preceding-sibling::tei:xr[@type='plural-form' or @type='imp-form' or
                    @type='past-form' or @type='infl-form'])">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="preceding-sibling::tei:xr[@type='plural-form' or @type='imp-form' or
                                   @type='past-form' or @type='infl-form']"/>
    </xsl:if>
    <!-- horribly project-specific, will be overridden by project-specific imports later on; 
      OTOH, we might make this a project feature, too, if there is a need -->
    <xsl:if test="preceding-sibling::tei:form/@type='N'">
      <xsl:text> [sg=pl]</xsl:text>
    </xsl:if>
  </xsl:template>

<xsl:template match="tei:gram[@type='cl-agr']">
  <xsl:value-of select="concat('agr: ',.)"/>
</xsl:template>

  <xsl:template match="sense">
    <xsl:text> </xsl:text>
    <xsl:if test="not(last()=1)">
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number value="position()"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>. </xsl:text>
    </xsl:if>

    <xsl:if test="count(usg | trans | def)>0">
      <xsl:apply-templates select="usg | trans | def"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>

    <xsl:if test="count(eg)>0">
      <xsl:text>    </xsl:text>
      <xsl:apply-templates select="eg"/>
    </xsl:if>

    <xsl:if test="count(xr)>0">
      <xsl:text>    </xsl:text>
      <xsl:apply-templates select="xr"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>

    <xsl:apply-templates select="*[name() != 'usg' and name() != 'trans' and name() != 'def' and name() != 'eg' and name() != 'xr']"/>
  </xsl:template>
  
  <xsl:template match="tei:sense">
    <xsl:if test="self::tei:sense and preceding-sibling::tei:sense"><xsl:text>&#xa;</xsl:text></xsl:if>
    <xsl:text> </xsl:text>
    <xsl:if test="not(last()=1)">
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:value-of select="@n"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number value="position()"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>. </xsl:text>
    </xsl:if>
    
    <xsl:apply-templates/>
  </xsl:template>
  

   <xsl:template match="usg[@type] | tei:usg[@type]">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>.] </xsl:text>
  </xsl:template>

  <xsl:template match="trans"> <!-- P4 -->
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="tr"> <!-- P4 -->
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="def">
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space()"/>
      <xsl:with-param name="width" select="75"/>
      <xsl:with-param name="start" select="4"/>
    </xsl:call-template>
    <xsl:if test="not(position()=last())">&#xa;     </xsl:if>
  </xsl:template>

  <xsl:template match="tei:def">
    <xsl:variable name="stuff"><xsl:apply-templates select="*|text()"/></xsl:variable>
    <!-- first question: am I abused? Do I hold a translation equivalent 
    within a <sense>, or am I a real definition within a <cit>? -->
    <xsl:choose>
      <xsl:when test="parent::tei:sense">
        <xsl:variable name="separator">
          <xsl:choose>
            <xsl:when test="preceding-sibling::tei:def"><xsl:value-of select="'; '"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($separator,$stuff)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="format">
          <xsl:with-param name="txt" select="normalize-space($stuff)"/>
          <xsl:with-param name="width" select="75"/>
          <xsl:with-param name="start" select="4"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="eg"> <!-- P4 -->
    <xsl:text>&quot;</xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="concat(normalize-space(q), '&quot;')"/>
      <xsl:with-param name="width" select="75"/>
      <xsl:with-param name="start" select="4"/>
    </xsl:call-template>

    <xsl:if test="trans">
      <xsl:text>    (</xsl:text>
      <xsl:value-of select="trans/tr"/>
      <xsl:text>)&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xr">
    <xsl:choose>
      <xsl:when test="not(@type) or type='cf'">
        <xsl:text>See also</xsl:text>
      </xsl:when>
      <xsl:when test="@type='syn'">
        <xsl:text>Synonym</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@type"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>: {</xsl:text>
    <xsl:value-of select="ref | tei:ref"/>
    <xsl:text>}</xsl:text>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="tei:xr">
    <xsl:choose>
      <xsl:when test="count(@rend) and @rend='as-is'">
        <xsl:apply-templates/>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="not(@type) or @type='cf'">
            <xsl:text>&#xa;   See also: </xsl:text>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="@type='syn'">
            <xsl:text>&#xa;   </xsl:text>
            <xsl:choose>
              <xsl:when test="count(tei:ref) &gt; 1"><xsl:text>Synonyms: </xsl:text></xsl:when>
              <xsl:otherwise><xsl:text>Synonym: </xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="@type='ant'">
            <xsl:text>&#xa;   </xsl:text>
            <xsl:choose>
              <xsl:when test="count(tei:ref) &gt; 1"><xsl:text>Antonyms: </xsl:text></xsl:when>
              <xsl:otherwise><xsl:text>Antonym: </xsl:text></xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="@type='infl-base'"> <!-- inflectional base -->
            <xsl:text>&#xa; Inflection of: </xsl:text>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <xsl:when test="@type='deriv-base'"> <!-- derivational/compound base -->
            <xsl:text>&#xa; Derived from: </xsl:text>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:when>
          <!-- the <xr>s below are positioned inline -->
          <xsl:when test="@type='imp-form'"> <!-- imperative -->
            <xsl:text>(imp: </xsl:text>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:when test="@type='plural-form'"> <!-- plural -->
            <xsl:text>(pl: </xsl:text>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:when test="@type='past-form'"> <!-- past -->
            <xsl:text>(past: </xsl:text>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:when test="@type='infl-form'"> <!-- general inflections, e.g. past/pprt/fut -->
            <xsl:text>(</xsl:text>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- unknown type: print the value and set it on a separate line -->
            <xsl:text>&#xa; </xsl:text>
            <xsl:value-of select="concat(@type,': ')"/>
            <xsl:apply-templates select="tei:ref"/>
            <xsl:text>&#xa;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:ref">
    <xsl:if test="preceding-sibling::*[1][self::tei:ref]">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="ancestor::tei:teiHeader">
        <xsl:value-of select="concat(.,' [',@target,']')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('{',.,'}')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
   <xsl:template match="entry//p | tei:entry//tei:p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="entry//note">
    <xsl:choose>
      <xsl:when test="@resp='translator'">
        <xsl:text>&#xa;         Entry edited by: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:when>
      <xsl:when test="text()">
        <xsl:text>&#xa;         Note: </xsl:text>
        <xsl:value-of select="text()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:note[@type='editor']" priority="1"/>

  <xsl:template match="tei:entry//tei:note">
    <xsl:variable name="stuff"><xsl:apply-templates/></xsl:variable>
    <xsl:variable name="spc">
      <xsl:choose>
        <xsl:when test="(count(preceding-sibling::node())=0) or @rend='noindent'">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="' '"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count(@*)=0">
        <xsl:value-of select="concat('&#xa;         Note: ',$stuff)"/>
      </xsl:when>
      <xsl:when test="@resp='translator'">
        <xsl:text>&#xa;         Entry edited by: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>&#xa;</xsl:text>
      </xsl:when>
      <!-- a subset of values from the TEI Guidelines -->
      <xsl:when test="@type='lbl' or @type='dom' or @type='obj' or @type='subj' or @type='hint' or @type='num' or @type='geo' or @type='syn' or @type='colloc'">
        <xsl:value-of select="concat($spc,'(',.,')')"/>
      </xsl:when>
      <xsl:when test="@type='gram'">
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="format">
          <xsl:with-param name="txt" select="concat(' Note (gram.): ',normalize-space($stuff))"/>
          <xsl:with-param name="width" select="75"/>
          <xsl:with-param name="start" select="1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@type='usage'">
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="format">
          <xsl:with-param name="txt" select="concat(' Usage: ',normalize-space($stuff))"/>
          <xsl:with-param name="width" select="75"/>
          <xsl:with-param name="start" select="1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="@type='def'">
        <xsl:text>&#xa;</xsl:text>
        <xsl:call-template name="format">
          <!--<xsl:with-param name="txt" select="concat(' Def.: ',normalize-space())"/>-->
          <xsl:with-param name="txt" select="concat(' ',normalize-space($stuff))"/>
          <xsl:with-param name="width" select="75"/>
          <xsl:with-param name="start" select="1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($spc,'(',$stuff,')')"/>
      </xsl:otherwise>
      <!--<xsl:when test="text()">
        <xsl:text>&#xa;         Note: </xsl:text>
        <xsl:value-of select="text()"/>
      </xsl:when>-->
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:quote">
    <xsl:choose>
      <xsl:when test="parent::tei:cit[@type='dicteg']">
        <xsl:value-of select="concat('&quot;',.,'&quot;')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  <xsl:template match="tei:q">
    <xsl:value-of select="concat('&quot;',.,'&quot;')"/>
  </xsl:template>

</xsl:stylesheet>

