<?php

require_once('manager.php');

if (!is_logged_in())
{
	header("Location: index.php");
	exit;
}

include('html/header.php');

?>
<div id="submit">
	<form method="post" action="submit.php">
		<select id="challenge" name="cid">

<?php

$challenges = get_challenges();

foreach ($challenges as $challenge)
{
	if (($challenge['status'] == 0) || ($challenge['manual'] == 1))
	{ // Skip offline and manual challenges
		continue;
	}

	echo '<option value="' . htmlspecialchars($challenge['cid']) . '">' . htmlspecialchars($challenge['cid']) . ' - ' . htmlspecialchars($challenge['title']) . '</option>';
}

?>
		</select>
		<div class="clear"></div>
		<input class="solution" type="text" name="solution" placeholder="solution" />
		<div class="clear"></div>
		<button class="flagsubmit" type="submit">Send</button>
</form>
<?php

if (isset($_POST['cid']) && isset($_POST['solution']))
{
	echo '<span class="submit_status">' . htmlspecialchars(check_submission($_POST['cid'], $_POST['solution'])) . '</span>';
}

include('html/footer.php');

?>
