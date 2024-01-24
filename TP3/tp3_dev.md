# TP3 : Développement d'un outil pour les admins

**Le but de ce TP est de développer un outil (sommaire) qui remplirait une des tâches que nous les admins on a besoin.**

Là encore je vous demande de faire preuve d'esprit, et de voir au-delà du sujet pour déceler les problématiques cools, et les problèmes algorithmiques rigolos.

**Je vous propose 3 sujets au choix**, je ne vous guide pas dans le code, mais vous donne simplement des indications sur ce que votre programme doit faire. Dans les 3 cas, vous devrez aussi respecter certaines contraintes et bonnes pratiques.

> Suivant le sujet que vous choisissez, vous serez sûrement amené à retoucher aux sockets, ou au moins à la programmation asynchrone.

Les 3 sujets (j'vous rappelle qu'on est en cours de Linux pour mon choix des thèmes) :

- **outil de monitoring**
  - surveille la machine (RAM, CPU, disque, autres)
  - peut-être interrogé en ligne de commande et retourne les réponses format JSON
  - création d'une API HTTP pour pouvoir récupérer les données depuis ailleurs
- **outil de backup**
  - copie des fichiers d'un endroit à un autre en somme
  - supporte la compression et l'archivage
  - supporte les cibles distantes à travers SSH
  - utilisé en ligne de commande
- **IDS**
  - détection d'intrusion
  - surveille des fichiers du disque et vérifie qu'ils n'ont pas changé

## Sommaire

- [TP3 : Développement d'un outil pour les admins](#tp3--développement-dun-outil-pour-les-admins)
  - [Sommaire](#sommaire)
- [0. Setup](#0-setup)
- [I. Instructions communes](#i-instructions-communes)
- [II. Sujet 1 Monitoring](#ii-sujet-1-monitoring)
- [III. Sujet 2 Backup](#iii-sujet-2-backup)
- [IV. Sujet 3 IDS](#iv-sujet-3-ids)

# 0. Setup

➜ **Vous créerez un dépôt git dédié à l'hébergement de votre programme**

- le README de rendu du TP contient juste le lien vers ce dépôt dédié

➜ **En Python évidemment à priori**

- mais vous êtes libres sur le choix du langage

➜ **Solo ou Duo**

- à vous de voir ce que vous préférez
- en binôme c'est cool, on va plus vite, plus loin, on confronte les idées, et git est là pour bosser à 2

# I. Instructions communes

![App](./img/app.svg)

➜ **Linux-friendly**

- vous développez un outil qui est destiné à être exécuté sur des machines Linux
- faites vos tests avec une VM (pas un conteneur)

➜ **Output**

- l'output doit être joli et lisible

➜ **Options**

- votre programme doit supporter des options au lancement, au moins un `--help`
- je vous donne + de détails sur les options qui doivent être dispos dans la section dédiée à chaque sujet

➜ **Fichier de conf**

- peu importe l'outil que vous avez choisi de dév, il doit utiliser un fichier de conf
- le fichier de conf sera écrit en JSON
- il contiendra des trucs différents suivant le sujet que vous choisissez, détails dans la partie dédiée
- le fichier de conf qui est lu par défaut doit être dans le path standard sous les OS Linux : `/etc/`
  - il faut un sous-dossier qui porte le nom du programme
  - s'il n'existe pas, votre programme le crée au premier lancement

➜ **Logs**

- votre outil doit log ce qu'il fait
- le fichier de log doit être par défaut dans le path standard sous les OS Linux : `/var/log/`
  - il faut un sous-dossier qui porte le nom du programme
  - s'il n'existe pas, votre programme le crée au premier lancement

➜ **Un README**

- un beau README qui explique comment se servir de l'outil
- il doit comporter :
  - une section `Installation` qui indique comment installer votre outil
    - faut installer des paquets ? des dépendances ? Docker ?
    - vous donnez les commandes, faites ça clean, vous avez lu quelques README sur Github vous-mêmes non ?
  - une section `Usage` qui montre un exemple simple d'utilisation
    - en début de section vous montrez une exécution du `--help`
    - un exemple d'utilisation simple
  - une section `Configuration`
    - qui montre ce qu'on peut mettre dans le fichier de conf

➜ **Une unité systemd**

- les trois sujets s'y prêtent bien
- il faudra remettre un fichier `xxx.service` qui permettra de lancer votre programme comme un service système
  - le service lancera une commande spécifique de votre programme
  - j'indiquerai avec l'emoji 🚩 la commande que doit lancer le service
- et aussi `xxx.timer` pour que le service soit déclenché à intervalles réguliers

➜ **Un code clean SVP**

- nommage de fonctions, de variables
- plusieurs fichiers
- pas ré-écrire le même code 1000x
- etc.
- une bonne fonction
  - elle fait moins de 20 lignes
  - si ta fonction est (beaucoup) plus longue, alors tu dois pouvoir la split en plusieurs fonctions et ça aurait plus de sens

➜ **Le but c'est pas d'appeler des commandes shell**

- vous devez *coder* le programme qui fait les trucs, et pas juste appeler `ss` pour savoir si tel ou tel port est ouvert

# II. Sujet 1 Monitoring

![Monitoring](./img/monit.jpg)

Un programme `monit.py` qui monitore certaines ressources de la machine et peut effectuer des rapports au format JSON.

Autrement dit, le programme check la valeur de certains trucs (genre combien de RAM il reste de dispo ?) et les enregistre. Il est ensuite possible d'appeler le programme en ligne de commande pour obtenir le résultat des derniers checks.

➜ **Utilisation du programme `monit.py`**

- toutes les actions doivent générer au moins une ligne de logs indiquant que la commande a été appelée
- `monit.py check`
  - il check la valeur de certaines ressources du système
  - il enregistre ces données dans un fichier dédié
  - 🚩 cette commande doit être appelée dans le service `backup.service`
- `monit.py list`
  - il affiche la liste des rapports qui ont été effectués
- `monit.py get last`
  - il sort le dernier rapport
- `monit.py get avg X`
  - il calcule les valeurs moyennes des X dernières heures

➜ **Ce que votre programme doit surveiller**

- RAM
- utilisation disque
- activité du CPU
- est-ce que certains ports sont ouverts et dispos en TCP

➜ **Le fichier de conf**

- on précise la liste des ports TCP à surveiller
- si la connexion TCP fonctionne, c'est que le port est actif, on retourne True
- sinon False

➜ **Enregistrer les données**

- vous enregistrerez les rapports dans le path standard pour les données des applications sous les OS Linux : `/var/`
  - il faut un sous-dossier `monit`
  - s'il n'existe pas, votre programme le crée au premier lancement
- un fichier pour chaque rapport généré avec `monit.py check`

➜ **Contenu d'un rapport**

- format JSON
- contenu
  - l'heure et la date où le check a été effectué, dans un format standard
  - un ID unique pour chaque check
  - toutes les valeurs récoltées (RAM, etc)

---

⭐ **Bonus alertes**

- on peut indiquer des seuils dans le fichier de conf
  - par exemple, on définit que s'il reste que 20% de RAM, c'est critique !
- si un seuil est dépassé, vous envoyez une alerte
  - par exemple, dans un salon Discord qu'on configure dans le fichier de conf
- l'alerte est envoyée à chaque `check` on envoie un rapport qui contient juste un OK si tout va bien, sinon il indique les valeurs qui ont dépassé un seuil critique

⭐ **Bonus DB**

- on lance un petit conteneur MongoDB pour stocker les données au format JSON
- plutôt que de les stocker sur le disque dans des fichiers, on met ça en DB

⭐ **Bonus API**

- il existe un deuxième programme `monit-api.py` qui expose une API HTTP sur un port donné
- si on interroge cette API, on peut récupérer les rapports de monitoring en format JSON
  - `GET /reports` : récup tous les rapports
  - `GET /reports/<ID>` : récup un seul rapport
- j'vous ai écrit [un bout de cours sur les API avec Python Flask](../../../cours/dev/api/README.md)

# III. Sujet 2 Backup

![Restore](./img/restore.jpeg)

Un programme `backup.py` qui effectue une sauvegarde d'un ou plusieurs dossiers/fichiers indiqués par l'utilisateur.

Le programme permet aussi de lister les sauvegardes qui ont été effectuées, et de les restaurer.

➜ **Utilisation du programme `backup.py`**

- toutes les actions doivent générer au moins une ligne de logs indiquant que la commande a été appelée
- `backup.py backup`
  - permet d'effectuer une backup en fonction de ce qu'il y a défini dans le fichier de conf
  - 🚩 cette commande doit être appelée dans le service `backup.service`
- `backup.py list`
  - liste les backups qui ont été effectuées
- `backup.py restore <BACKUP>`
  - restauration d'une sauvegarde, en utilisant l'ID de la sauvegarde qu'on a obtenu avec `backup.py list`
- `backup.py delete <BACKUP>`
  - on supprime une sauvegarde donnée
- `backup.py clean`
  - on supprime éventuellement des sauvegardes, en fonction des conditions de rétention indiquées dans le fichier de conf
  - 🚩 cette commande doit être appelée dans le service `backup.service`

➜ **Fichier de conf**

- permet de lister les dossiers et fichiers qu'on souhaite backup
- permet de définir une destination
  - soit un dossier local
  - soit un dossier qui se situe sur une autre machine (à travers SSH)
- conditions de rétention
  - on peut indiquer qu'on ne souhaite stocker que X backups maximum
  - au delà de ce nombre, la backup la plus ancienne sera supprimée avant de créer la nouvelle

➜ **Action `backup.py backup`**

- crée une archive compressée dans le format de votre choix (pas ZIP, ni RAR, choisissez autre chose que ces deux-là)
- sauvegarde dans un dossier dédié
  - `/var/backup/` par défaut
  - ou autres si quelque chose est précisé dans le fichier de conf
  - si c'est une machine distante SSH la destination, la compression est effectuée avant
- dans le dossier de destination, il existe un fichier `state.json`
  - il répertorie la liste de toutes les backups, pour chacune :
    - un ID unique
    - date et heure où la backup a été effectuée
    - le path vers l'archive

➜ **Action `backup.py list`**

- liste les backups qui ont déjà été effectuées
- en interrogeant le fichier `state.json`
- retourne les résultats dans un format plus lisible que du JSON moche

➜ **Action `backup.py restore <BACKUP>`**

- restaure une backup dont on a précisé l'ID
- c'est à dire : on récupère le fichier s'il est sur machine distante en SSH
- on décompresse l'archive
- et on remet les fichiers où ils étaient

➜ **Action `backup.py clean`**

- supprime des backups si nécessaire, en fonction de ce qui a été précisé dans le fichier de conf
- si on a indiqué 5 backups max et qu'on vient de réaliser la 6ème, alors `backup.py clean` doit supprimer la plus ancienne
  - en se référant au fichier `state.json`

---

⭐ **Bonus API**

- il existe un deuxième programme `backup-api.py` qui expose une API HTTP sur un port donné
- si on interroge cette API, on peut
  - récupérer la liste des sauvegardes
    - `GET /backups`
    - `GET /backups/<ID>`
  - déclencher une sauvegarde
    - `POST /backup`
- j'vous ai écrit [un bout de cours sur les API avec Python Flask](../../../cours/dev/api/README.md)

# IV. Sujet 3 IDS

![Watchin](./img/watching.png)

Un IDS est un détecteur d'intrusion (Intrusion Detection System). Ici on parle d'un programme qui va surveiller les fichiers du disque dur pour savoir s'ils ont été modifiés.

On utilise vraiment ce genre d'outils en contexte réel, car certains fichiers ne sont normalement plus jamais modifiés après leur configuration initiale. Toute modification peut être considéré comme suspecte.

> Par exemple, on surveille `/etc/shadow`.

On va donc développer ici un ptit `ids.py` qui surveille l'état de certains fichiers sur le disque et deux trois autres trucs.

➜ **Utilisation du programme `ids.py`**

- toutes les actions doivent générer au moins une ligne de logs indiquant que la commande a été appelée
- `ids.py build`
  - construit un fichier JSON qui contient un état des choses qu'on a demandé à surveiller
  - ce fichier est stocké dans `/var/ids/db.json`
- `ids.py check`
  - vérifie que l'état actuel est conforme à ce qui a été stocké dans `/var/ids/db.json`
  - si quelque chose a changé, alors il faut le signaler
  - retourne un rapport au format JSON indiquant
    - juste `{"state":"ok"}` si rien a bougé par rapport à `/var/ids/db.json`
    - sinon affiche un rapport de ce qui a changé en commençant par `{"state":"divergent"}`
  - 🚩 cette commande doit être appelée dans le service `backup.service`

➜ **Fichier de conf**

- contient une liste de fichier à surveiller
- contient une liste de dossiers à surveiller : on surveille tous les sous fichiers aussi
- indique si on souhaite surveiller les ports en écoute ou non

➜ **Le fichier `/var/ids/db.json`** doit contenir

- heure et date du `build` (quand ce fichier a été généré)
- l'état des fichiers à surveiller
  - hash SHA512
  - hash SHA256
  - hash MD5
  - date de dernière modif du fichier
  - date de création du fichier
  - propriétaire du fichier
  - groupe propriétaire du fichier
  - taille du fichier
- un rapport sur les ports TCP/UDP en écoute

---

⭐ **Bonus API**

- il existe un deuxième programme `ids-api.py` qui expose une API HTTP sur un port donné
- si on interroge cette API, on peut :
  - effectuer un check
    - `POST /check`
  - récupérer le rapport au format JSON
    - `GET /reports` : tous les rapports
    - `GET /reports/<ID>` : un seul rapport
- j'vous ai écrit [un bout de cours sur les API avec Python Flask](../../../cours/dev/api/README.md)
⭐ **Bonus alertes**

- si un `check` ne passe pas, vous envoyez une alerte
  - par exemple, dans un salon Discord qu'on configure dans le fichier de conf