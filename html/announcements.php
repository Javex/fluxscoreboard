<?php

$announcements = get_announcements();

?>
<div class="blood">
	<table id="announcements" cellspacing="0" cellpadding="0">
		<tr>
			<td class="papertop"></td>
		</tr>
		<tr>
			<td class="papermiddle">
<?php

foreach($announcements as $announcement)
{

?>
				<table align="center">
					<tr>
						<td><h2><?= htmlspecialchars($announcement['timestamp']) ?></h2></td>
					</tr>
					<tr>
						<td valign="top" class="papertext"><?= htmlspecialchars($announcement['message']) ?></td>
					</tr>
				</table>
<?php

}

?>
			</td>
		</tr>
		<tr>
			<td class="paperbottom"></td>
		</tr>
	</table>
</div>
