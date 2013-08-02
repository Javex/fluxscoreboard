<div id="login">	
	<form id="loginform" action="index.php" method="post">
		<input class="crew_field" type="text" name="name" placeholder="team" />
		<div class="clear"></div>
		<input class="pw_field" type="password" name="password" placeholder="password" />
		<div class="clear"></div>
		<button class="login_button" type="submit">Submit</button>
	</form>
	<div id="image_submit"></div>
<?php 

if (isset($_GET['loginfailed']) && is_string($_GET['loginfailed'])) 
{
	if($_GET['loginfailed'] == 1)
	{
		echo '<span class="login_error">Wrong login.</span>';
	}
	else if($_GET['loginfailed'] == 2)
	{
		echo '<span class="login_error">Please login.</span>';
	}
}

?>
</div>
<script type="text/javascript" src="http://braaaains.hack.lu/bloody.js"></script>	
