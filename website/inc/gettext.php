<?php

 // a GET or POST parameter with name 'l' overrides HTTP_ACCEPT_LANGUAGE
 if(isset($_REQUEST['l']))
 {
   $langtag2Q[ $_REQUEST['l'] ] = 1;
 }
 else
 {
  // parse HTTP_ACCEPT_LANGUAGE
  //echo "HTTP_ACCEPT_LANGUAGE: " . $_SERVER['HTTP_ACCEPT_LANGUAGE'] . "<br>";
  $lsWithQString = explode(',', $_SERVER['HTTP_ACCEPT_LANGUAGE']);
  foreach($lsWithQString as $lWithQString)
  {
    $splitted = explode(';q=', $lWithQString);
    $langtag = $splitted[0];
    $QString = array_key_exists(1, $splitted) ? $splitted[1] : ''; 
    if($QString=='') $Q = 1;
    else list($Q) = sscanf ($QString, "%f");
    $langtag2Q[$langtag] = $Q;
    //echo "langtag2Q[$langtag]= $Q<br>";
  }
 }

 global $twoletters2threeletters;
 $twoletters2threeletters = array(
  'bs' => 'bos',
  'de' => 'deu',
  'en' => 'eng',
  'fr' => 'fra',
  'ku' => 'kur',
  'ar' => 'ara',
  'ru' => 'rus',
  'bg' => 'bul',
  'lt' => 'lit',
  'nl' => 'nld',
  'pt' => 'por');

 // the following also defines which locales we offer
 global $langtag2locale;
 $langtag2locale = array(
  'bs' => 'bs_BA',
  'de' => 'de_DE',
  'fr' => 'fr_FR',
  'kha' => 'kha_IN',
  'ku' => 'ku_TR',
  'ar' => 'ar_EG',
  'ru' => 'ru_RU',
  'bg' => 'bg_BG',
  'lt' => 'lt_LT',
  'nl' => 'nl_NL',
  'pt' => 'pt_BR'
  );
 arsort($langtag2Q);
 global $content_language;
 $content_language = 'en';
 $l = 'en_GB';

 foreach($langtag2Q as $langtag => $Q)
 {
   //echo "Trying $langtag...";
   if(array_key_exists($langtag, $langtag2locale)) // TODO
   {
     $content_language = $langtag;
     $l = $langtag2locale[$langtag];
     //echo "Using locale $l<br>";
     break;
   }
 }

 global $SKIP_SETLOCALE;
 if(!isset($SKIP_SETLOCALE))
 {
   $ret = setlocale(LC_MESSAGES, "$l.utf8");
   if(!$ret)
   {
     header("HTTP/1.0 500 Internal Server Error: setlocale to '$l' failed");
     die("setlocale to '$l' failed<br>");
   }
   //else echo "setlocale to '$l' succeeded: $ret<br>";
   $ret = bindtextdomain('freedict', 'locale');
   //echo "bindtextdomain: $ret<br>";
   bind_textdomain_codeset('freedict', 'UTF-8');
   $ret = textdomain('freedict');
   //echo "textdomain: $ret<br>";
 }

 function languagemenu()
 {
   include_once 'langcodes.php';
   global $langtag2locale, $Langcode2english, $twoletters2threeletters,
     $content_language;
   $r =
    '<form action="../" method="get">' .
    _("Website Language: ") .
        '<select name="l" onchange="parent.location.href=\'../\'+l.value">' . "\n" .
        '  <option value="en">' . _('English') . "</option>\n";
   foreach($langtag2locale as $lt => $loc)
   {
     if(strlen($lt)==2 && isset($twoletters2threeletters[$lt]))
       $lt2 = $twoletters2threeletters[$lt];else $lt2 = $lt;
     $r .= '  <option value="' . $lt . '"';
     if($lt == $content_language) $r .= ' selected="selected"';
     $r .= '>' . langcode2english($lt2) . "</option>\n";
   }
   return $r . '</select><input type="submit" value="!" /></form>';
 }

?>
