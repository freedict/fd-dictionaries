<?php

global $Langcode2english;
$Langcode2english = array(
 'afr' => _('Afrikaans'),
 'ara' => _('Arabic'),
 'ckb' => _('Sorani'),
 'cro' => _('Croatian'),
 'cze' => _('Czech'),
 'bul' => _('Bulgarian'),
 'dan' => _('Danish'),
 'nld' => _('Dutch'),
 'eng' => _('English'),
 'ell' => _('Modern Greek'),
 'fra' => _('French'),
 'gle' => _('Irish'),
 'deu' => _('German'),
 'hin' => _('Hindi'),
 'hun' => _('Hungarian'),
 'iri' => _('Irish'),
 'ita' => _('Italian'),
 'kha' => _('Khasi'),
 'kmr' => _('Kurmanji'),
 'kur' => _('Kurdish'),
 'lat' => _('Latin'),
 'lit' => _('Lithuanian'),
 'jpn' => _('Japanese'),
 'pol' => _('Polish'),
 'por' => _('Portuguese'),
 'rom' => _('Romanian'),
 'rus' => _('Russian'),
 'san' => _('Sanskrit'),
 'sco' => _('Gaelic Scottish'), // this module was named incorrectly
 'scr' => _('Serbo-Croatian'),
 'slo' => _('Slovak'),
 'spa' => _('Spanish'),
 'swa' => _('Swahili'),
 'swh' => _('Swahili'),
 'swe' => _('Swedish'),
 'tur' => _('Turkish'),
 'wel' => _('Welsh'),
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
