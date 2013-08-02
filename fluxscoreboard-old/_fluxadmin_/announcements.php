<?php

require_once('../manager.php');
include("html/header.php");

?>

<h2>announcements</h2>

<?php
	// do stuff
	if(!empty($_GET['delete']))
	{
		echo deleteAnnouncement($_GET['delete']);
	}

	if(!empty($_POST['insert']))
	{
		echo insertAnnouncement($_POST['message']);
	}

?>

	<table>
		<tr>
			<th>id</th>
			<th>time</th>
			<th>message</th>
			<th>options</th>
		</tr>
	
<?php	

	// list submissions
	$result = mysql_query("SELECT id, timestamp, message FROM news ORDER BY timestamp DESC");

	for($i=0; $i<mysql_num_rows($result); $i++)
	{
		if(!($row = mysql_fetch_array($result)))
		{
			die("Error loading submission data.");
		}
		
		$id = (int)$row["id"];
		$timestamp = htmlentities($row['timestamp'], ENT_QUOTES, 'utf-8');
		$message = htmlentities($row['message'], ENT_QUOTES, 'utf-8');

		echo "<tr><td>$id</td><td>$timestamp</td><td>$message</td><td><a href=\"announcements.php?delete=$id\" onClick=\"return confirm('Are you sure you want to delete announcement $id?');\">delete</a></td></tr>";
	}
?>

</table>

<br />

<b>add new announcement:</b><br>
<form action="announcements.php" method="post">
<table>
	<tr><td><textarea name="message" cols="30" rows="5"></textarea></td></tr>
	<tr><td align="right" colspan="2"><input type="submit" name="insert" value="add" /></td></tr>
</table>
</form>

<?php

	include("html/footer.php");
?>
