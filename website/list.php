<?php
require_once "inc/data.php";
require_once "inc/langcodes.php";
require_once 'inc/links.php';
require_once 'inc/gettext.php';
$title = _('Download / List View'); require_once 'inc/head.php';
?>
<body>

<h1><?php echo _('Detailed Dictionary Overview') ?></h1>

<table summary="Detailed Dictionary Overview">
 <tr bgcolor="#eeeeee">
  <th rowspan="2"><?php echo _('Language &amp; Project') ?></th>
  <th rowspan="2"><?php echo _('Maintainer') ?></th>
  <th rowspan="2"><?php echo _('Headwords') ?></th>
  <th rowspan="2"><?php echo _('Version') ?></th>
  <th rowspan="2"><?php echo _('Last Changed') ?></th>
  <th rowspan="2"><?php echo _('Status') ?></th>
  <th colspan="8"><?php echo _('Version for / Size in MB') ?></th>
 </tr>
 <tr bgcolor="#dddddd">
  <th>dictd</th>
  <th><small>evolutionary</small></th>
  <!-- th><small>mobi- pocket</small></th -->
  <th>zbedic</th>
  <th>StarDict</th>
  <th>rpm</th>
  <th>TEI XML</th>
  <th>src</th>
 </tr>

<?php

function cmp($a, $b)
{
  global $get_attr;
  $na = $a->$get_attr('name');
  $nb = $b->$get_attr('name');
  if($na == $nb) return 0;
  return ($na < $nb) ? -1 : 1;
}

function nodelist2array($nodelist)
{
  $r = array();
  foreach($nodelist as $n) array_push($r, $n);
  return $r;
}

$ds = ($have_php5) ?
 nodelist2array($freedict_database->getElementsByTagName('dictionary')) :
 $fddb_docel->get_elements_by_tagname('dictionary');

usort($ds, "cmp");
$dscount = 0;
$hwsum = 0;
foreach($ds as $d)
{
  $dscount++;
  list($l1, $l2) = split('-', $d->$get_attr('name'));

  $status = $d->$get_attr('status');
  echo '<tr bgcolor="'. status2color($status) .'">';

  echo '<td>';
  $source = $d->$get_attr('sourceURL');
  if($source) echo '<a href="'. htmlentities($source) .'" target="_top">';
  echo _(langcode2english($l1)) .' -&gt; '. _(langcode2english($l2));
  if($source) echo '</a>';
  echo '</td>';

  $maintainer = $d->$get_attr('maintainerName');
  if($maintainer=='') $maintainer='-';
  echo '<td>'. $maintainer .'</td>';
  echo '<td align="right">'. $d->$get_attr('headwords') .'</td>';
  $hwsum += $d->$get_attr('headwords');
  echo '<td>'. $d->$get_attr('edition') .'</td>';
  echo '<td>'. $d->$get_attr('date') .'</td>';
  echo '<td><small>'. $status .'</small></td>';

  foreach(array('dictd', 'evolutionary', 'bedic', 'stardict', 'rpm', 'tei', 'src') as $platform)
  {
    linkcell($d, find_release($d, $platform), $platform);
  }

  echo '</tr>';
}
?>
</table>

<?php
echo "$dscount dictionaries, $hwsum headwords<br />";

require_once 'inc/legend.php';
require_once 'inc/footer.php';
 ?>
