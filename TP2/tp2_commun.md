# TP2 Commun : Stack PHP

## Fichiers :

- [PHP](./php/) :
  - [conf](./php/conf/)
  - [SQL](./php/sql/)
  - [src](./php/src/)
- [Docker Compose](./php/docker-compose.yml)

```bash
C:\Users\Utilisateur\Documents\B2_info\linux\B2_TP-Linux\TP2\php> docker compose up
 ✔ Container php-php-1         Created                                                                                         0.0s 
 ✔ Container php-phpmyadmin-1  Created                                                                                         0.0s 
 ✔ Container php-mysql-1       Created                                                                                         0.0s 
Attaching to mysql-1, php-1, phpmyadmin-1
[...]
```

```bash
C:\Users\Utilisateur\Documents\B2_info\linux\B2_TP-Linux> docker ps
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS          PORTS                               NAMES
0211d62a56e3   php:8.3-apache      "docker-php-entrypoi…"   13 minutes ago   Up 29 seconds   0.0.0.0:80->80/tcp                  php-php-1
cebd2b20ea51   phpmyadmin:latest   "/docker-entrypoint.…"   2 hours ago      Up 29 seconds   0.0.0.0:8080->80/tcp                php-phpmyadmin-1
3a8f8eba126e   mysql:latest        "docker-entrypoint.s…"   2 hours ago      Up 29 seconds   0.0.0.0:3306->3306/tcp, 33060/tcp   php-mysql-1
```

```bash
C:\Users\Utilisateur\Documents\B2_info\linux\B2_TP-Linux> docker logs 0211d62a56e3

[Sat Dec 30 13:18:17.772206 2023] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.57 (Debian) PHP/8.3.0 configured -- resuming normal operations
[Sat Dec 30 13:18:17.772284 2023] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
[Sat Dec 30 13:19:00.792657 2023] [php:notice] [pid 17] [client 172.18.0.1:60440] App is ready on http://localhost:80
Server is started
```

```bash
PS C:\Users\Utilisateur> curl localhost


StatusCode        : 200
StatusDescription : OK
Content           : Hello World !

RawContent        : HTTP/1.1 200 OK
                    Keep-Alive: timeout=5, max=100
                    Connection: Keep-Alive
                    Content-Length: 14
                    Content-Type: text/html; charset=UTF-8
                    Date: Sat, 30 Dec 2023 13:34:01 GMT
                    Server: Apache/2.4.57 (Debian)...
Forms             : {}
Headers           : {[Keep-Alive, timeout=5, max=100], [Connection, Keep-Alive], [Content-Length, 14], [Content-Type, text/html; charset=UTF-8]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 14
```