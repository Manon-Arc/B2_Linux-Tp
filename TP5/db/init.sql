/*create the database*/

USE "app_nulle";

CREATE TABLE IF NOT EXISTS meo
  (
     id    INT NOT NULL auto_increment,
     name  VARCHAR(255) NOT NULL,
     email VARCHAR(255) NOT NULL,
     PRIMARY KEY (id)
  );