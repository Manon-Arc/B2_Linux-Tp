<html>
<body>

Hellooooooooooooo <?php echo $_POST["name"]; ?> 🐈
<br>
Your email address is: <?php echo $_POST["email"]; ?>
<br>
Everything has been sent to database !  (maybe it will work, or maybe it will explode because you didn't configure the database :( )

<?php

$host = 'db1.tp5.b2'; $user = 'SQL'; $password = 'azerty'; $db = 'app_nulle';

$conn = new mysqli($host,$user,$password,$db);

//if(!$conn) {echo "Erreur de connexion à MSSQL<br />";}

$sql = $conn->prepare('INSERT INTO meo (name, email) VALUES (?, ?)');
$sql->bind_param($_POST["name"], $_POST["email"]);
$sql->execute();

/*$conn->execute_query($sql, [$_POST["name"], $_POST["email"]]);
mysqli_close($conn);*/

?>
<br><br>
<input type="button" value="Home" onClick="document.location.href='/'" />
</body>
</html> 
