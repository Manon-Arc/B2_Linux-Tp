# TP4 : Vers une maîtrise des OS Linux
test

Cette deuxième partie a donc pour but de vous (re)montrer **des techniques d'administration classique** :

- partitionnement
- gestion de users
- gestion du temps
- je vous épargne la gestion de services cette fois hehe

![Systemd breaks](./img/systemd.jpg)

## Sommaire

- [TP4 : Vers une maîtrise des OS Linux](#tp4--vers-une-maîtrise-des-os-linux)
  - [Sommaire](#sommaire)
- [I. Partitionnement](#i-partitionnement)
  - [1. LVM dès l'installation](#1-lvm-dès-linstallation)
  - [2. Scénario remplissage de partition](#2-scénario-remplissage-de-partition)
- [II. Gestion de users](#ii-gestion-de-users)
- [III. Gestion du temps](#iii-gestion-du-temps)

# I. Partitionnement

> *Pas de Vagrant possible ici, déso !*

Pour le coup ça l'est, ou ça doit le devenir : **élémentaire**. Concrètement dans cette section on va gérer des partitions dans un premier temps, pour ensuite gérer des users et faire une conf `sudo` maîtrisée.

Je vous ai remis [le cours sur le partitionnement de l'an dernier](../../../cours/partition/README.md) dans ce dépôt, et [le mémo LVM](../../../cours/memo/lvm.md).

## 1. LVM dès l'installation

🌞 **Faites une install manuelle de Rocky Linux**

- ouais vous refaites l'install depuis l'iso
- mais cette fois, vous gérez le partitionnement vous-mêmes
- c'est en GUI à l'install, profitez-en hehe
- **tout doit être partitionné avec LVM** (partitionnement logique)
- **donnez à votre VM un disque de 40G**
  - je rappelle qu'avec des disques virtuels "dynamiques" l'espace n'est pas consommé sur votre machine tant que la VM ne l'utilise pas
- je veux le schéma de partition suivant :

| Point de montage | Taille       | FS    |
| ---------------- | ------------ | ----- |
| /                | 10G          | ext4  |
| /home            | 5G           | ext4  |
| /var             | 5G           | ext4  |
| swap             | 1G           | swap  |
| espace libre     | ce qui reste | aucun |

> On sépare les données des applications (`/var`), ~~les pouvelles~~ les répertoires personnels des utilisateurs (`/home`) du reste du système (tout le reste est contenu dans `/`). systemd s'occupera de deux trois trucs en plus, comme séparer la partition `/tmp` pour qu'elle existe en RAM (truc2fou).

➜ Une fois installée, faites le tour du propriétaire :

```bash
# lister les périphériques de type bloc = les disque durs, clés usb et autres trucs
lsblk

# montre l'espace dispo sur les partitions montées actuellement
df -h

# interagir avec les LVM
## voir les physical volumes
pvs # short
pvdisplay # beaucoup d'infos

## voir les volume groups
vgs
vgdisplay

## et les logical volumes
lvs
lvdisplay
```

## 2. Scénario remplissage de partition

🌞 **Remplissez votre partition `/home`**

- on va simuler avec un truc bourrin :

```
dd if=/dev/zero of=/home/<TON_USER>/bigfile bs=4M count=5000
```

> 5000x4M ça fait 40G. Ca fait trop.

🌞 **Constater que la partition est pleine**

- avec un `df -h`

🌞 **Agrandir la partition**

- avec des commandes LVM il faut agrandir le logical volume
- ensuite il faudra indiquer au système de fichier ext4 que la partition a été agrandie
- prouvez avec un `df -h` que vous avez récupéré de l'espace en plus

🌞 **Remplissez votre partition `/home`**

- on va simuler encore avec un truc bourrin :

```
dd if=/dev/zero of=/home/<TON_USER>/bigfile bs=4M count=5000
```

> 5000x4M ça fait toujours 40G. Et ça fait toujours trop.

➜ **Eteignez la VM et ajoutez lui un disque de 40G**

🌞 **Utiliser ce nouveau disque pour étendre la partition `/home` de 40G**

- dans l'ordre il faut :
- indiquer à LVM qu'il y a un nouveau PV dispo
- ajouter ce nouveau PV au VG existant
- étendre le LV existant pour récupérer le nouvel espace dispo au sein du VG
- indiquer au système de fichier ext4 que la partition a été agrandie
- prouvez avec un `df -h` que vous avez récupéré de l'espace en plus

> Si vous avez assez d'espace libre, et que vous voulez montrer la taille de votre kiki, vous pouvez refaire la commande `dd` et vraiment créer le fichier de 40G.

# II. Gestion de users

Je vous l'ai jamais demandé, alors c'est limite un interlude obligé que j'ai épargné à tout le monde, mais les admins, vous y échapperez pas.

On va faire un petit exercice tout nul de gestion d'utilisateurs.

> *Si t'es si fort, ça prend même pas 2-3 min, alors fais-le :D*

🌞 **Gestion basique de users**

- créez des users en respactant le tableau suivant :

| Name    | Groupe primaire | Groupes secondaires | Password | Homedir         | Shell              |
| ------- | --------------- | ------------------- | -------- | --------------- | ------------------ |
| alice   | alice           | admins              | toto     | `/home/alice`   | `/bin/bash`        |
| bob     | bob             | admins              | toto     | `/home/bob`     | `/bin/bash`        |
| charlie | charlie         | admins              | toto     | `/home/charlie` | `/bin/bash`        |
| eve     | eve             | N/A                 | toto     | `/home/eve`     | `/bin/bash`        |
| backup  | backup          | N/A                 | toto     | `/var/backup`   | `/usr/bin/nologin` |

- prouvez que tout ça est ok avec juste un `cat` du fichier adapté (y'a pas le password dedans bien sûr)

🌞 **La conf `sudo` doit être la suivante**

| Qui est concerné | Quels droits                                                      | Doit fournir son password |
| ---------------- | ----------------------------------------------------------------- | ------------------------- |
| Groupe admins    | Tous les droits                                                   | Non                       |
| User eve         | Peut utiliser la commande `ls` en tant que l'utilisateur `backup` | Oui                       |

🌞 **Le dossier `/var/backup`**

- créez-le
- choisir des permissions les plus restrictives possibles (comme toujours, la base quoi) sachant que :
  - l'utilisateur `backup` doit pouvoir évoluer normalement dedans
  - les autres n'ont aucun droit
- il contient un fichier `/var/backup/precious_backup`
  - créez-le (contenu vide ou balec)
  - choisir des permissions les plus restrictives possibles sachant que
    - `backup` doit être le seul à pouvoir le lire et le modifier
    - le groupe `backup` peut uniquement le lire

🌞 **Mots de passe des users, prouvez que**

- ils sont hashés en SHA512 (c'est violent)
- ils sont salés (c'est pas une blague si vous connaissez pas le terme, on dit "salted" en anglais aussi)

🌞 **User eve**

- elle ne peut que saisir `sudo ls` et rien d'autres avec `sudo`
- vous pouvez faire `sudo -l` pour voir vos droits `sudo` actuels

# III. Gestion du temps

![Timing](./img/timing.jpg)

Il y a un service qui tourne en permanence (ou pas) sur les OS modernes pour maintenir l'heure de la machine synchronisée avec l'heure que met à disposition des serveurs.

Le protocole qui sert à faire ça s'appelle NTP (Network Time Protocol, tout simplement). Il existe donc des serveurs NTP. Et le service qui tourne en permanence sur nos PCs/serveurs, c'est donc un client NTP.

Il existe des serveurs NTP publics, hébergés gracieusement, comme le projet [NTP Pool](https://www.ntppool.org).

🌞 **Je vous laisse gérer le bail vous-mêmes**

- déterminez quel service sur Rocky Linux est le client NTP par défaut
  - demandez à google, ou explorez la liste des services avec `systemctl list-units -t service -a`, ou les deux
- demandez à ce service de se synchroniser sur [les serveurs français du NTP Pool Project](https://www.ntppool.org/en/zone/fr)
- assurez-vous que vous êtes synchronisés sur l'heure de Paris

> systemd fournit un outil en ligne de commande `timedatectl` qui permet de voir des infos liées à la gestion du temps