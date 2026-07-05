<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
   <title>ISO Schematron rules</title>
   <!-- This file generated 2026-07-05T17:04:13Z by 'extract-isosch.xsl'. -->
   <!-- ********************* -->
   <!-- namespaces, declared: -->
   <!-- ********************* -->
   <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
   <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
   <ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
   <ns prefix="rna" uri="http://relaxng.org/ns/compatibility/annotations/1.0"/>
   <ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>
   <ns prefix="sch1x" uri="http://www.ascc.net/xml/schematron"/>
   <!-- ********************* -->
   <!-- namespaces, implicit: -->
   <!-- ********************* -->
   <ns prefix="esp-d3e64049" uri="http://www.w3.org/2001/XInclude"/>
   <!-- ******************************************************* -->
   <!-- constraints in en, und, mul, zxx, of which there are 53 -->
   <!-- ******************************************************* -->
   <pattern id="schematron-constraint-CMC_generatedBy_within_post-1">
      <rule context="tei:*[@generatedBy]">
         <assert test="ancestor-or-self::tei:post">The @generatedBy attribute is for use within a &lt;post&gt; element.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-att-datable-w3c-when-2">
      <rule context="tei:*[@when]">
         <report test="@notBefore|@notAfter|@from|@to" role="nonfatal">The @when attribute cannot be used with any other att.datable.w3c attributes.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-att-datable-w3c-from-3">
      <rule context="tei:*[@from]">
         <report test="@notBefore" role="nonfatal">The @from and @notBefore attributes cannot be used together.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-att-datable-w3c-to-4">
      <rule context="tei:*[@to]">
         <report test="@notAfter" role="nonfatal">The @to and @notAfter attributes cannot be used together.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-only_1_ODD_source-5">
      <rule context="tei:*[@source]">
         <let name="srcs" value="tokenize( normalize-space(@source),' ')"/>
         <report test="(   self::tei:classRef                                 | self::tei:dataRef                                 | self::tei:elementRef                                 | self::tei:macroRef                                 | self::tei:moduleRef                                 | self::tei:schemaSpec )                                   and                                   $srcs[2]"> When used on a schema description element (like <value-of select="name(.)"/>), the @source attribute should have only 1 value. (This one has <value-of select="count($srcs)"/>.)</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-targetLang-6">
      <rule context="tei:*[not(self::tei:schemaSpec)][@targetLang]">
         <assert test="@target">@targetLang should only be used on <name/> if @target is specified.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-spanTo-points-to-following-7">
      <rule context="tei:*[ starts-with( @spanTo, '#') ]">
         <assert test="id( substring( @spanTo, 2 ) ) &gt;&gt; ."> The element indicated by @spanTo (<value-of select="@spanTo"/>) must follow the current <name/> element</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-schemeVersionRequiresScheme-8">
      <rule context="tei:*[@schemeVersion]">
         <assert test="@scheme and not(@scheme = 'free')"> @schemeVersion can only be used if @scheme is specified.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-subtypeTyped-9">
      <rule context="tei:*[@subtype]">
         <assert test="@type">The <name/> element should not be categorized in detail with @subtype unless also categorized in general with @type</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-calendar_attr_on_empty_element-10">
      <rule context="tei:*[@calendar]">
         <assert test="string-length( normalize-space(.) ) gt 0"> @calendar indicates one or more systems or calendars to which the date represented by the content of this element belongs, but this <name/> element has no textual content.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-p-in-ab-or-p-11">
      <rule context="tei:p">
         <report test="(ancestor::tei:ab or ancestor::tei:p) and                        not( ancestor::tei:floatingText                           | parent::tei:exemplum                           | parent::tei:item                           | parent::tei:note                           | parent::tei:q                           | parent::tei:quote                           | parent::tei:remarks                           | parent::tei:said                           | parent::tei:sp                           | parent::tei:stage                           | parent::tei:cell                           | parent::tei:figure )"> Abstract model violation: Paragraphs may not occur inside other paragraphs or ab elements.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-p-in-l-12">
      <rule context="tei:l//tei:p">
         <assert test="ancestor::tei:floatingText | parent::tei:figure | parent::tei:note"> Abstract model violation: Metrical lines may not contain higher-level structural elements such as div, p, or ab, unless p is a child of figure or note, or is a descendant of floatingText.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-deprecationInfo-only-in-deprecated-13">
      <rule context="tei:desc[ @type eq 'deprecationInfo']">
         <assert test="../@validUntil">Information about a deprecation should only be present in a specification element that is being deprecated: that is, only an element that has a @validUntil attribute should have a child &lt;desc type="deprecationInfo"&gt;.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-rt-target-not-span-14">
      <rule context="tei:rt/@target">
         <report test="../@from | ../@to">When target= is present, neither from= nor to= should be.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-rt-from-15">
      <rule context="tei:rt/@from">
         <assert test="../@to">When from= is present, the to= attribute of <name/> is required.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-rt-to-16">
      <rule context="tei:rt/@to">
         <assert test="../@from">When to= is present, the from= attribute of <name/> is required.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-ptrAtts-17">
      <rule context="tei:ptr">
         <report test="@target and @cRef">Only one of the attributes @target and @cRef may be supplied on <name/>.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-refAtts-18">
      <rule context="tei:ref">
         <report test="@target and @cRef">Only one of the attributes @target and @cRef may be supplied on <name/>.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-gloss-list-must-have-labels-19">
      <rule context="tei:list[@type='gloss']">
         <assert test="tei:label">The content of a "gloss" list should include a sequence of one or more pairs of a label element followed by an item element</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-targetorcontent1-20">
      <rule context="tei:relatedItem">
         <report test="@target and count( child::* ) &gt; 0">If the @target attribute on <name/> is used, the relatedItem element must be empty</report>
         <assert test="@target or child::*">A relatedItem element should have either a @target attribute or a child element to indicate the related bibliographic item</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-l-in-l-21">
      <rule context="tei:l">
         <report test="ancestor::tei:l[not(.//tei:note//tei:l[. = current()])]">Abstract model violation: Lines may not contain lines or lg elements.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-atleast1oflggapl-22">
      <rule context="tei:lg">
         <assert test="count(descendant::tei:lg|descendant::tei:l|descendant::tei:gap) &gt; 0">An lg element must contain at least one child l, lg, or gap element.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-lg-in-l-23">
      <rule context="tei:lg">
         <report test="ancestor::tei:l[not(.//tei:note//tei:lg[. = current()])]">Abstract model violation: Lines may not contain line groups.</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-quotationContents-24">
      <rule context="tei:quotation">
         <report test="not( @marks )  and  not( tei:p )"> On <name/>, either the @marks attribute should be used, or a paragraph of description provided</report>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-citestructure-outer-match-29">
      <rule context="tei:citeStructure[not(parent::tei:citeStructure)]">
         <assert test="starts-with(@match,'/')">An XPath in @match on the outer <name/> must start with '/'.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-citestructure-inner-match-30">
      <rule context="tei:citeStructure[parent::tei:citeStructure]">
         <assert test="not(starts-with(@match,'/'))">An XPath in @match must not start with '/' except on the outer <name/>.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-div-in-l-31">
      <rule context="tei:l//tei:div">
         <assert test="ancestor::tei:floatingText"> Abstract model violation: Metrical lines may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.</assert>
      </rule>
   </pattern>
   <pattern id="schematron-constraint-abstractModel-structure-div-in-ab-or-p-32">
      <rule context="tei:div">
         <report test="(ancestor::tei:p or ancestor::tei:ab) and not(ancestor::tei:floatingText)"> Abstract model violation: p and ab may not contain higher-level structural elements such as div, unless div is a descendant of floatingText.</report>
      </rule>
   </pattern>
   <!-- ****************** -->
   <!-- deprecation tests: -->
   <!-- ****************** -->
   <pattern>
      <rule context="tei:superEntry">
         <report test="true()" role="nonfatal">
                  WARNING: use of deprecated element — The <name/> element will be removed from the TEI on 2027-03-07. 
                </report>
      </rule>
   </pattern>
   <pattern>
      <rule context="tei:re">
         <report test="true()" role="nonfatal">
                  WARNING: use of deprecated element — The <name/> element will be removed from the TEI on 2026-03-10. 
                </report>
      </rule>
   </pattern>
</schema>
