# TP1 : Premiers pas Docker

Dans ce TP on va appréhender les bases de Docker.

Etant fondamentalement une techno Linux, **vous réaliserez le TP sur une VM Linux** (ou sur votre poste si vous êtes sur Linux).

## Sommaire

- [TP1 : Premiers pas Docker](#tp1--premiers-pas-docker)
  - [Sommaire](#sommaire)
- [0. Setup](#0-setup)
- [I. Init](#i-init)
- [II. Images](#ii-images)
- [III. Docker compose](#iii-docker-compose)

# 0. Setup

➜ **Munissez-vous du [mémo Docker](../../cours/memo/docker.md)**

➜ **Une VM Rocky Linux sitoplé, une seul suffit**

- met lui une carte host-only pour pouvoir SSH dessus
- et une carte NAT pour un accès internet

➜ **Checklist habituelle :**

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] SSH fonctionnel
- [x] accès Internet
- [x] résolution de nom
- [x] SELinux en mode *"permissive"* vérifiez avec `sestatus`, voir [mémo install VM tout en bas](../../cours/memo/install_vm.md)

# I. Init

- [I. Init](#i-init)
  - [1. Installation de Docker](#1-installation-de-docker)
  - [2. Vérifier que Docker est bien là](#2-vérifier-que-docker-est-bien-là)
  - [3. sudo c pa bo](#3-sudo-c-pa-bo)
  - [4. Un premier conteneur en vif](#4-un-premier-conteneur-en-vif)
  - [5. Un deuxième conteneur en vif](#5-un-deuxième-conteneur-en-vif)

## 1. Installation de Docker

Pour installer Docker, il faut **toujours** (comme d'hab en fait) se référer à la doc officielle.

**Je vous laisse donc suivre les instructions de la doc officielle pour installer Docker dans la VM.**

> ***Il n'y a pas d'instructions spécifiques pour Rocky dans la doc officielle**, mais rocky est très proche de CentOS. Vous pouvez donc suivre les instructions pour CentOS 9.*

## 2. Vérifier que Docker est bien là

```bash
# est-ce que le service Docker existe ?
[manon@tp1-linux ~]$ systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; preset: disabled)
     Active: active (running) since Thu 2023-12-21 10:51:53 CET; 1min 35s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 20074 (dockerd)
      Tasks: 10
     Memory: 38.4M
        CPU: 387ms
     CGroup: /system.slice/docker.service
             └─20074 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Dec 21 10:51:52 tp1-linux systemd[1]: Starting Docker Application Container Engine...
Dec 21 10:51:52 tp1-linux dockerd[20074]: time="2023-12-21T10:51:52.108888515+01:00" level=info msg="Starting up"
Dec 21 10:51:52 tp1-linux dockerd[20074]: time="2023-12-21T10:51:52.180228733+01:00" level=info msg="Loading containers: start."
Dec 21 10:51:53 tp1-linux dockerd[20074]: time="2023-12-21T10:51:53.113599445+01:00" level=info msg="Firewalld: interface docker0 already part of docker zone, returning"
Dec 21 10:51:53 tp1-linux dockerd[20074]: time="2023-12-21T10:51:53.281664214+01:00" level=info msg="Loading containers: done."
Dec 21 10:51:53 tp1-linux dockerd[20074]: time="2023-12-21T10:51:53.304347166+01:00" level=info msg="Docker daemon" commit=311b9ff graphdriver=overlay2 version=24.0.7
Dec 21 10:51:53 tp1-linux dockerd[20074]: time="2023-12-21T10:51:53.304775415+01:00" level=info msg="Daemon has completed initialization"
Dec 21 10:51:53 tp1-linux dockerd[20074]: time="2023-12-21T10:51:53.355787494+01:00" level=info msg="API listen on /run/docker.sock"
Dec 21 10:51:53 tp1-linux systemd[1]: Started Docker Application Container Engine.
```
```bash
# si oui, on le démarre alors
[manon@tp1-linux ~]$ sudo systemctl start docker
```
```bash
# voyons si on peut taper une commande docker
[manon@tp1-linux ~]$ sudo docker info
Client: Docker Engine - Community
 Version:    24.0.7
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.11.2
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.21.0
    Path:     /usr/libexec/docker/cli-plugins/docker-compose

Server:
 Containers: 1
  Running: 0
  Paused: 0
  Stopped: 1
 Images: 1
 Server Version: 24.0.7
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
  Using metacopy: false
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: systemd
 Cgroup Version: 2
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 3dd1e886e55dd695541fdcd67420c2888645a495
 runc version: v1.1.10-0-g18a0cb0
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
  cgroupns
 Kernel Version: 5.14.0-362.8.1.el9_3.x86_64
 Operating System: Rocky Linux 9.3 (Blue Onyx)
 OSType: linux
 Architecture: x86_64
 CPUs: 1
 Total Memory: 1.723GiB
 Name: tp1-linux
 ID: 8e894798-2f3a-41fd-b302-8061add17a5f
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false
```
```bash
[manon@tp1-linux ~]$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## 3. sudo c pa bo

On va faire en sorte que vous puissiez taper des commandes `docker` sans avoir besoin des droits `root`, et donc de `sudo`.

Pour ça il suffit d'ajouter votre utilisateur au groupe `docker`.

> ***Pour que le changement de groupe prenne effet, il faut vous déconnecter/reconnecter de la session SSH** (pas besoin de reboot la machine, pitié).*

🌞 **Ajouter votre utilisateur au groupe `docker`**

```bash
[manon@tp1-linux ~]$ sudo usermod -a -G docker manon

[manon@tp1-linux ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

➜ Vous pouvez même faire un `alias` pour `docker`

```bash
[manon@tp1-linux ~]$ alias dk='docker' >> ~/.bashrc
[manon@tp1-linux ~]$ dk ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## 4. Un premier conteneur en vif

On va lancer un conteneur NGINX qui juste fonctionne, puis custom un peu sa conf. Ce serait par exemple pour tester une conf NGINX, ou faire tourner un serveur NGINX de production.

🌞 **Lancer un conteneur NGINX**

- avec la commande suivante :

```bash
docker run -d -p 9999:80 nginx

[manon@tp1-linux ~]$ docker run -d -p 9999:80 nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
af107e978371: Pull complete
336ba1f05c3e: Pull complete
8c37d2ff6efa: Pull complete
51d6357098de: Pull complete
782f1ecce57d: Pull complete
5e99d351b073: Pull complete
7b73345df136: Pull complete
Digest: sha256:bd30b8d47b230de52431cc71c5cce149b8d5d4c87c204902acf2504435d4b4c9
Status: Downloaded newer image for nginx:latest
9850b48551d114670639c5e5387401f5b01886ed772da2022f396e55b607d23c
```

> Si tu mets pas le `-d` tu vas perdre la main dans ton terminal, et tu auras les logs du conteneur directement dans le terminal. `-d` comme *daemon* : pour lancer en tâche de fond. Essaie pour voir !

🌞 **Visitons**

- vérifier que le conteneur est actif avec une commande qui liste les conteneurs en cours de fonctionnement
```bash
[manon@tp1-linux ~]$ dk ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                   NAMES
9850b48551d1   nginx     "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   0.0.0.0:9999->80/tcp, :::9999->80/tcp   gifted_faraday
```
- afficher les logs du conteneur
```bash
[manon@tp1-linux ~]$ docker logs 9850b48551d1
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/12/21 10:10:45 [notice] 1#1: using the "epoll" event method
2023/12/21 10:10:45 [notice] 1#1: nginx/1.25.3
2023/12/21 10:10:45 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2023/12/21 10:10:45 [notice] 1#1: OS: Linux 5.14.0-362.8.1.el9_3.x86_64
2023/12/21 10:10:45 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1073741816:1073741816
2023/12/21 10:10:45 [notice] 1#1: start worker processes
2023/12/21 10:10:45 [notice] 1#1: start worker process 29
```
- afficher toutes les informations relatives au conteneur avec une commande `docker inspect`
```bash
[manon@tp1-linux ~]$ docker inspect 9850b48551d
[
    {
        "Id": "9850b48551d114670639c5e5387401f5b01886ed772da2022f396e55b607d23c",
        "Created": "2023-12-21T10:10:45.261396904Z",
        "Path": "/docker-entrypoint.sh",
        "Args": [
            "nginx",
            "-g",
            "daemon off;"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 20585,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2023-12-21T10:10:45.897215712Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },

[...]

            "SandboxKey": "/var/run/docker/netns/7f145925e75a",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "bb89504efe5d34bfcd50db605cd2071bfa0a5d1baad22f345821852433927206",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "009dfaf0c3f4b2db31fba49d874958ce687b966778234db2ffc77b3a686a0e0e",
                    "EndpointID": "bb89504efe5d34bfcd50db605cd2071bfa0a5d1baad22f345821852433927206",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }
    }
]        
```
- afficher le port en écoute sur la VM avec un `sudo ss -lnpt`
```bash
[manon@tp1-linux ~]$ sudo ss -lnpt | grep docker
LISTEN 0      4096         0.0.0.0:9999      0.0.0.0:*    users:(("docker-proxy",pid=20544,fd=4))
LISTEN 0      4096            [::]:9999         [::]:*    users:(("docker-proxy",pid=20550,fd=4))
```
- ouvrir le port `9999/tcp` (vu dans le `ss` au dessus normalement) dans le firewall de la VM
```bash
[manon@tp1-linux ~]$ sudo firewall-cmd --add-port=9999/tcp --permanent
success
[manon@tp1-linux ~]$ sudo firewall-cmd --reload
success
```
- depuis le navigateur de votre PC, visiter le site web sur `http://IP_VM:9999`

```bash
[manon@tp1-linux ~]$ curl http://10.5.1.18:9999
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

➜ On peut préciser genre mille options au lancement d'un conteneur, **go `docker run --help` pour voir !**

➜ Hop, on en profite pour voir un truc super utile avec Docker : le **partage de fichiers au moment où on `docker run`**

- en effet, il est possible de partager un fichier ou un dossier avec un conteneur, au moment où on le lance
- avec NGINX par exemple, c'est idéal pour déposer un fichier de conf différent à chaque conteneur NGINX qu'on lance
  - en plus NGINX inclut par défaut tous les fichiers dans `/etc/nginx/conf.d/*.conf`
  - donc suffit juste de drop un fichier là-bas
- ça se fait avec `-v` pour *volume* (on appelle ça "monter un volume")

> *C'est aussi idéal pour créer un conteneur qui setup un environnement de dév par exemple. On prépare une image qui contient Python + les libs Python qu'on a besoin, et au moment du `docker run` on partage notre code. Ainsi, on peut dév sur notre PC, et le code s'exécute dans le conteneur. On verra ça plus tard les dévs !*

🌞 **On va ajouter un site Web au conteneur NGINX**

- créez un dossier `nginx`
  - pas n'importe où, c'est ta conf caca, c'est dans ton homedir donc `/home/<TON_USER>/nginx/`
- dedans, deux fichiers : `index.html` (un site nul) `site_nul.conf` (la conf NGINX de notre site nul)
- exemple de `index.html` :

```bash
[manon@tp1-linux ~]$ sudo cat /home/manon/nginx/index.html
<h1>MEOOOW</h1>
```
```bash
[manon@tp1-linux ~]$ sudo cat /home/manon/nginx/site_nul.conf
server {
    listen        8080;

    location / {
        root /var/www/html/index.html;
    }
}
```

- lancez le conteneur avec la commande en dessous, notez que :
  - on partage désormais le port 8080 du conteneur (puisqu'on l'indique dans la conf qu'il doit écouter sur le port 8080)
  - on précise les chemins des fichiers en entier
  - note la syntaxe du `-v` : à gauche le fichier à partager depuis ta machine, à droite l'endroit où le déposer dans le conteneur, séparés par le caractère `:`

```bash
docker run -d -p 9999:8080 -v /home/<USER>/nginx/index.html:/var/www/html/index.html -v /home/<USER>/nginx/site_nul.conf:/etc/nginx/conf.d/site_nul.conf nginx
```

```bash
[manon@tp1-linux ~]$ dk run -d -p 9999:8080 -v /home/manon/nginx/index.html:/var/www/html/index.html -v /home/manon/nginx/site_nul.conf:/etc/nginx/conf.d/site_nul.conf nginx
254f5d67e98c1b952615d6a93adfe745778441cb596b8f479726b5d0772d172e
```

🌞 **Visitons**

- vérifier que le conteneur est actif
```bash
[manon@tp1-linux ~]$ dk ps
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS                                               NAMES
254f5d67e98c   nginx     "/docker-entrypoint.…"   About a minute ago   Up About a minute   80/tcp, 0.0.0.0:9999->8080/tcp, :::9999->8080/tcp   fervent_pike
```
- aucun port firewall à ouvrir : on écoute toujours port 9999 sur la machine hôte (la VM)
- visiter le site web depuis votre PC
```bash
[manon@tp1-linux ~]$ curl http://10.5.1.18:9999
<h1>MEOOOW</h1>
```

## 5. Un deuxième conteneur en vif

Cette fois on va lancer un conteneur Python, comme si on voulait tester une nouvelle lib Python par exemple. Mais sans installer ni Python ni la lib sur notre machine.

On va donc le lancer de façon interactive : on lance le conteneur, et on pop tout de suite un shell dedans pour faire joujou.

🌞 **Lance un conteneur Python, avec un shell**

- il faut indiquer au conteneur qu'on veut lancer un shell
- un shell c'est "interactif" : on saisit des trucs (input) et ça nous affiche des trucs (output)
  - il faut le préciser dans la commande `docker run` avec `-it`
- ça donne donc :

```bash
# on lance un conteneur "python" de manière interactive
# et on demande à ce conteneur d'exécuter la commande "bash" au démarrage
docker run -it python bash
```

> *Ce conteneur ne vit (comme tu l'as demandé) que pour exécuter ton `bash`. Autrement dit, si ce `bash` se termine, alors le conteneur s'éteindra. Autrement diiiit, si tu quittes le `bash`, le processus `bash` va se terminer, et le conteneur s'éteindra. C'est vraiment un conteneur one-shot quoi quand on utilise `docker run` comme ça.*

🌞 **Installe des libs Python**

- une fois que vous avez lancé le conteneur, et que vous êtes dedans avec `bash`
- installez deux libs, elles ont été choisies complètement au hasard (avec la commande `pip install`):
  - `aiohttp`
  - `aioconsole`
- tapez la commande `python` pour ouvrir un interpréteur Python
- taper la ligne `import aiohttp` pour vérifier que vous avez bien téléchargé la lib

```bash
Python 3.12.1 (main, Dec 19 2023, 20:14:15) [GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import aiohttp
```

➜ **Tant que t'as un shell dans un conteneur**, tu peux en profiter pour te balader. Tu peux notamment remarquer :

- si tu fais des `ls` un peu partout, que le conteneur a sa propre arborescence de fichiers

```bash
root@0e543ef2b263:/# ls
bin  boot  dev  etc  home  lib  lib32  lib64  libx32  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```
- si t'essaies d'utiliser des commandes usuelles un poil évoluées, elles sont pas là
  - genre t'as pas `ip a` ou ce genre de trucs
  - un conteneur on essaie de le rendre le plus léger possible
  - donc on enlève tout ce qui n'est pas nécessaire par rapport à un vrai OS
  - juste une application et ses dépendances

# II. Images

- [II. Images](#ii-images)
  - [1. Images publiques](#1-images-publiques)
  - [2. Construire une image](#2-construire-une-image)

## 1. Images publiques

🌞 **Récupérez des images**

- avec la commande `docker pull`
- récupérez :
  - l'image `python` officielle en version 3.11 (`python:3.11` pour la dernière version)
```bash
[manon@tp1-linux ~]$ docker pull python:3.11
3.11: Pulling from library/python
```
  - l'image `mysql` officielle en version 5.7
```bash
[manon@tp1-linux ~]$ docker pull mysql:5.7
5.7: Pulling from library/mysql
```
  - l'image `wordpress` officielle en dernière version
    - c'est le tag `:latest` pour récupérer la dernière version
    - si aucun tag n'est précisé, `:latest` est automatiquement ajouté
```bash
[manon@tp1-linux ~]$ docker pull wordpress
Using default tag: latest
latest: Pulling from library/wordpress
```
  - l'image `linuxserver/wikijs` en dernière version
    - ce n'est pas une image officielle car elle est hébergée par l'utilisateur `linuxserver` contrairement aux 3 précédentes
    - on doit donc avoir un moins haut niveau de confiance en cette image

```bash
[manon@tp1-linux ~]$ docker pull linuxserver/wikijs
Using default tag: latest
latest: Pulling from linuxserver/wikijs
```
- listez les images que vous avez sur la machine avec une commande `docker`
```bash
[manon@tp1-linux ~]$ docker images
REPOSITORY           TAG       IMAGE ID       CREATED        SIZE
linuxserver/wikijs   latest    869729f6d3c5   6 days ago     441MB
mysql                5.7       5107333e08a8   9 days ago     501MB
python               latest    fc7a60e86bae   2 weeks ago    1.02GB
wordpress            latest    fd2f5a0c6fba   2 weeks ago    739MB
python               3.11      22140cbb3b0c   2 weeks ago    1.01GB
nginx                latest    d453dd892d93   8 weeks ago    187MB
hello-world          latest    d2c94e258dcb   7 months ago   13.3kB
```

> Quand on tape `docker pull python` par exemple, un certain nombre de choses est implicite dans la commande. Les images, sauf si on précise autre chose, sont téléchargées depuis [le Docker Hub](https://hub.docker.com/). Rendez-vous avec un navigateur sur le Docker Hub pour voir la liste des tags disponibles pour une image donnée. Sachez qu'il existe d'autres répertoires publics d'images comme le Docker Hub, et qu'on peut facilement héberger le nôtre. C'est souvent le cas en entreprise. **On appelle ça un "registre d'images"**.

🌞 **Lancez un conteneur à partir de l'image Python**

- lancez un terminal `bash` ou `sh
```bash
[manon@tp1-linux ~]$ docker run -it python bash
root@424479e94f59:/#
```
- vérifiez que la commande `python` est installée dans la bonne version
```bash
root@424479e94f59:/# python --version
Python 3.12.1
```

> *Sympa d'installer Python dans une version spéficique en une commande non ? Peu importe que Python soit déjà installé sur le système ou pas. Puis on détruit le conteneur si on en a plus besoin.*

## 2. Construire une image

Pour construire une image il faut :

- créer un fichier `Dockerfile`
- exécuter une commande `docker build` pour produire une image à partir du `Dockerfile`

🌞 **Ecrire un Dockerfile pour une image qui héberge une application Python**

- l'image doit contenir
  - une base debian (un `FROM`)
  - l'installation de Python (un `RUN` qui lance un `apt install`)
    - il faudra forcément `apt update` avant
    - en effet, le conteneur a été allégé au point d'enlever la liste locale des paquets dispos
    - donc nécessaire d'update avant de install quoique ce soit
  - l'installation de la librairie Python `emoji` (un `RUN` qui lance un `pip install`)
  - ajout de l'application (un `COPY`)
  - le lancement de l'application (un `ENTRYPOINT`)
- le code de l'application :

```python
import emoji

print(emoji.emojize("Cet exemple d'application est vraiment naze :thumbs_down:"))
```

- pour faire ça, créez un dossier `python_app_build`
  - pas n'importe où, c'est ton Dockerfile, ton caca, c'est dans ton homedir donc `/home/<USER>/python_app_build`
  - dedans, tu mets le code dans un fichier `app.py`
  - tu mets aussi `le Dockerfile` dedans

```bash
[manon@tp1-linux python_app_build]$ cat Dockerfile
FROM debian

RUN apt update -y && apt install -y python3-pip

RUN python3 -m pip install emoji --break-system-packages

COPY app.py /app/app.py

WORKDIR /app

ENTRYPOINT ["python3","app.py"]
```

🌞 **Build l'image**

- déplace-toi dans ton répertoire de build `cd python_app_build`
- `docker build . -t python_app:version_de_ouf`
  - le `.` indique le chemin vers le répertoire de build (`.` c'est le dossier actuel)
  - `-t python_app:version_de_ouf` permet de préciser un nom d'image (ou *tag*)
- une fois le build terminé, constater que l'image est dispo avec une commande `docker`

```bash
[manon@tp1-linux python_app_build]$ docker build . -t python_app:boom
```

```bash
[manon@tp1-linux python_app_build]$ docker images
REPOSITORY           TAG       IMAGE ID       CREATED         SIZE
python_app           boom      01d791e60b64   2 minutes ago   636MB
linuxserver/wikijs   latest    869729f6d3c5   6 days ago      441MB
mysql                5.7       5107333e08a8   9 days ago      501MB
python               latest    fc7a60e86bae   2 weeks ago     1.02GB
wordpress            latest    fd2f5a0c6fba   2 weeks ago     739MB
python               3.11      22140cbb3b0c   2 weeks ago     1.01GB
nginx                latest    d453dd892d93   8 weeks ago     187MB
hello-world          latest    d2c94e258dcb   7 months ago    13.3kB
```

🌞 **Lancer l'image**

- lance l'image avec `docker run` :

```bash
[manon@tp1-linux python_app_build]$ docker run python_app:boom
Cet exemple d'application est vraiment naze 👎
```

# III. Docker compose

Pour la fin de ce TP on va manipuler un peu `docker compose`.

🌞 **Créez un fichier `docker-compose.yml`**

- dans un nouveau dossier dédié `/home/<USER>/compose_test`
- le contenu est le suivant :

```yml
version: "3"

services:
  conteneur_nul:
    image: debian
    entrypoint: sleep 9999
  conteneur_flopesque:
    image: debian
    entrypoint: sleep 9999
```

Ce fichier est parfaitement équivalent à l'enchaînement de commandes suivantes (*ne les faites pas hein*, c'est juste pour expliquer) :

```bash
$ docker network create compose_test
$ docker run --name conteneur_nul --network compose_test debian sleep 9999
$ docker run --name conteneur_flopesque --network compose_test debian sleep 9999
```

🌞 **Lancez les deux conteneurs** avec `docker compose`

- déplacez-vous dans le dossier `compose_test` qui contient le fichier `docker-compose.yml`
- go exécuter `docker compose up -d`

```bash
[manon@tp1-linux compose_test]$ docker compose up -d
[+] Running 3/3
 ✔ conteneur_flopesque 1 layers [⣿]      0B/0B      Pulled                                                                                             2.6s
   ✔ bc0734b949dc Already exists                                                                                                                       0.0s
 ✔ conteneur_nul Pulled                                                                                                                                3.0s
[+] Running 3/3
 ✔ Network compose_test_default                  Created                                                                                               0.1s
 ✔ Container compose_test-conteneur_flopesque-1  Started                                                                                               0.1s
 ✔ Container compose_test-conteneur_nul-1        Started                                                                                               0.1s
 ```

🌞 **Vérifier que les deux conteneurs tournent**

- toujours avec une commande `docker`
- tu peux aussi use des trucs comme `docker compose ps` ou `docker compose top` qui sont cools dukoo
  - `docker compose --help` pour voir les bails
```bash
[manon@tp1-linux compose_test]$ docker compose ps
NAME                                 IMAGE     COMMAND        SERVICE               CREATED         STATUS         PORTS
compose_test-conteneur_flopesque-1   debian    "sleep 9999"   conteneur_flopesque   2 minutes ago   Up 2 minutes
compose_test-conteneur_nul-1         debian    "sleep 9999"   conteneur_nul         2 minutes ago   Up 2 minutes
```

🌞 **Pop un shell dans le conteneur `conteneur_nul`**

- référez-vous au mémo Docker
- effectuez un `ping conteneur_flopesque` (ouais ouais, avec ce nom là)
  - un conteneur est aussi léger que possible, aucun programme/fichier superflu : t'auras pas la commande `ping` !
  - il faudra installer un paquet qui fournit la commande `ping` pour pouvoir tester
  - juste pour te faire remarquer que les conteneurs ont pas besoin de connaître leurs IP : les noms fonctionnent

```bash
[manon@tp1-linux compose_test]$ docker exec -it compose_test-conteneur_nul-1 bash
root@3f94256612fa:/# apt update

root@3f94256612fa:/# apt install iputils-ping -y

root@3f94256612fa:/# ping conteneur_flopesque
PING conteneur_flopesque (172.18.0.3) 56(84) bytes of data.
64 bytes from compose_test-conteneur_flopesque-1.compose_test_default (172.18.0.3): icmp_seq=1 ttl=64 time=0.057 ms
64 bytes from compose_test-conteneur_flopesque-1.compose_test_default (172.18.0.3): icmp_seq=2 ttl=64 time=0.082 ms
64 bytes from compose_test-conteneur_flopesque-1.compose_test_default (172.18.0.3): icmp_seq=3 ttl=64 time=0.071 ms
```