<?php

global $freedict_database, $fddb_docel, $get_attr, $have_php5;
define(DB_FILENAME, '../freedict-database.xml');
// php4 uses the domxml extension, php5 the dom extension
$have_php5 = version_compare(PHP_VERSION, '5', '>=');

$freedict_database = ($have_php5) ?
 DOMDocument::load(DB_FILENAME) :
 domxml_open_file(DB_FILENAME);
if(!$freedict_database)
{
  echo "Error while parsing the document\n";
  exit;
}

if(!$have_php5) $fddb_docel = $freedict_database->document_element();

function getElementsByTagName($of, $tagname)
{
  global $have_php5;
  return ($have_php5) ?
    $of->getElementsByTagName($tagname) :
    $of->get_elements_by_tagname($tagname);
}

$dicts = ($have_php5) ?
 $freedict_database->getElementsByTagName('dictionary') :
 $fddb_docel->get_elements_by_tagname('dictionary');

$get_attr = ($have_php5) ? 'getAttribute' : 'get_attribute';
$set_attr = ($have_php5) ? 'setAttribute' : 'set_attribute';

foreach($dicts as $d)
{

  $status = $d->$get_attr('status');
  $headwords = $d->$get_attr('headwords');
  // set interesting status
  if($status=='unknown' && ($headwords > 10000))
    $status='big enough to be useful';
  if($status=='unknown' && ($headwords < 1000))
    $status='too small';
  $d->$set_attr('status', $status);
}

function status2color($status)
{
  switch($status)
  {
    case 'stable': return '#aaffaa';break;
    case 'big enough to be useful': return '#aaffaa';break;
    case 'too small': return '#aaaaaa';break;
    case 'low quality': return '#ffaaaa';break;
    default: return '#dddddd';
  }
}

function linkcell($dictionary, $release, $platform, $alt = '')
{
  global $get_attr;
  if(!$release)
  {
    $unsupported = $dictionary->$get_attr('unsupported');
    if(preg_match("/$platform/", $unsupported)) echo '<td>u</td>';
    else echo '<td>-</td>';
    return;
  }

  $url = $release->$get_attr('URL');
  echo '<td bgcolor="'. status2color($dictionary->$get_attr('status'))
    .'"><a href="'. $url .'" target="_top"';
  if(isset($alt)) echo ' title="'. $alt .'"';
  echo '>';
  printf("%2.2f", $release->$get_attr('size') / pow(2, 20));
  echo "</a></td>\n";
}

function find_release($dictionary, $platform)
{
  global $get_attr;
  $rs = getElementsByTagName($dictionary, 'release');
  foreach($rs as $r)
  {
    if($r->$get_attr('platform') == $platform) return $r;
  }
  return NULL;
}

function find_dictionary($name)
{
  global $fddb_docel, $have_php5, $freedict_database, $get_attr;
  foreach(getElementsByTagname(($have_php5) ? $freedict_database :
   $fddb_docel, 'dictionary') as $d)
    if($d->$get_attr('name') == $name) return $d;
  return NULL;
}

?>
