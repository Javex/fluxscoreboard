<?php

require_once('manager.php');
include("html/header.php");

?>
<table class="tablesorter {sortlist: [[0,0], [1,0]]}" cellspacing="1">
	<thead>
		<tr>
			<th class="{sorter: 'digit'}">#</th>
			<th class="{sorter: 'text'}">Team</th>
			<th class="{sorter: 'text'}">Location</th>
			<th class="{sorter: 'text'}">Local</th>
<?php

$challenges = get_challenges();

foreach ($challenges as $challenge)
{
	if ($challenge["status"] == 0)
	{ // Skip offline challenges
		continue;
	}

	echo '<th title="' . htmlspecialchars($challenge['title']) . '" class="challenge {sorter: \'digit\'}"># ' . htmlspecialchars($challenge['cid']) . '</th>';
}

?>
			<th class="{sorter: 'digit'}">Total</th>
		</tr>
	</thead>
	<tbody>
<?php

$teams = get_teams();

foreach ($teams as $team)
{
	$local = ($team['local']) ? 'yes' : 'no';

	echo '<tr>'
	. '<td>' . htmlspecialchars($team['rank']) . '</td>'
	. '<td>' . htmlspecialchars($team['teamname']) . '</td>'
	. '<td>' . htmlspecialchars($team['state']) . '</td>'
	. '<td>' . htmlspecialchars($local) . '</td>';

	foreach ($challenges as $challenge)
	{
		if ($challenge["status"] == 0)
		{ // Skip offline challenges
			continue;
		}

		if (isset($team['solved'][$challenge['cid']]))
		{ // Solved
			if ($challenge['cid'] == CID_BEERCHALLENGE)
			{
				echo '<td class="beerhero"><img src="images/beerhero.gif" alt="beerhero" /></td>';
			}
			else
			{
				echo '<td>' . htmlspecialchars($challenge['points'] + $team['solved'][$challenge['cid']]) . '</td>';
			}
		}
		else
		{ // Not solved
			echo '<td></td>';
		}
	}

	echo '<td>' . htmlspecialchars($team['score']) . '</td>'
	. '</tr>';
}

?>
	</tbody>
</table>
<?php

include("html/footer.php");

?>
