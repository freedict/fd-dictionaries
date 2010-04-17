<?php
$platform = substr(basename($_SERVER['PHP_SELF']), 6);
if(substr($platform,-4) =='.php') $platform= substr($platform, 0, -4);

$platformStrings = array(
  'dict-tgz' => '<a href="http://sourceforge.net/project/showfiles.php?group_id=605" target="_top">'.
    _('DICT servers') .'</a> ' ._('on Windows/Linux'),
  'dict-bz2' => '<a href="http://dict.org/links.html" target="_top">'.
    _('DICT servers') .'</a> ' ._('on Windows/Linux'),
  'mobipocket' => '<a href="http://www.mobipocket.com/en/DownloadSoft/DownLoadReaderStep1.asp" target="_top">'.
    _('Mobipocket') .'</a> '. _('on WinCE/Palm'),
  'evolutionary' => '<a href="http://www.mrhoney.de/y/1/html/evolutio.htm" target="_top">Evolutionary Dictionary</a> '.
    _('on WinCE/Palm'),
  'bedic' => '<a href="http://bedic.sourceforge.net/" target="_top">BEDic</a> '.
    _('on Zaurus/Qt'),
  'rpm' => '<a href="http://redhat.com/" target="_top">RedHat</a> or <a href="http://suse.com/" target="_top">SuSE</a> Linux',
  'gem' => '<a href="http://rocklinux.org/" target="_top">ROCK Linux</a>');

require_once 'inc/data.php';
require_once 'inc/langcodes.php';
require_once "inc/gettext.php";
require_once "inc/links.php";
$title = _('Download / Matrix View'); require_once 'inc/head.php';
?>
<body>

<h1><?php echo _('Download / Matrix View') ?></h1>

<p><?php printf(_('All downloads are for platform %s.'), '<i>' . $platformStrings[$platform], '</i>') ?></p>

<?php
  if(strpos($platform, 'dict-') !== false)
  {
    printf(_('Another application understanding this file format is %1sWordtrans%2s, a KDE application.'),
      '<a target="_parent" href="http://www.escomposlinux.org/rvm/wordtrans/">', '</a>');
  }
  else if($platform == 'bedic')
  {
    echo '<p>';
    echo _('BEDic has two frontends: ZBEDic, which runs on the Zaurus
     Linux PDA from Sharp, and QBEDic, which runs on Linux/Qt. BEDic is
     similar to stardict as it doesn\'t use a client/server
     approach like') .
     ' <a href="' . fdict_url('flags-dict-tgz.php') . '">dictd</a>.</p>';
  }
?>

<table summary="<?php echo _('Select your language combination!') ?>">
 <tr bgcolor="#eeeeee">
  <th colspan="<?php echo count($Langcode2english)+1 ."\">".
    _('Source Language / Size in MB') ?></th>
 </tr>
 <tr bgcolor="#eeeeee">
  <th><?php echo _('Destination<br />Language') ?></th>

<?php
  foreach($Langcode2english as $code => $english)
  {
    // no column if $code never appears as source language
    // or no release for this plattform available
    global $fddb_docel, $have_php5;
    $appears = false;
    foreach(getElementsByTagname(($have_php5) ? $freedict_database : $fddb_docel, 'dictionary') as $d)
    {
      if(substr($d->$get_attr('name'),0,3) == $code)
      {
	$r = find_release($d, $platform);
	if(isset($r))
	{
	  $appears = true; break;
	}
      }
    }
    if(!$appears) continue;

    // add to $columns
    $columns[$code] = $english;
    echo '<th>';
    $i = langcode2image($code);
    if(isset($i)) echo '<img src="'. fdict_url($i) .'" alt="'.
      _($english). '" title="'. _($english). '" />';
    else echo _($english);
    echo "</th>\n";
  }
?>

 </tr>

<?php

foreach($Langcode2english as $l2 => $english2)
{

  // no row if $l2 never appears as source language
  // or no release for this plattform available
  $appears = false;
  foreach($columns as $l1 => $english1)
  {
    if($l1 == $l2) continue;
    $combination = $l1 .'-'. $l2;
    $d = find_dictionary($combination);
    if(isset($d)) $r = find_release($d, $platform);
    if(!isset($d) or !isset($r)) continue;
    $appears = true; break;
  }
  if(!$appears) continue;

  // row head: image
  echo "<tr>\n<th bgcolor=\"#eeeeee\">";
  $i = langcode2image($l2);
  if(isset($i)) echo "<img src=\"". fdict_url($i) ."\" alt=\"".
      _($english2). "\" title=\"". _($english2). "\" />";
    else echo _($english2);
    echo "</th>\n";

  // the download cells
  foreach($columns as $l1 => $english1)
  {
    if($l1 == $l2)
    {
      echo "<td bgcolor=\"#eeeeee\"></td>\n"; continue;
    }

    $combination = $l1 .'-'. $l2;
    $d = find_dictionary($combination);
    if(isset($d)) $r = find_release($d, $platform);
    if(!isset($d) or !isset($r))
    {
      echo "<td>-</td>\n"; continue;
    }

    $alt = 'Headwords: '. $d->$get_attr('headwords').
	   ' Version: '. $d->$get_attr('version').
	   ' Last change: '. $d->$get_attr('date').
	   ' Status: '. $d->$get_attr('status');

    linkcell($d, $r, $platform, $alt);
  }

  echo "</tr>\n";
}

?>
</table>

<p><?php echo _('Please click on the links to get to the SourceForge
Download Mirror selection page. Right-Click and Save-As will not work
from here!') ?></p>

<?php
require 'inc/legend.php';
require_once 'inc/footer.php';
