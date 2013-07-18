<?php

session_start();
define('FULL_PATH', '/var/www');
define('CID_BEERCHALLENGE', 8);
define('DISABLE_SUBMISSION', false);

require_once(FULL_PATH . '/includes/dbconnect.php');
require_once(FULL_PATH . '/includes/functions_auth.php');
require_once(FULL_PATH . '/includes/functions_teams.php');
require_once(FULL_PATH . '/includes/functions_challenges.php');
require_once(FULL_PATH . '/includes/functions_announcements.php');
require_once(FULL_PATH . '/includes/functions_mail.php');

?>
