<?php

global $Langcode2english;
$Langcode2english = array(
 'afr' => _('Afrikaans'),
 'ara' => _('Arabic'),
 'ast' => _('Asturian'),
 'bel' => _('Belarusian'),
 'bre' => _('Breton'),
 'bos' => _('Bosnian'),
 'cat' => _('Catalan'),
 'ces' => _('Czech'),
 'ckb' => _('Sorani'),
 'cym' => _('Welsh'),
 'bul' => _('Bulgarian'),
 'dan' => _('Danish'),
 'nld' => _('Dutch'),
 'ell' => _('Modern Greek'),
 'eng' => _('English'),
 'epo' => _('Esperanto'),
 'fra' => _('French'),
 'gla' => _('Scottish Gaelic'),
 'gle' => _('Irish'),
 'deu' => _('German'),
 'hin' => _('Hindi'),
 'hrv' => _('Croatian'),
 'hun' => _('Hungarian'),
 'iri' => _('Irish'),
 'isl' => _('Icelandic'),
 'ita' => _('Italian'),
 'kha' => _('Khasi'),
 'kmr' => _('Kurmanji'),
 'kur' => _('Kurdish'),
 'lat' => _('Latin'),
 'lit' => _('Lithuanian'),
 'mkd' => _('Macedonian'),
 'nno' => _('Norwegian Nynorsk'),
 'nob' => _('Norwegian Bokmål'),
 'jpn' => _('Japanese'),
 'oci' => _('Occitan'),
 'pol' => _('Polish'),
 'por' => _('Portuguese'),
 'rom' => _('Romanian'),
 'rus' => _('Russian'),
 'san' => _('Sanskrit'),
 'sco' => _('Gaelic Scottish'), // this module was named incorrectly
 'slk' => _('Slovak'),
 'spa' => _('Spanish'),
 'srp' => _('Serbo-Croatian'),
 'swa' => _('Swahili'),
 'swh' => _('Swahili'),
 'swe' => _('Swedish'),
 'tur' => _('Turkish'),
 'ukr' => _('Ukrainian'),
 );

asort($Langcode2english);

# all images should be available as /images/flags/$Langcode.gif
# list here exceptions only
global $Langcode2image;
$Langcode2image = array(
 'lat' => 'images/flags/lat.png'
 );

function langcode2english($code)
{
  global $Langcode2english;
  if(isset($Langcode2english[$code])) return $Langcode2english[$code];
  return $code;
}

function langcode2image($code)
{
  global $Langcode2image;
  if(isset($Langcode2image[$code])) return $Langcode2image[$code];
  if(file_exists("images/flags/$code.gif")) return "images/flags/$code.gif";
  return;
}

?>
