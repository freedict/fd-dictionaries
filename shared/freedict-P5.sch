<?xml version="1.0" encoding="utf-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <title>ISO Schematron rules</title>
  <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
  <ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
  <pattern id="gramGrp-tagUsage_conformance">
    <rule
      context="/tei:TEI/tei:text/tei:body//tei:*[local-name() eq 'entry' or local-name() eq 'sense']/tei:gramGrp/tei:*">
      <let name="loc_name" value="local-name()"/>
      <assert
        test="not(/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:tagsDecl/tei:namespace[@name eq 'http://www.tei-c.org/ns/1.0']/tei:tagUsage[@gi eq $loc_name]/tei:list/tei:item) or (. = /tei:TEI/tei:teiHeader/tei:encodingDesc/tei:tagsDecl/tei:namespace[@name eq 'http://www.tei-c.org/ns/1.0']/tei:tagUsage[@gi eq $loc_name]/tei:list/tei:item)"
        >The values of gramGrp/<name/> must belong to the set identified in tagUsage for this
        element.</assert>
    </rule>
    <rule context="/tei:TEI/tei:text/tei:body//tei:cit[@type eq 'trans']/tei:gramGrp/tei:*">
      <let name="loc_name" value="local-name()"/>
      <assert
        test="not(/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:tagsDecl/tei:namespace[@name eq 'http://www.tei-c.org/ns/1.0'][@n eq 'equiv']/tei:tagUsage[@gi eq $loc_name]/tei:list/tei:item) or (. = /tei:TEI/tei:teiHeader/tei:encodingDesc/tei:tagsDecl/tei:namespace[@name eq 'http://www.tei-c.org/ns/1.0'][@n eq 'equiv']/tei:tagUsage[@gi eq $loc_name]/tei:list/tei:item)"
        >The values of cit[@type='trans']/gramGrp/<name/> must belong to the set identified in
        tagUsage for this element, in the 'equiv' section.</assert>
    </rule>
    <rule
      context="/tei:TEI/tei:text/tei:body//tei:*[local-name() eq 'entry' or local-name() eq 'sense']/tei:gramGrp/tei:gramGrp[@type='agr']/tei:*">
      <let name="loc_name" value="local-name()"/>
      <assert
        test="not(/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:tagsDecl/tei:namespace[@name eq 'http://www.tei-c.org/ns/1.0'][@n eq 'agr']/tei:tagUsage[@gi eq $loc_name]/tei:list/tei:item) or (. = /tei:TEI/tei:teiHeader/tei:encodingDesc/tei:tagsDecl/tei:namespace[@name eq 'http://www.tei-c.org/ns/1.0'][@n eq 'agr']/tei:tagUsage[@gi eq $loc_name]/tei:list/tei:item)"
        >The values of gramGrp[@type='agr']/<name/> must belong to the set identified in tagUsage
        for this element, in the 'agr' section.</assert>
    </rule>
  </pattern>
  <pattern id="tagUsage_item_check">
    <rule context="tei:list/tei:item">
      <let name="targ_res" value="document(@ana)"/>
      <assert
        test="if(ancestor::tei:tagsDecl[@rend eq 'anchored'] or ancestor::tei:namespace[@rend eq 'anchored'] or ancestor::tei:tagUsage[@rend eq 'anchored']) then (exists($targ_res) and string-length($targ_res)) else true()"
        >The @ana attributes should identify a resource fragment in the FreeDict ontology
        interface.</assert>
    </rule>
  </pattern>
  <pattern id="ptr-constraint-ptrAtts">
    <rule context="tei:ptr">
      <report test="@target and @cRef">Only one of the attributes 'target' and 'cRef' may be
        supplied.</report>
    </rule>
  </pattern>
  <pattern id="ref-constraint-refAtts">
    <rule context="tei:ref">
      <report test="@target and @cRef">Only one of the attributes 'target' and 'cRef' may be
        supplied.</report>
    </rule>
  </pattern>
  <pattern id="relatedItem-constraint-targetorcontent1">
    <rule context="tei:relatedItem">
      <report test="@target and count( child::* ) &gt; 0">If the 'target' attribute is used, the
        relatedItem element must be empty</report>
      <assert test="@target or child::*">A relatedItem element should have either a 'target'
        attribute or a child element to indicate the related bibliographic item</assert>
    </rule>
  </pattern>
</schema>
