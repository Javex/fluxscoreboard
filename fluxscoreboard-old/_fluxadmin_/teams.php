<?php

require_once('../manager.php');
include('html/header.php');

if (!empty($_GET['delete']))
{
	echo delete_team($_GET['delete']);
}

if (!empty($_POST['insert']))
{
	echo register_team($_POST['name'], $_POST['password'], $_POST['password'], $_POST['email'], $_POST['location']);
}

if (!empty($_POST['update']))
{
	echo update_team($_POST['tid'], $_POST['name'], $_POST['password'], $_POST['email'], $_POST['location']);
}

$teams = get_teams();
$states = get_states();

?>

<table>
	<thead>
		<tr>
			<th>tid</th>
			<th>name</th>
			<th>edit</th>
			<th>delete</th>
		</tr>
	</thead>
	<tbody>
<?php

foreach ($teams as $team)
{
	echo '<tr>'
	. '<td>' . htmlspecialchars($team['tid']) . '</td>'
	. '<td>' . htmlspecialchars($team['teamname']) . '</td>'
	. '<td><a href="teams.php?edit=' . htmlspecialchars($team['tid']) . '">edit</a></td>'
	. '<td><a href="teams.php?delete=' . htmlspecialchars($team['tid']) . '" onClick="return confirm(\'Rly?\');">delete</a></td>'
	. '</tr>';
}

?>
	</tbody>
</table>
<br />
<?php

if(isset($_GET['edit']) && is_numeric($_GET['edit']))
{
	$team = get_team($_GET['edit']);

?>
<b>edit team:</b><br>
<form method="post">
	<input type="text" name="name" placeholder="Team name ..." value="<?= htmlspecialchars($team['teamname']) ?>" /><br />
	<input type="password" name="password" value="" placeholder="Password ..." /><br />
	<input type="text" name="email" placeholder="Email ..." value="<?= htmlspecialchars($team['email']) ?>" /><br />
	<select name="location">
<?php

foreach ($states as $state)
{
	$selected = ($state['id'] === $team['state']) ? 'selected="selected"' : '';
	echo '<option ' . $selected . ' value="' . htmlspecialchars($state['id']) . '">' . htmlspecialchars($state['name']) . '</option>' . "\n";
}

?>
	</select><br />
	<button type="submit" name="update" value="1">Edit</button>
	<input type="hidden" name="tid" value="<?= htmlspecialchars($_GET['edit']) ?>" />
</form>

<?php

}
else
{

?>
<b>add new team:</b><br>
<form method="post">
	<input type="text" name="name" placeholder="Team name ..." /><br />
	<input type="password" name="password" value="" placeholder="Password ..." /><br />
	<input type="text" name="email" placeholder="Email ..." /><br />
	<select name="location">
<?php

foreach ($states as $state)
{
	echo '<option value="' . htmlspecialchars($state['id']) . '">' . htmlspecialchars($state['name']) . '</option>' . "\n";
}

?>
	</select><br />
	<button type="submit" name="insert" value="1">Add</button>
</form>

<?php

}

include('html/footer.php');

?>
