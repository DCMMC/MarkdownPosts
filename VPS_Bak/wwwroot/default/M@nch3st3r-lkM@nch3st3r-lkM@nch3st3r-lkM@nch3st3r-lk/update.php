<?php

//execute shell
#$confirm = $_GET["confirm"];

# if ($confirm == true) {
	passthru("whoami && sh /home/wwwroot/MarkdownPostsUpdateHook.sh");
#} else {
#	echo "confirm must be true!";
#}
