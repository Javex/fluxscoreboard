<?php

require_once('manager.php');

if (!is_logged_in())
{
	header("Location: index.php");
	exit;
}

if (!isset($_GET['id']) || empty($_GET['id']) || !is_numeric($_GET['id']))
{
	$_GET['id'] = 0;
}

$cid = (int)$_GET['id'];
$challenge = get_challenge($cid);

$title = $challenge['title'];
$text = $challenge['text'];
$points = (int)$challenge['points'];
$manual = (int)$challenge['manual'];


if ($challenge === false)
{
	exit('No wayz, braw');
}

include('html/header.php');

?>
<div class="blood">
	<table id="challenge" cellspacing="0" cellpadding="0">
		<tr>
			<td class="papertop"></td>
		</tr>
		<tr>
			<td class="papermiddle">
				<table align="center">
					<tr>
						<td><h2><?= $cid . ' - ' . $title ?></h2></td>
					</tr>
					<tr>
						<td valign="top" class="papertext"><?= $text ?></td>
					</tr>
					<tr>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td>
							<p><b>credits:</b> <?= $manual ? 'manually evaluated - no time bonus.' : $points . ' +3 (1st), +2 (2nd), +1 (3rd)' ?></p>
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class="paperbottom"></td>
		</tr>
	</table>
</div>
<?php

include("html/footer.php");

?>
