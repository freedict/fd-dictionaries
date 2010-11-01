(: simple_dump.xquery - perform a simple dump of the contents of a FreeDict dictionary

Originally by Piotr Bański (bansp at o2.pl), 01-nov-2010.
License: GNU GPL ver. 3.0 or any later version. 

$Id:$

This script expects an external parameter $lg_pair but you may safely set that to '' 
and manipulate the contents of $my_lg_pair pair instead.

Initially, it was only supposed to match the headword(s) with their equivalents, 
but I got slightly carried away. Still, this is supposed to be a simple dump, 
so it skips a lot of potential details.

:)

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace functx = "http:///www.functx.com";

declare option saxon:output "method=text";

(:the following variable is system-internal :)
declare variable $my_svn_id as xs:string := "$Id:$";

(: set this to the pair of languages that you want to process :)
declare variable $my_lg_pair as xs:string := "eng-scr";

(: reset this to true() for an even simpler dump :)
declare variable $skip_gram as xs:boolean := false();

declare variable $lg_pair as xs:string external;

declare function functx:get_lg_pair() as xs:string {
let $lgs := if ($lg_pair) then $lg_pair else $my_lg_pair
return $lgs
};

declare function functx:get_filename() as xs:string {
let $lgs := functx:get_lg_pair()
return concat('../../',$lgs,'/',$lgs,'.tei')
};

declare function functx:header() as xs:string {
let $ret := concat('Dump of ',functx:get_lg_pair(),'.tei on ',substring-before(string(xs:date(current-dateTime())),'+'),' at ',substring-before(string(xs:time(current-dateTime())),'.'),'&#10;&#10;')
return $ret
};

declare function functx:process() as xs:string+ {
for $entry in doc(functx:get_filename())/TEI/text/body/entry
let $hdwd := $entry/form/orth
let $gram := for $any in $entry/gramGrp/* return normalize-space($any)
let $gloss := $entry//cit[@type='trans']/quote | $entry//sense/def
order by lower-case($hdwd[1])
return concat(string-join($hdwd,', '),if (count($gram) and not($skip_gram)) then concat('  [',string-join($gram,'|'),']  ') else ' -- ',normalize-space(string-join($gloss,', ')))
};

let $ret := functx:process()
return concat(functx:header(),string-join($ret,'&#10;'))
