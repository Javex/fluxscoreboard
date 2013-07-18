<?php

require_once('../manager.php');
include("html/header.php");

if (isset($_POST['from']) && isset($_POST['subject']) && isset($_POST['message']))
{
	echo '<b>' . send_mail($_POST['from'], $_POST['subject'], $_POST['message']) . '</b>';
} 

?>
<form action="massmail.php" method="post">
	<input type="text" name="from" placeholder="from" value="<?= @htmlspecialchars($_POST['from']) ?>" /><br />
	<input type="text" name="subject" placeholder="subject" value="<?= @htmlspecialchars($_POST['subject']) ?>" /><br />
	<textarea name="message" rows="4" cols="50" placeholder="message"><?= @htmlspecialchars($_POST['message']) ?></textarea><br />
	<button type="submit">Send</button>
</form>
<?php

include("html/footer.php");

?>

