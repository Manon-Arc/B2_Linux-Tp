<html>
<body>

Hellooooooooooooo <?php echo $_POST["name"]; ?> 🐈
<br>
Your email address is: <?php echo $_POST["email"]; ?>
<br>
Everything has been sent to database !  (maybe it will work, or maybe it will explode because you didn't configure the database :( )

<?php

$host = '10.5.1.211'; $user = 'SQL'; $password = 'azerty'; $db = 'app_nulle';
$conn = new mysqli($host,$user,$password,$db);
if(!$conn) {echo "Erreur de connexion à MSSQL<br />";}

$sql = 'INSERT INTO app_nulle (name, email) VALUES (?, ?)';
$conn->execute_query($sql, [$_POST["name"], $_POST["email"]]);
mysqli_close($conn);

?>
<br><br>
<input type="button" value="Home" onClick="document.location.href='/'" />
</body>
</html> 
