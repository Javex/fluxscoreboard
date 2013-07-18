<?php

require_once('../manager.php');
include("html/header.php");

?>

<h2>submissions</h2>

<?php
	// do stuff
	if(!empty($_GET['delete']))
	{
		echo deleteSubmission($_GET['delete']);
	}

	if(!empty($_POST['insert']))
	{
		echo insertSubmission($_POST['teamid'], $_POST['challid'], $_POST['bonus']);
	}

	if(!empty($_POST['update']))
	{
		echo updateSubmission($_POST['sid'], $_POST['teamid'], $_POST['challid'], $_POST['timestamp'], $_POST['bonus']);
	}
?>

	<table>
		<tr>
			<th>sid</th>
			<th>team (tid)</th>
			<th>challenge (cid)</th>
			<th>timestamp</th>
			<th>points</th>
			<th>options</th>
		</tr>
	
<?php	

	// list submissions
	$result = mysql_query("SELECT submissions.sid, submissions.teamid, teams.name, submissions.challid, challenges.title, submissions.timestamp, submissions.bonus, challenges.points FROM submissions,teams,challenges WHERE submissions.teamid = teams.tid AND submissions.challid = challenges.cid ORDER BY sid DESC");

	for($i=0; $i<mysql_num_rows($result); $i++)
	{
		if(!($row = mysql_fetch_array($result)))
		{
			die("Error loading submission data.");
		}
		
		$sid = (int)$row["sid"];
		$teamid = (int)$row["teamid"];
		$teamname = htmlentities($row["name"], ENT_QUOTES, 'utf-8');
		$challid = (int)$row["challid"];
		$challtitle = htmlentities($row["title"], ENT_QUOTES, 'utf-8');
		$timestamp = htmlentities($row["timestamp"], ENT_QUOTES, 'utf-8');
		$points = (int)$row["points"] + (int)$row["bonus"];

		echo "<tr><td>$sid</td><td>$teamname ($teamid)</td><td>$challtitle ($challid)</td><td>$timestamp</td><td>$points</td><td><a href=\"submissions.php?edit=$sid\">edit</a>, <a href=\"submissions.php?delete=$sid\" onClick=\"return confirm('Are you sure you want to delete submission $sid?');\">delete</a></td></tr>";
	}
?>

</table>

<br />

<?php

	// edit challenge form
	if(!empty($_GET['edit']) && is_numeric($_GET['edit']))
	{

		$sid = (int)$_GET['edit'];

		$result = mysql_query("SELECT teamid, challid, FROM_UNIXTIME(timestamp) AS timestamp, bonus FROM submissions WHERE sid = $sid");

		if(!($row = mysql_fetch_array($result)))
		{
			die("Error loading submission data.");
		}

		$teamid = (int)$row["teamid"];
		$challid = (int)$row["challid"];
		$timestamp = htmlentities($row["timestamp"], ENT_QUOTES, 'utf-8');
		$bonus = (int)$row["bonus"];

?>

<b>update submission <?php echo $sid; ?>:</b><br>
<form action="submissions.php" method="POST">
<input type="hidden" name="sid" value="<?php echo $sid; ?>" />
<table>
	<tr><td>teamid:</td><td><input type="text" name="teamid" size="10" value="<?php echo $teamid; ?>" /></td></tr>
	<tr><td>challid:</td><td><input type="text" name="challid" size="10" value="<?php echo $challid; ?>" /></td></tr>
	<tr><td>timestamp:</td><td><input type="text" name="timestamp" size="10" value="<?php echo $timestamp; ?>" /></td></tr>
	<tr><td>bonus:</td><td><input type="text" name="bonus" size="10" value="<?php echo $bonus; ?>" /></td></tr>
	<tr><td align="right" colspan="2"><input type="submit" name="update" value="update"></td></tr>
</table>
</form>


<?php
	// new challenge form
	} else {
?>

<b>add new submission:</b><br>
<form action="submissions.php" method="post">
<table>
	<tr><td>teamid:</td><td><input type="text" size="10" name="teamid"/></td></tr>
	<tr><td>challid:</td><td><input type="text" size="10" name="challid" /></td></tr>
	<tr><td>bonus:</td><td><input type="text" size="10" name="bonus" value="0" /></td></tr>
	<tr><td align="right" colspan="2"><input type="submit" name="insert" value="add" /></td></tr>
</table>
</form>

<?php
	}

	include("html/footer.php");
?>
