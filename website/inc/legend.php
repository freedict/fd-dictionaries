<table summary="<?php echo _('List of table cells with differing background colours representing examplary dictionary states') ?>">
 <caption><?php
include_once 'data.php';

echo _("Color Legend") . "</caption>\n";

function cell($status, $description)
{
  echo ' <tr><td bgcolor="'. status2color($status) .'">';
  echo "$description</td></tr>\n";
}

cell("stable",
 _("Dictionary Status was marked as 'stable'"));
cell("big enough to be useful",
 _("Dictionary Status was marked as 'big enough to be useful' (from 10000 entries on)"));
cell("too small",
 _("Dictionary Status was marked as 'too small' (less than 1000 entries)"));
cell("low quality",
 _("Dictionary Status was marked as 'low quality'"));
cell("unknown",
 _("Dictionary Status was not given or is 'unknown'"));

?>
</table>
<p><?php echo _("The numbers for the platform downloads represent the download
  sizes in Megabytes.") .' '. _("A small 'u' instead of a download link means
  that the respective dictionary is not supported on that platform.") .' '.
  _("This is currently always due to characters of the dictionary not being
  encodable or displayable for/on the platform.") ?></p>

