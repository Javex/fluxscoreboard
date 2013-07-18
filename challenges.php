<?php

require_once('manager.php');

if (!is_logged_in())
{
	header("Location: index.php");
	exit;
}

include('html/header.php');

?>
<table class="tablesorter {sortlist: [[4,1], [0,0]]}" id="challenges" cellspacing="1">
	<thead>
		<tr>
			<th class="{sorter: 'digit'}">#</th>
			<th class="{sorter: 'text'}">Title</th>
			<th class="{sorter: 'digit'}">Points</th>
			<th class="{sorter: 'digit'}">Solved</th>
			<th class="{sorter: 'text'}">Status</th>
		</tr>
	</thead>
	<tbody>
<?php

$challenges = get_challenges();
$solved_challenges = get_solved_challenges();

foreach ($challenges as $challenge)
{
	$manual = (int)$challenge['manual'];
	$points = $manual ? 'evaluated' : (int)$challenge['points'];
	$status = ((int)$challenge["status"] == 1) ? '<span class="online">online</span>' : '<span class="offline">offline</span>';
	$solved = isset($solved_challenges[$challenge['cid']]);
	$title = ((int)$challenge["status"] == 1) ? '<a href="challenge.php?id=' . htmlspecialchars($challenge['cid']) . '">' . htmlspecialchars($challenge['title']) . '</a>' : htmlspecialchars($challenge['title']);


	echo '<tr>'
	. '<td>' . htmlspecialchars($challenge['cid']) . '</td>'
	. '<td' . ($solved ? ' class="solved"' : '') . '>' . $title . '</td>'
	. '<td>' . htmlspecialchars($points) . '</td>'
	. '<td>' . htmlspecialchars($challenge['solved']) . '</td>'
	. '<td>' . $status . '</td>' // Trusted
	. '</tr>';
}

?>
	</tbody>
</table>
<?php

include('html/footer.php');

?>

