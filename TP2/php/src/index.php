<?php

function hello()
{
    echo "Hello World !\n";
    $log = "Server is started";
    $fp = fopen("php://stdout", 'rw');
    fputs($fp, "$log\n");

    error_log("App is ready on http://localhost:80");
}

hello();
?>