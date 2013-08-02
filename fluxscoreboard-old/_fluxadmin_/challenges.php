<?php

require_once('../manager.php');
include("html/header.php");

?>

<h2>challenges</h2>

<?php
	// do stuff
	if(!empty($_GET['delete']))
	{
		echo deleteChallenge($_GET['delete']);
	}

	if(isset($_GET['status']))
	{
		echo statusChallenge($_GET['cid'], $_GET['status']);
	}	
	
	if(!empty($_POST['insert']))
	{
		echo insertChallenge($_POST['title'], $_POST['text'], $_POST['solution'], $_POST['points']);
	}

	if(!empty($_POST['update']))
	{
		echo updateChallenge($_POST['cid'], $_POST['title'], $_POST['text'], $_POST['solution'], $_POST['points']);
	}
	
?>
	
	<table>
		<tr>
			<th>cid</th>
			<th>title</th>
			<th>solution</th>
			<th>points</th>	
			<th>manual</th>		
			<th>status</th>
			<th>options</th>
		</tr>
		
<?php		
	// list challenges
	$result = mysql_query("SELECT cid, title, solution, points, status, manual FROM challenges ORDER BY cid");

	for($i=0; $i<mysql_num_rows($result); $i++)
	{
		if(!($row = mysql_fetch_array($result)))
		{
			die("Error loading challenges data.");
		}
		
		$cid = (int)$row["cid"];
		$title = htmlentities($row["title"], ENT_QUOTES, 'utf-8');
		$solution = htmlentities($row["solution"], ENT_QUOTES, 'utf-8');
		$points = (int)$row["points"];
		$status = ((int)$row["status"] == 1) ? 'online' : 'offline';
		$class = ((int)$row["status"] == 1) ? 'success' : 'error';
		$manual = (int)$row["manual"] ? 'x' : '-';
		
		
		echo "<tr><td align=\"right\">$cid</td><td>$title</td><td>$solution</td><td align=\"right\">$points</td><td align=\"center\">$manual</td><td align=\"center\"><span class=\"$class\">$status</span></td><td><a href=\"challenges.php?edit=$cid\">edit</a>, <a href=\"challenges.php?status=",(int)(!$row["status"]),"&cid=$cid\" onClick=\"return confirm('Are you sure you want to change the status of challenge $cid? This will also affect the ability to submit a solution for this challenge. Already awarded points will stay.');\">status</a>, <a href=\"challenges.php?delete=$cid\" onClick=\"return confirm('Are you sure you want to delete challenge $cid? This will also delete all points previously awarded for this challenge.');\">delete</a></td></tr>";
	}
?>

</table>

<br />

<?php

	// edit challenge form
	if(!empty($_GET['edit']) && is_numeric($_GET['edit']))
	{

		$cid = (int)$_GET['edit'];

		$result = mysql_query("SELECT title, text, solution, points FROM challenges WHERE cid = $cid");

		if(!($row = mysql_fetch_array($result)))
		{
			die("Error loading challenge data.");
		}
	
		$title = htmlentities($row["title"], ENT_QUOTES, 'utf-8');
		$text = htmlentities($row["text"], ENT_QUOTES, 'utf-8');
		$solution = htmlentities($row["solution"], ENT_QUOTES, 'utf-8');
		$points = (int)$row["points"];

?>

<b>update challenge <?php echo $cid; ?>:</b><br>
<form action="challenges.php" method="POST">
<input type="hidden" name="cid" value="<?php echo $cid; ?>" />
<table>
	<tr><td>title:</td><td><input type="text" name="title" size="30" value="<?php echo $title; ?>" /></td></tr>
	<tr><td>text:</td><td><textarea name="text" rows="4" cols="25"><?php echo $text; ?></textarea></td></tr>
	<tr><td>solution:</td><td><input type="text" size="30" name="solution" value="<?php echo $solution; ?>" /></td></tr>
	<tr><td>points:</td><td><input type="text" size="10" name="points" value="<?php echo $points; ?>" /></td></tr>
	<tr><td></td><td><small>points = 0: only manual submissions by admins are allowed.</small></td></tr>
	<tr><td align="right" colspan="2"><input type="submit" name="update" value="update"></td></tr>
</table>
</form>

<?php
	// new challenge form
	} else {
?>

<b>add new challenge (starts offline):</b><br>
<form action="challenges.php" method="post">
<table>
	<tr><td>title:</td><td><input type="text" name="title" size="30" /></td></tr>
	<tr><td>text:</td><td><textarea name="text" rows="4" cols="25"></textarea></td></tr>
	<tr><td>solution:</td><td><input type="text" size="30" name="solution" /></td></tr>
	<tr><td>points:</td><td><input type="text" size="10" name="points" /></td></tr>
	<tr><td></td><td><small>points = 0: only manual submissions by admins are allowed.</small></td></tr>
	<tr><td align="right" colspan="2"><input type="submit" name="insert" value="add" /></td></tr>
</table>
</form>

<?php
	}

	include("html/footer.php");
?>
