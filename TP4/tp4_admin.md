# TP4 : Vers une maîtrise des OS Linux

Cette deuxième partie a donc pour but de vous (re)montrer **des techniques d'administration classique** :

- partitionnement
- gestion de users
- gestion du temps
- je vous épargne la gestion de services cette fois hehe

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
[manon@tp4 ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0   40G  0 disk 
├─sda1        8:1    0   21G  0 part 
│ ├─rl-root 253:0    0   10G  0 lvm  /
│ ├─rl-swap 253:1    0    1G  0 lvm  [SWAP]
│ ├─rl-home 253:2    0    5G  0 lvm  /home
│ └─rl-var  253:3    0    5G  0 lvm  /var
└─sda2        8:2    0    1G  0 part /boot
sr0          11:0    1 1024M  0 rom  

# montre l'espace dispo sur les partitions montées actuellement
[manon@tp4 ~]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                882M     0  882M   0% /dev/shm
tmpfs                353M  5.0M  348M   2% /run
/dev/mapper/rl-root  9.8G  1.1G  8.2G  12% /
/dev/sda2            974M  261M  646M  29% /boot
/dev/mapper/rl-home  4.9G   44K  4.6G   1% /home
/dev/mapper/rl-var   4.9G  141M  4.5G   3% /var
tmpfs                177M     0  177M   0% /run/user/1000

# interagir avec les LVM
## voir les physical volumes

# short
[manon@tp4 ~]$ sudo pvs
[sudo] password for manon: 
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda1  rl lvm2 a--  21.00g 4.00m


# beaucoup d'infos
[manon@tp4 ~]$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda1
  VG Name               rl
  PV Size               <21.01 GiB / not usable 4.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              5377
  Free PE               1
  Allocated PE          5376
  PV UUID               OFXsTZ-qeCm-DOey-0xxW-eAsV-NGYp-f2xxeT

## voir les volume groups
[manon@tp4 ~]$ sudo vgs
  VG #PV #LV #SN Attr   VSize  VFree
  rl   1   4   0 wz--n- 21.00g 4.00m

[manon@tp4 ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               rl
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  5
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                4
  Open LV               4
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               21.00 GiB
  PE Size               4.00 MiB
  Total PE              5377
  Alloc PE / Size       5376 / 21.00 GiB
  Free  PE / Size       1 / 4.00 MiB
  VG UUID               MZ3YYf-go8x-e09c-J7hw-wSXc-B1Nf-lyZpn4

## et les logical volumes
[manon@tp4 ~]$ sudo lvs
  LV   VG Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home rl -wi-ao----  5.00g                                                    
  root rl -wi-ao---- 10.00g                                                    
  swap rl -wi-ao----  1.00g                                                    
  var  rl -wi-ao----  5.00g 

[manon@tp4 ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/rl/root
  LV Name                root
  VG Name                rl
  LV UUID                L5rgSi-6BgR-jfSe-dXb8-zT0K-s5rD-P3msS7
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2024-01-25 11:18:54 +0100
  LV Status              available
  # open                 1
  LV Size                10.00 GiB
  Current LE             2560
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0
   
  --- Logical volume ---
  LV Path                /dev/rl/home
  LV Name                home
  VG Name                rl
  LV UUID                2PHyCy-Tt1N-S48w-mUge-wzYc-YPx2-2wzU1y
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2024-01-25 11:18:54 +0100
  LV Status              available
  # open                 1
  LV Size                5.00 GiB
  Current LE             1280
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
   
  --- Logical volume ---
  LV Path                /dev/rl/var
  LV Name                var
  VG Name                rl
  LV UUID                dWft23-9JE3-xVIs-XS6P-RHJX-bV1L-Af16At
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2024-01-25 11:18:54 +0100
  LV Status              available
  # open                 1
  LV Size                5.00 GiB
  Current LE             1280
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:3
   
  --- Logical volume ---
  LV Path                /dev/rl/swap
  LV Name                swap
  VG Name                rl
  LV UUID                nK6UcK-ZJsY-ktx9-8ccA-mTr6-2NdD-7Sk2rX
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2024-01-25 11:18:55 +0100
  LV Status              available
  # open                 2
  LV Size                1.00 GiB
  Current LE             256
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

```

## 2. Scénario remplissage de partition

🌞 **Remplissez votre partition `/home`**

- on va simuler avec un truc bourrin :

```
dd if=/dev/zero of=/home/<TON_USER>/bigfile bs=4M count=5000
```

> 5000x4M ça fait 40G. Ca fait trop.

```bash
[manon@tp4 ~]$ sudo dd if=/dev/zero of=/home/manon/bigfile bs=4M count=5000
dd: error writing '/home/manon/bigfile': No space left on device
1235+0 records in
1234+0 records out
5179555840 bytes (5.2 GB, 4.8 GiB) copied, 3.55043 s, 1.5 GB/s
```

🌞 **Constater que la partition est pleine**

- avec un `df -h`
```bash
[manon@tp4 ~]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                882M     0  882M   0% /dev/shm
tmpfs                353M  5.0M  348M   2% /run
/dev/mapper/rl-root  9.8G  1.1G  8.2G  12% /
/dev/sda2            974M  261M  646M  29% /boot
/dev/mapper/rl-home  4.9G  4.9G     0 100% /home
/dev/mapper/rl-var   4.9G  141M  4.5G   3% /var
tmpfs                177M     0  177M   0% /run/user/1000
```

🌞 **Agrandir la partition**

- avec des commandes LVM il faut agrandir le logical volume
- ensuite il faudra indiquer au système de fichier ext4 que la partition a été agrandie
- prouvez avec un `df -h` que vous avez récupéré de l'espace en plus

```bash
[manon@tp4 ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0   40G  0 disk 
├─sda1        8:1    0   21G  0 part 
│ ├─rl-root 253:0    0   10G  0 lvm  /
│ ├─rl-swap 253:1    0    1G  0 lvm  [SWAP]
│ ├─rl-home 253:2    0    5G  0 lvm  /home
│ └─rl-var  253:3    0    5G  0 lvm  /var
└─sda2        8:2    0    1G  0 part /boot
sr0          11:0    1 1024M  0 rom  
```

```bash
[manon@tp4 ~]$ sudo fdisk /dev/sda
Welcome to fdisk (util-linux 2.37.4).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.
[...]
The partition table has been altered.
Syncing disks.

[manon@tp4 ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0   40G  0 disk 
├─sda1        8:1    0   21G  0 part 
│ ├─rl-root 253:0    0   10G  0 lvm  /
│ ├─rl-swap 253:1    0    1G  0 lvm  [SWAP]
│ ├─rl-home 253:2    0    5G  0 lvm  /home
│ └─rl-var  253:3    0    5G  0 lvm  /var
├─sda2        8:2    0    1G  0 part /boot
└─sda3        8:3    0   18G  0 part 
sr0          11:0    1 1024M  0 rom  

[manon@tp4 ~]$ sudo pvcreate /dev/sda3
Physical volume "/dev/sda3" successfully created.

[manon@tp4 ~]$ sudo vgextend rl /dev/sda3
 Volume group "rl" successfully extended

[manon@tp4 ~]$ sudo lvextend -l +100%FREE /dev/rl/home 
Size of logical volume rl/home changed from 5.00 GiB (1280extents) to 22.99 GiB (5886 extents).
Logical volume rl/home successfully resized.

[manon@tp4 ~]$ sudo resize2fs /dev/rl/home

[manon@tp4 ~]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                882M     0  882M   0% /dev/shm
tmpfs                353M  5.0M  348M   2% /run
/dev/mapper/rl-root  9.8G  1.1G  8.2G  12% /
/dev/sda2            974M  261M  646M  29% /boot
/dev/mapper/rl-home   23G  4.9G   17G  23% /home
/dev/mapper/rl-var   4.9G  141M  4.5G   3% /var
tmpfs                177M     0  177M   0% /run/user/1000
```

🌞 **Remplissez votre partition `/home`**

- on va simuler encore avec un truc bourrin :

```bash
[manon@tp1 ~]$ sudo dd if=/dev/zero of=/home/manon/bigfile bs=4M count=5000
5000+0 records in
5000+0 records out
20971520000 bytes (21 GB, 20 GiB) copied, 14.7513 s, 1.4 GB/s
```

> 5000x4M ça fait toujours 40G. Et ça fait toujours trop.

➜ **Eteignez la VM et ajoutez lui un disque de 40G**

🌞 **Utiliser ce nouveau disque pour étendre la partition `/home` de 40G**

```bash
[manon@tp4 ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0   40G  0 disk 
├─sda1        8:1    0   21G  0 part 
│ ├─rl-root 253:0    0   10G  0 lvm  /
│ ├─rl-swap 253:1    0    1G  0 lvm  [SWAP]
│ ├─rl-home 253:2    0   23G  0 lvm  /home
│ └─rl-var  253:3    0    5G  0 lvm  /var
├─sda2        8:2    0    1G  0 part /boot
└─sda3        8:3    0   18G  0 part 
  └─rl-home 253:2    0   23G  0 lvm  /home
sdb           8:16   0   40G  0 disk 
```

- dans l'ordre il faut :
- indiquer à LVM qu'il y a un nouveau PV dispo
- ajouter ce nouveau PV au VG existant
- étendre le LV existant pour récupérer le nouvel espace dispo au sein du VG
- indiquer au système de fichier ext4 que la partition a été agrandie
- prouvez avec un `df -h` que vous avez récupéré de l'espace en plus

```bash
[manon@tp4 ~]$ sudo pvcreate /dev/sdb
Physical volume "/dev/sdb" successfully created.

[manon@tp4 ~]$ sudo vgextend rl /dev/sdb
  Physical volume "/dev/sdb" successfully created.
  Volume group "rl" successfully extended

[manon@tp1 ~]$ sudo lvextend -l +100%FREE /dev/rl/home 
  Size of logical volume rl/home changed from 22.99 GiB (5886 extents) to <62.99 GiB (16125 extents).
  Logical volume rl/home successfully resized.

[manon@tp1 ~]$ sudo resize2fs /dev/rl/home
resize2fs 1.46.5 (30-Dec-2021)
Filesystem at /dev/rl/home is mounted on /home; on-line resizing required
old_desc_blocks = 3, new_desc_blocks = 8
The filesystem on /dev/rl/home is now 16512000 (4k) blocks long.

[manon@tp1 ~]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                890M     0  890M   0% /dev/shm
tmpfs                356M  5.0M  351M   2% /run
/dev/mapper/rl-root  9.8G  941M  8.4G  10% /
/dev/mapper/rl-var   4.9G   97M  4.5G   3% /var
/dev/mapper/rl-home   62G   20G   40G  33% /home
/dev/sda1           1014M  221M  794M  22% /boot
tmpfs                178M     0  178M   0% /run/user/1000
```

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

```bash
sudo groupadd admins
sudo groupadd alice
sudo groupadd bob
sudo groupadd charlie
sudo groupadd eve
sudo groupadd backup

useradd -g alice -G admins -m -s /bin/bash alice 
useradd -g bob -G admins -m -s /bin/bash bob 
useradd -g charlie -G admins -m -s /bin/bash charlie 
useradd -g eve -m -s /bin/bash eve 
useradd -g backup -d /var/backup -s /bin/bash backup 

sudo passwd alice
sudo passwd bob
sudo passwd charlie
sudo passwd eve
sudo passwd backup
```

- prouvez que tout ça est ok avec juste un `cat` du fichier adapté (y'a pas le password dedans bien sûr)

```bash
[manon@tp1 home]$ cat /etc/passwd
alice:x:1001:1001::/home/alice:/bin/bash
bob:x:1002:1003::/home/bob:/bin/bash
charlie:x:1003:1004::/home/charlie:/bin/bash
eve:x:1004:1005::/home/eve:/bin/bash
backup:x:1005:1006::/var/backup:/bin/bash
```

🌞 **La conf `sudo` doit être la suivante**

| Qui est concerné | Quels droits                                                      | Doit fournir son password |
| ---------------- | ----------------------------------------------------------------- | ------------------------- |
| Groupe admins    | Tous les droits                                                   | Non                       |
| User eve         | Peut utiliser la commande `ls` en tant que l'utilisateur `backup` | Oui                       |

```bash
[manon@tp1 home]$ sudo cat /etc/sudoers | grep -e admin -e eve
eve ALL=(backup) 	      /bin/ls
%admins ALL=(ALL)       NOPASSWD: ALL
```

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

```bash
[manon@tp1 var]$ ls -la | grep backup
drwx------.  2 backup backup  4096 Jan 26 11:09 backup

[manon@tp1 var]$ sudo ls -la backup/ | grep precious_backup
-rw-r-----.  1 backup backup    0 Jan 26 11:45 precious_backup

```

🌞 **Mots de passe des users, prouvez que**

- ils sont hashés en SHA512 (c'est violent)
- ils sont salés (c'est pas une blague si vous connaissez pas le terme, on dit "salted" en anglais aussi)

```bash
[manon@tp1 ~]$ sudo cat /etc/shadow
manon:$6$cr/U5rl9co9MdTZB$VeKbryFGGyvvP5mM1VYFcp2B0ZCX.wtu6b8p8Vvk1b4N1jhpiSMS7fhPvylHzsYXz98g9.1f2vSEvV6iOJPOF.::0:99999:7:::
alice:$6$rnrtp/jhyxtE09zv$LM2LJ.kEhxnMRbJIVCBHG/b26emJ9PoOO9V.G7Qbj62a6.1GwwBJ/4xgoquUD/ksF5l6qpSqfdz9XKRZSYVRF1:19748:0:99999:7:::
bob:$6$4WKWOs8qhN00qhLh$2nPJELiGWOEhmOjkILHQIFU2yh664vZMsjQEqgoMHBACQLepOD9Gs0lyhCYYl4bp2RrDp8TKo784/Q3x41waw0:19748:0:99999:7:::
charlie:$6$fHwdkBLukkp0UeHs$Q8OudGYgWB7TnF0hm7cqSe.uf9VG9AQ9.7xfwXJYCxFZErvn/teMcsE4Ga0jZZqASDSsaCcl.CpPkYsxFc27y1:19748:0:99999:7:::
eve:$6$UJwdDX1pU5VCDfWr$QcZP4/KWyL4n5N7JvUh.U0NwrqKi7eRmzf7P2x8J/AQn6bNV8XQyQXfSLxjczgVT44nP.5FAfRbqXvEdmz.ja/:19748:0:99999:7:::
backup:$6$fGjkZE1E3pU757na$8sak4Q3guslC3WW0AioHpcflteXzctbAzJgq87s3lNOsdvMM0xQfpgZaEpOCc2sA7hWxkYRBTV0cTaVE9kZKl/:19748:0:99999:7:::
```

🌞 **User eve**

- elle ne peut que saisir `sudo ls` et rien d'autres avec `sudo`
- vous pouvez faire `sudo -l` pour voir vos droits `sudo` actuels

```bash
[manon@tp1 ~]$ sudo cat /etc/sudoers | grep eve
eve ALL=(ALL) 		/usr/bin/ls

[eve@tp1 manon]$ sudo -l | grep ls
    (ALL) /usr/bin/ls
```

# III. Gestion du temps

Il y a un service qui tourne en permanence (ou pas) sur les OS modernes pour maintenir l'heure de la machine synchronisée avec l'heure que met à disposition des serveurs.

Le protocole qui sert à faire ça s'appelle NTP (Network Time Protocol, tout simplement). Il existe donc des serveurs NTP. Et le service qui tourne en permanence sur nos PCs/serveurs, c'est donc un client NTP.

Il existe des serveurs NTP publics, hébergés gracieusement, comme le projet [NTP Pool](https://www.ntppool.org).

🌞 **Je vous laisse gérer le bail vous-mêmes**

- déterminez quel service sur Rocky Linux est le client NTP par défaut
  - demandez à google, ou explorez la liste des services avec `systemctl list-units -t service -a`, ou les deux
- demandez à ce service de se synchroniser sur [les serveurs français du NTP Pool Project](https://www.ntppool.org/en/zone/fr)
- assurez-vous que vous êtes synchronisés sur l'heure de Paris

> systemd fournit un outil en ligne de commande `timedatectl` qui permet de voir des infos liées à la gestion du temps

```bash
[manon@tp1 ~]$ systemctl list-units -t service -a | grep chrony
  chronyd.service                            loaded    active   running NTP client/server

[manon@tp1 etc]$ cat chrony.conf
# /etc/chrony.conf
server 0.fr.pool.ntp.org iburst
server 1.fr.pool.ntp.org iburst
server 2.fr.pool.ntp.org iburst
server 3.fr.pool.ntp.org iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony

[manon@tp1 etc]$ sudo systemctl enable chronyd

[manon@tp1 etc]$ sudo systemctl status chronyd
● chronyd.service - NTP client/server
     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2024-01-26 10:36:45 CET; 1h 46min ago
       Docs: man:chronyd(8)
             man:chrony.conf(5)
   Main PID: 773 (chronyd)
      Tasks: 1 (limit: 11109)
     Memory: 4.4M
        CPU: 79ms
     CGroup: /system.slice/chronyd.service
             └─773 /usr/sbin/chronyd -F 2


[manon@tp1 etc]$ timedatectl
               Local time: Fri 2024-01-26 12:24:08 CET
           Universal time: Fri 2024-01-26 11:24:08 UTC
                 RTC time: Fri 2024-01-26 11:24:07
                Time zone: Europe/Paris (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```