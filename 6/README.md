# Module 1 : Reverse Proxy

Un reverse proxy est donc une machine que l'on place devant un autre service afin d'accueillir les clients et servir d'intermédiaire entre le client et le service.

Dans notre cas, on va là encore utiliser un outil libre : NGINX (et oui, il peut faire ça aussi, c'est même sa fonction première).

L'utilisation d'un reverse proxy peut apporter de nombreux bénéfices :

- décharger le service HTTP de devoir effectuer le chiffrement HTTPS (coûteux en performances)
- répartir la charge entre plusieurs services
- effectuer de la mise en cache
- fournir un rempart solide entre un hacker potentiel et le service et les données importantes
- servir de point d'entrée unique pour accéder à plusieurs sites web

## Sommaire

- [Module 1 : Reverse Proxy](#module-1--reverse-proxy)
  - [Sommaire](#sommaire)
- [I. Setup](#i-setup)
- [II. HTTPS](#ii-https)

# I. Setup

🖥️ **VM `proxy.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](../../2/README.md#checklist).**

➜ **On utilisera NGINX comme reverse proxy**

- installer le paquet `nginx`

```
[mael@localhost ~]$ sudo dnf install nginx
```

- démarrer le service `nginx`

```
[mael@localhost ~]$ sudo systemctl start nginx
```

- utiliser la commande `ss` pour repérer le port sur lequel NGINX écoute

```
[mael@localhost ~]$ sudo ss -alnpt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1204,fd=6),("nginx",pid=1203,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1204,fd=7),("nginx",pid=1203,fd=7))
```

- ouvrir un port dans le firewall pour autoriser le trafic vers NGINX

```
[mael@localhost ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[mael@localhost ~]$ sudo firewall-cmd --reload
success
```

- utiliser une commande `ps -ef` pour déterminer sous quel utilisateur tourne NGINX

```
[mael@localhost ~]$ ps -ef | grep nginx
root        1203       1  0 15:19 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1204    1203  0 15:19 ?        00:00:00 nginx: worker process
mael        1213    1017  0 15:21 pts/0    00:00:00 grep --color=auto nginx
```

- vérifier que le page d'accueil NGINX est disponible en faisant une requête HTTP sur le port 80 de la machine

```
[mael@localhost ~]$ curl 10.105.1.32 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
100  7620  100  7620    0     0   496k      0 --:--:-- --:--:-- --:--:--  531k
curl: (23) Failed writing body
```

➜ **Configurer NGINX**

- nous ce qu'on veut, c'pas une page d'accueil moche, c'est que NGINX agisse comme un reverse proxy entre les clients et notre serveur Web
- deux choses à faire :
  - créer un fichier de configuration NGINX
    - la conf est dans `/etc/nginx`
    - procédez comme pour Apache : repérez les fichiers inclus par le fichier de conf principal, et créez votre fichier de conf en conséquence
  - NextCloud est un peu exigeant, et il demande à être informé si on le met derrière un reverse proxy
    - y'a donc un fichier de conf NextCloud à modifier
    - c'est un fichier appelé `config.php`

```
[mael@localhost ~]$ sudo nano /etc/nginx/conf.d/proxy.conf
```

```
[mael@web ~]$ sudo nano /var/www/tp6_nextcloud/config/config.php 
[mael@web ~]$ sudo cat /var/www/tp6_nextcloud/config/config.php
  'trusted_proxies' =>
  array (
    0 => '10.105.1.32'
  ),
```

Référez-vous à monsieur Google pour tout ça :)

Exemple de fichier de configuration minimal NGINX.:

```nginx
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp6.linux;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying 
        proxy_pass http://10.105.1.32:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```

➜ **Modifier votre fichier `hosts` de VOTRE PC**

```
mael@pc:~$ sudo cat /etc/hosts | grep web.tp6.linux
10.105.1.32     web.tp6.linux
```

➜ **Faites en sorte de**

- rendre le serveur `web.tp6.linux` injoignable
- sauf depuis l'IP du reverse proxy
- en effet, les clients ne doivent pas joindre en direct le serveur web : notre reverse proxy est là pour servir de serveur frontal
- **comment ?** Je vous laisser là encore chercher un peu par vous-mêmes (hint : firewall)

```
[mael@web ~]$ sudo firewall-cmd --zone=trusted --add-source=10.105.1.32 --permanent
success
[mael@web ~]$ sudo firewall-cmd --permanent --zone=drop --change-interface=enp0s8
The interface is under control of NetworkManager, setting zone to 'drop'.
success
[mael@web ~]$ sudo firewall-cmd --reload
success
```

➜ **Une fois que c'est en place**

```
mael@pc:~$ ping 10.105.1.32
PING 10.105.1.32 (10.105.1.32) 56(84) bytes of data.
64 bytes from 10.105.1.32: icmp_seq=1 ttl=64 time=0.588 ms
64 bytes from 10.105.1.32: icmp_seq=2 ttl=64 time=0.763 ms
64 bytes from 10.105.1.32: icmp_seq=3 ttl=64 time=0.694 ms
64 bytes from 10.105.1.32: icmp_seq=4 ttl=64 time=0.618 ms
^C
--- 10.105.1.32 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3065ms
rtt min/avg/max/mdev = 0.588/0.665/0.763/0.068 ms
mael@pc:~$ ping 10.105.1.11
PING 10.105.1.11 (10.105.1.11) 56(84) bytes of data.
^C
--- 10.105.1.11 ping statistics ---
21 packets transmitted, 0 received, 100% packet loss, time 20484ms
```

# II. HTTPS

Le but de cette section est de permettre une connexion chiffrée lorsqu'un client se connecte. Avoir le ptit HTTPS :)

Le principe :

- on génère une paire de clés sur le serveur `proxy.tp6.linux`
  - une des deux clés sera la clé privée : elle restera sur le serveur et ne bougera jamais
  - l'autre est la clé publique : elle sera stockée dans un fichier appelé *certificat*
    - le *certificat* est donné à chaque client qui se connecte au site
- on ajuste la conf NGINX
  - on lui indique le chemin vers le certificat et la clé privée afin qu'il puisse les utiliser pour chiffrer le trafic
  - on lui demande d'écouter sur le port convetionnel pour HTTPS : 443 en TCP

Je vous laisse Google vous-mêmes "nginx reverse proxy nextcloud" ou ce genre de chose :)

# Module 2 : Sauvegarde du système de fichiers

Dans cette partie, **on va monter un *serveur de sauvegarde* qui sera chargé d'accueillir les sauvegardes des autres machines**, en particulier du serveur Web qui porte NextCloud.

Le *serveur de sauvegarde* sera un serveur NFS. NFS est un protocole qui permet de partager un dossier à travers le réseau.

Ainsi, notre *serveur de sauvegarde* pourra partager un dossier différent à chaque machine qui a besoin de stocker des données sur le long terme.

Dans le cadre du TP, le serveur partagera un dossier à la machine `web.tp6.linux`.

Sur la machine `web.tp6.linux` s'exécutera à un intervalles réguliers un script qui effectue une sauvegarde des données importantes de NextCloud et les place dans le dossier partagé.

Ainsi, ces données seront archivées sur le *serveur de sauvegarde*.

## Sommaire

- [Module 2 : Sauvegarde du système de fichiers](#module-2--sauvegarde-du-système-de-fichiers)
  - [Sommaire](#sommaire)
  - [I. Script de backup](#i-script-de-backup)
    - [1. Ecriture du script](#1-ecriture-du-script)
    - [2. Clean it](#2-clean-it)
    - [3. Service et timer](#3-service-et-timer)
  - [II. NFS](#ii-nfs)
    - [1. Serveur NFS](#1-serveur-nfs)
    - [2. Client NFS](#2-client-nfs)

## I. Script de backup

Partie à réaliser sur `web.tp6.linux`.

### 1. Ecriture du script

🌞 **Ecrire le script `bash`**

- il s'appellera `tp6_backup.sh`
- il devra être stocké dans le dossier `/srv` sur la machine `web.tp6.linux`
- le script doit commencer par un *shebang* qui indique le chemin du programme qui exécutera le contenu du script
  - ça ressemble à ça si on veut utiliser `/bin/bash` pour exécuter le contenu de notre script :

```
#!/bin/bash
```

- pour apprendre quels dossiers il faut sauvegarder dans tout le bordel de NextCloud, [il existe une page de la doc officielle qui vous informera](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/backup.html)
- vous devez compresser les dossiers importants
  - au format `.zip` ou `.tar.gz`
  - le fichier produit sera stocké dans le dossier `/srv/backup/`
  - il doit comporter la date, l'heure la minute et la seconde où a été effectué la sauvegarde
    - par exemple : `nextcloud_2211162108.tar.gz`

> On utilise la notation américaine de la date `yymmdd` avec l'année puis le mois puis le jour, comme ça, un tri alphabétique des fichiers correspond à un tri dans l'ordre temporel :)

### 2. Clean it

On va rendre le script un peu plus propre vous voulez bien ?

➜ **Utiliser des variables** déclarées en début de script pour stocker les valeurs suivantes :

- le nom du fichier `.tar.gz` ou `zip` produit par le script

```bash
# Déclaration d'une variable toto qui contient la string "tata"
toto="tata"

# Appel de la variable toto
# Notez l'utilisation du dollar et des double quotes
echo "$toto"
```

---

➜ **Commentez le script**

- au minimum un en-tête sous le shebang
  - date d'écriture du script
  - nom/pseudo de celui qui l'a écrit
  - un résumé TRES BREF de ce que fait le script

---

➜ **Environnement d'exécution du script**

- créez un utilisateur sur la machine `web.tp6.linux`
  - il s'appellera `backup`
  - son homedir sera `/srv/backup/`
  - son shell sera `/usr/bin/nologin`
- cet utilisateur sera celui qui lancera le script
- le dossier `/srv/backup/` doit appartenir au user `backup`
- pour tester l'exécution du script en tant que l'utilisateur `backup`, utilisez la commande suivante :

```bash
$ sudo -u backup /srv/tp6_backup.sh
```

### 3. Service et timer

🌞 **Créez un *service*** système qui lance le script

- inspirez-vous des *services* qu'on a créés et/ou manipulés jusqu'à maintenant
- la seule différence est que vous devez rajouter `Type=oneshot` dans la section `[Service]` pour indiquer au système que ce service ne tournera pas à l'infini (comme le fait un serveur web par exemple) mais se terminera au bout d'un moment
- vous appelerez le service `backup.service`
- assurez-vous qu'il fonctionne en utilisant des commandes `systemctl`

```bash
$ sudo systemctl status backup
$ sudo systemctl start backup
```

🌞 **Créez un *timer*** système qui lance le *service* à intervalles réguliers

- le fichier doit être créé dans le même dossier
- le fichier doit porter le même nom
- l'extension doit être `.timer` au lieu de `.service`
- ainsi votre fichier s'appellera `backup.timer`
- la syntaxe est la suivante :

```systemd
[Unit]
Description=Run service X

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

> [La doc Arch est cool à ce sujet.](https://wiki.archlinux.org/title/systemd/Timers)

🌞 Activez l'utilisation du *timer*

- vous vous servirez des commandes suivantes :

```bash
# demander au système de lire le contenu des dossiers de config
# il découvrira notre nouveau timer
$ sudo systemctl daemon-reload

# on peut désormais interagir avec le timer
$ sudo systemctl start backup.timer
$ sudo systemctl enable backup.timer
$ sudo systemctl status backup.timer

# il apparaîtra quand on demande au système de lister tous les timers
$ sudo systemctl list-timers
```

## II. NFS

### 1. Serveur NFS

> On a déjà fait ça au TP4 ensemble :)

🖥️ **VM `storage.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](../../2/README.md#checklist).**

🌞 **Préparer un dossier à partager sur le réseau** (sur la machine `storage.tp6.linux`)

- créer un dossier `/srv/nfs_shares`
- créer un sous-dossier `/srv/nfs_shares/web.tp6.linux/`

> Et ouais pour pas que ce soit le bordel, on va appeler le dossier comme la machine qui l'utilisera :)

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)

- installer le paquet `nfs-utils`
- créer le fichier `/etc/exports`
  - remplissez avec un contenu adapté
  - j'vous laisse faire les recherches adaptées pour ce faire
- ouvrir les ports firewall nécessaires
- démarrer le service
- je vous laisse check l'internet pour trouver [ce genre de lien](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9) pour + de détails

### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

- il devra monter le dossier `/srv/nfs_shares/web.tp6.linux/` qui se trouve sur `storage.tp6.linux`
- le dossier devra être monté sur `/srv/backup/`
- je vous laisse là encore faire vos recherches pour réaliser ça !
- faites en sorte que le dossier soit automatiquement monté quand la machine s'allume

🌞 **Tester la restauration des données** sinon ça sert à rien :)

- livrez-moi la suite de commande que vous utiliseriez pour restaurer les données dans une version antérieure