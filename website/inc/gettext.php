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
    list($langtag, $QString) = explode(';q=', $lWithQString);
    if($QString=='') $Q = 1;
    else list($Q) = sscanf ($QString, "%f");
    $langtag2Q[$langtag] = $Q;
    //echo "langtag2Q[$langtag]= $Q<br>";
  }
 }
 
 global $twoletters2threeletters;
 $twoletters2threeletters = array(
  'de' => 'deu',
  'en' => 'eng',
  'ku' => 'kur',
  'ru' => 'rus');
  
 // the following also defines which locales we offer
 global $langtag2locale;
 $langtag2locale = array(
  'de' => 'de_DE',
  'kha' => 'kha_IN',
  'ku' => 'ku_TR',
  'ru' => 'ru_RU',
  );
 arsort($langtag2Q);
 global $content_language;
 $content_language = 'en';
 $l = 'en_GB';
 
 foreach($langtag2Q as $langtag => $Q)
 {
   //echo "Trying $langtag...";
   if(($langtag2locale[$langtag]) or
      defined($langtag2locale[$langtag])) // TODO
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
   $ret = setlocale(LC_ALL, $l);
   if(!$ret) echo "setlocale to '$l' failed<br>";
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
    '<form action="../" method="GET">' .
    _("Website Language: ") .
        '<select name="l" onChange="parent.location.href=\'../\'+l.value">' . "\n" .
        '  <option value="en">' . _('English') . "</option>\n";
   foreach($langtag2locale as $lt => $loc)
   {
     if(strlen($lt)==2 && isset($twoletters2threeletters[$lt]))
       $lt2 = $twoletters2threeletters[$lt];else $lt2 = $lt;
     $r .= '  <option value="' . $lt . '"';
     if($lt == $content_language) $r .= ' selected';
     $r .= '>' . langcode2english($lt2) . "</option>\n";
   }
   return $r . '</select><input type="submit" value="!"></form>';
 }
 
?>
