<xsl:stylesheet version='1.0'	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
<!-- vim: set ft=xml tw=160 shiftwidth=2 expandtab sts=2 ts=2: -->
  <!-- Transform bar.xml into FreeDict TEI XML -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:template match="/">
    <xsl:apply-templates select="source/*">
      <xsl:sort data-type="text" order="ascending" select="@orth"/>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="sub">
    <xsl:variable name="headword_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- handle @g attribute (gender), it might contain a slash -->
    <xsl:variable name="g">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@g"/>
      </xsl:call-template>
    </xsl:variable>

    <entry>
      <xsl:attribute name="xml:id"> <!-- add xml:id -->
        <xsl:choose>
          <xsl:when test="string-length(@id)>0"> <!-- then we set a special id -->
            <xsl:value-of select="@id"/>
          </xsl:when>
          <xsl:otherwise> <!-- else take, like usual, the automatic generated id -->
            <xsl:text>sub_</xsl:text><xsl:value-of select="$headword_id"/><xsl:text>_</xsl:text><xsl:value-of select="$g"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
        <xsl:if test="string-length(@gen)>0">
          <form type="infl">
            <orth><xsl:value-of select="@gen"/></orth>
            <gramGrp>
              <case>gen</case>
            </gramGrp>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@dat)>0">
          <form type="infl">
            <orth><xsl:value-of select="@dat"/></orth>
            <gramGrp>
              <case>dat</case>
            </gramGrp>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@akk)>0">
          <form type="infl">
            <orth><xsl:value-of select="@akk"/></orth>
            <gramGrp>
              <case>akk</case>
            </gramGrp>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@abl)>0">
          <form type="infl">
            <orth><xsl:value-of select="@abl"/></orth>
            <gramGrp>
              <case>abl</case>
            </gramGrp>
          </form>
        </xsl:if>
      </form>
      <gramGrp>
        <pos>n</pos>
        <xsl:choose>
          <xsl:when test="string-length(@pl) > 0">
            <number>pl</number>
          </xsl:when>
          <xsl:otherwise>
            <number>sg</number>
          </xsl:otherwise>
        </xsl:choose>
        <gen><xsl:value-of select="@g"/></gen>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>



  <xsl:template match="adv"> <!-- adverbs -->
    <xsl:variable name="the_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>

    <entry> <xsl:attribute name="xml:id">adv_<xsl:value-of select="$the_id"/></xsl:attribute>
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
      </form>
      <gramGrp>
        <pos>adv</pos>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>

  <xsl:template match="int"> <!-- for interjections -->
    <xsl:variable name="the_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>


    <entry> <xsl:attribute name="xml:id">
        <xsl:text>int_</xsl:text>
        <xsl:value-of select="$the_id"/>
      </xsl:attribute>
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
      </form>
      <gramGrp>
        <pos>int</pos>
        <xsl:if test="string-length(@pl)>0">
          <number>pl</number>
        </xsl:if>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>


  <xsl:template match="vrb">
    <!-- attributes, valid:
      * @orth     - I-form of verb
      * @i        - infinitive form
      * @p        - perfect form
      * @s        - supine form
      * @pers="3" - verb exists only in third-person form
    -->

    <xsl:variable name="id_head"> <!-- Head form -->
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
      <xsl:text>_</xsl:text>
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@i"/>
      </xsl:call-template>
    </xsl:variable>

    <entry>
      <xsl:attribute name="xml:id">vrb_head_<xsl:value-of select="$id_head"/></xsl:attribute>
      <!-- Why such a long id? We had the case that some verbs had the same head- but another infinitive; this should solve the problem -->
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
        <xsl:if test="string-length(@i)>0">
          <form type="infl">
            <orth type="inf"><xsl:value-of select="@i"/></orth>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@p)>0">
          <form type="infl">
            <orth type="perf"><xsl:value-of select="@p"/></orth>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@s)>0">
          <form type="infl">
            <orth type="sup"><xsl:value-of select="@s"/></orth>
          </form>
        </xsl:if>
      </form>
      <gramGrp>
        <number>sg</number>
        <xsl:if test="string-length(@pers) > 0">
          <per>3</per>
        </xsl:if>
        <mood>ind</mood>
        <tns>praes</tns>
        <pos>v</pos>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>


  <xsl:template match="adj">

    <xsl:variable name="the_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>

    <entry> <xsl:attribute name="xml:id">adj_<xsl:value-of select="$the_id"/></xsl:attribute>
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
        <xsl:if test="string-length(@f)>0">
          <form type="infl">
            <orth><xsl:value-of select="@f"/></orth>
            <gramGrp>
              <gen>f</gen>
            </gramGrp>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@n)>0">
          <form type="infl">
            <orth><xsl:value-of select="@n"/></orth>
            <gramGrp>
              <gen>n</gen>
            </gramGrp>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@gen)>0">
          <form type="infl">
            <orth><xsl:value-of select="@gen"/></orth>
            <gramGrp>
              <case>gen</case>
            </gramGrp>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@dat)>0">
          <form type="infl">
            <orth><xsl:value-of select="@dat"/></orth>
            <gramGrp>
              <case>dat</case>
            </gramGrp>
          </form>
        </xsl:if>
      </form>
      <gramGrp>
        <pos>adj</pos>
        <gen>m</gen>
        <xsl:if test="string-length(@pl)>0">
          <number>pl</number>
        </xsl:if>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>

  <xsl:template match="phr">
    <xsl:variable name="the_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>

    <entry> <xsl:attribute name="xml:id"><xsl:value-of select="$the_id"/></xsl:attribute>
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
      </form>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>


  <xsl:template match="conj">
    <xsl:variable name="the_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>

    <entry> <xsl:attribute name="xml:id">conj_<xsl:value-of select="$the_id"/></xsl:attribute>
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
      </form>
      <gramGrp>
        <pos>conj</pos>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>

    </entry>
  </xsl:template>

  <xsl:template match="num">

    <xsl:variable name="the_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>

    <entry> <xsl:attribute name="xml:id">num_<xsl:value-of select="$the_id"/></xsl:attribute>
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
      </form>
      <gramGrp>
        <pos>num</pos>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>



  <xsl:template match="prep">
    <xsl:variable name="the_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>

    <entry> <xsl:attribute name="xml:id">prep_<xsl:value-of select="$the_id"/></xsl:attribute>
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
      </form>
      <gramGrp>
        <pos>prep</pos>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>



  <xsl:template match="prn">
    <xsl:variable name="the_id">
      <xsl:call-template name="convert_to_id">
        <xsl:with-param name="to_convert" select="@orth"/>
      </xsl:call-template>
    </xsl:variable>

    <entry> <xsl:attribute name="xml:id">prn_<xsl:value-of select="$the_id"/>_<xsl:value-of select="@g"/></xsl:attribute>
      <form xml:lang="la">
        <orth><xsl:value-of select="@orth"/></orth>
        <xsl:if test="string-length(@gen)>0">
          <form type="infl">
            <orth> <xsl:value-of select="@gen"/> </orth>
            <gramGrp>
              <case>gen</case>
            </gramGrp>
          </form>
        </xsl:if>
        <xsl:if test="string-length(@dat)>0">
          <form type="infl">
            <orth><xsl:value-of select="@dat"/> </orth>
            <gramGrp>
              <case>dat</case>
            </gramGrp>
          </form>
        </xsl:if>
      </form>
      <gramGrp>
        <pos>pron</pos>
        <xsl:if test="string-length(@g)>0">
          <gen> <xsl:value-of select="@g"/> </gen>
        </xsl:if>
      </gramGrp>
      <xsl:call-template name="sense">
        <xsl:with-param name="senses" select="."/>
        <xsl:with-param name="notes" select="@note"/>
      </xsl:call-template>
    </entry>
  </xsl:template>


  <!-- ================================================================== -->

  <xsl:template name="devide-senses">
    <!-- devide different senses which are seperated with ";"; is done recursively -->
    <xsl:param name="meaning"/>

    <!-- if this is a recursive call, there could be a white-space at the beginning, so modify the parameter -->
    <xsl:variable name="modified_meaning">
      <xsl:choose>
        <xsl:when test="substring($meaning, 0,2) = ' '">
          <xsl:value-of select="substring($meaning, 2,string-length(.))"/>
          <!-- from second character to the end 
            (odd odd, why not 1 for the second char) -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$meaning"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="result_meaning">
      <!-- we declare an extra variable to avoid having to a nested structure here -->
      <xsl:choose>
        <xsl:when test="contains($modified_meaning, ';')">
          <xsl:value-of select="substring-before($modified_meaning, ';')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$modified_meaning"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- ><xsl:text>(</xsl:text><xsl:value-of select="$result_meaning"/><xsl:text>)</xsl:text>
    -->
    <sense level="1">
      <cit type="trans">
        <quote><xsl:value-of select="$result_meaning"/></quote>
      </cit>
    </sense>

    <!-- more of these extra senses? get them: -->
    <xsl:if test="contains($modified_meaning, ';')">
      <!-- if there's another ";", call me recursively -->
      <xsl:call-template name="devide-senses">
        <xsl:with-param name="meaning" select="substring-after($modified_meaning, ';')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
 
  <xsl:template name="sense"> <!-- properly format translations -->
    <xsl:param name="senses"/>
    <xsl:param name="notes"/>

    <xsl:if test="string-length($notes) >0">
      <note type="usage"><xsl:value-of select="$notes"/></note>
    </xsl:if>

    <xsl:call-template name="devide-senses">
      <xsl:with-param name="meaning" select="."/>
    </xsl:call-template>
    <!-- I hope that I can put notes here without violating the standard -->
  </xsl:template>

   

  <xsl:template name="replace-string">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:choose>
      <xsl:when test="contains($text,$replace)">
        <xsl:value-of select="substring-before($text,$replace)"/>
        <xsl:value-of select="$with"/>
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
          <xsl:with-param name="replace" select="$replace"/>
          <xsl:with-param name="with" select="$with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="convert_to_id">
    <xsl:param name="to_convert"/>
    <xsl:variable name="replaced_once">
      <xsl:call-template name="replace-string"> <!-- defined template -->
        <xsl:with-param name="text" select="$to_convert"/>
        <xsl:with-param name="replace" select="' '"/>
        <xsl:with-param name="with" select="''"/> <!-- _ would make string longer that it is already -->
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="replaced_twice">
      <xsl:call-template name="replace-string"> <!-- defined template -->
        <xsl:with-param name="text" select="$replaced_once"/>
        <xsl:with-param name="replace" select="'.'"/>
        <xsl:with-param name="with" select="''"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="replaced_thrice">
      <xsl:call-template name="replace-string"> <!-- defined template -->
        <xsl:with-param name="text" select="$replaced_twice"/>
        <xsl:with-param name="replace" select="','"/>
        <xsl:with-param name="with" select="''"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="replaced_fourt">
      <xsl:call-template name="replace-string">
        <xsl:with-param name="text" select="$replaced_thrice"/>
        <xsl:with-param name="replace" select="'?'"/>
        <xsl:with-param name="with" select="''"/>
      </xsl:call-template>
    </xsl:variable>


    <!-- final output -->
    <xsl:call-template name="replace-string"> <!-- defined template -->
      <xsl:with-param name="text" select="$replaced_fourt"/>
      <xsl:with-param name="replace" select="'/'"/>
      <xsl:with-param name="with" select="'_'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="literal">
    <xsl:copy-of select="./*" />
  </xsl:template>
</xsl:stylesheet>
