<?php

function send_mail($from, $subject, $message)
{
	if (empty($from))
	{
		return "Error: From empty";
	}

	if (empty($subject))
	{
		return "Error: Subject empty";
	}

	if (empty($message))
	{
		return "Error: Message empty";
	}

	$headers = 'From: ' . $from . "\r\n" . 'Reply-To: ' . $from . "\r\n" . 'X-Mailer: PHP/FiddlersGreen';


	$to = "emperorlama@gmail.com";
	mail($to, $subject, $message, $headers);

	return "Success: Message sent";
}

?>
