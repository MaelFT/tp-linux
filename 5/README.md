# Partie 1 : Mise en place et maîtrise du serveur Web

## 1. Installation

🌞 **Installer le serveur Apache**

```
[mael@localhost ~]$ sudo dnf install httpd
```

🌞 **Démarrer le service Apache**

```
[mael@localhost ~]$ sudo systemctl start httpd
```

```
[mael@localhost ~]$ sudo systemctl enable httpd
```

```
[mael@localhost ~]$ sudo ss -ltunp | grep httpd
tcp   LISTEN 0      511                *:80              *:*    users:(("httpd",pid=1784,fd=4),("httpd",pid=1783,fd=4),("httpd",pid=1782,fd=4),("httpd",pid=1780,fd=4))
```

```
[mael@localhost ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[mael@localhost ~]$ sudo firewall-cmd --reload
success
[mael@localhost ~]$ sudo firewall-cmd --list-all
  ports: 80/tcp
```

🌞 **TEST**

```
[mael@localhost ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor pre>
     Active: active (running) since Mon 2022-12-12 16:17:03 CET; 3min 53s ago
```

```
[mael@localhost ~]$ curl localhost | head -n 5
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
```

```
mael@pc:~$ curl 10.105.1.11:80 | head -n 5
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
```

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```
[mael@localhost ~]$ cat /lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#	[Service]
#	Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```
[mael@localhost ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep User
User apache
```

```
[mael@localhost ~]$ ps -ef | grep apache
apache      1781    1780  0 16:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1782    1780  0 16:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1783    1780  0 16:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1784    1780  0 16:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

```
[mael@localhost ~]$ ls -al /usr/share/testpage/
total 12
drwxr-xr-x.  2 root root   24 Dec 12 16:00 .
drwxr-xr-x. 83 root root 4096 Dec 12 16:00 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
```

🌞 **Changer l'utilisateur utilisé par Apache**

- créez un nouvel utilisateur
  - pour les options de création, inspirez-vous de l'utilisateur Apache existant
    - le fichier `/etc/passwd` contient les informations relatives aux utilisateurs existants sur la machine
    - servez-vous en pour voir la config actuelle de l'utilisateur Apache par défaut (son homedir et son shell en particulier)
- modifiez la configuration d'Apache pour qu'il utilise ce nouvel utilisateur
  - montrez la ligne de conf dans le compte rendu, avec un `grep` pour ne montrer que la ligne importante
- redémarrez Apache
- utilisez une commande `ps` pour vérifier que le changement a pris effet
  - vous devriez voir un processus au moins qui tourne sous l'identité de votre nouvel utilisateur

🌞 **Faites en sorte que Apache tourne sur un autre port**

- modifiez la configuration d'Apache pour lui demander d'écouter sur un autre port de votre choix
  - montrez la ligne de conf dans le compte rendu, avec un `grep` pour ne montrer que la ligne importante
- ouvrez ce nouveau port dans le firewall, et fermez l'ancien
- redémarrez Apache
- prouvez avec une commande `ss` que Apache tourne bien sur le nouveau port choisi
- vérifiez avec `curl` en local que vous pouvez joindre Apache sur le nouveau port
- vérifiez avec votre navigateur que vous pouvez joindre le serveur sur le nouveau port

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

➜ **Si c'est tout bon vous pouvez passer à [la partie 2.](../part2/README.md)**

# Partie 2 : Mise en place et maîtrise du serveur de base de données

🌞 **Install de MariaDB sur `db.tp5.linux`**

```
[mael@localhost ~]$ sudo dnf install mariadb-server
```

```
[mael@localhost ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
[mael@localhost ~]$ sudo systemctl start mariadb
```

```
[mael@localhost ~]$ sudo mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] Y
Enabled successfully!
Reloading privilege tables..
 ... Success!


You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] Y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] Y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] Y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] Y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] Y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

🌞 **Port utilisé par MariaDB**

```
[mael@localhost ~]$ sudo ss -lnmpt | grep mariadb
LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=3978,fd=19))
```

```
[mael@localhost ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[mael@localhost ~]$ sudo firewall-cmd --reload
success
[mael@localhost ~]$ sudo firewall-cmd --list-all
public (active)
  ports: 3306/tcp
```

🌞 **Processus liés à MariaDB**

 ```
[mael@localhost ~]$ ps -ef | grep mariadb
mysql       3978       1  0 17:25 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
 ```

 # Partie 3 : Configuration et mise en place de NextCloud

## 1. Base de données

🌞 **Préparation de la base pour NextCloud**

```
[mael@localhost ~]$ sudo mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

```sql
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.015 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.009 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.002 sec)
```

🌞 **Exploration de la base de données**

```
[mael@localhost ~]$ sudo dnf install mysql
```

```
[mael@localhost ~]$ mysql -u nextcloud -h 10.105.1.12 -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 4
Server version: 5.5.5-10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

```sql
SHOW DATABASES;
USE <DATABASE_NAME>;
SHOW TABLES;
```

```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.01 sec)

mysql> USE nextcloud
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)

```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

```
MariaDB [mysql]> SELECT user,host FROM user;
+-------------+-------------+
| User        | Host        |
+-------------+-------------+
| nextcloud   | 10.105.1.11 |
| mariadb.sys | localhost   |
| mysql       | localhost   |
| root        | localhost   |
+-------------+-------------+
4 rows in set (0.005 sec)
```

## 2. Serveur Web et NextCloud

🌞 **Install de PHP**

```bash
# On ajoute le dépôt CRB
$ sudo dnf config-manager --set-enabled crb
# On ajoute le dépôt REMI
$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

# On liste les versions de PHP dispos, au passage on va pouvoir accepter les clés du dépôt REMI
$ dnf module list php

# On active le dépôt REMI pour récupérer une version spécifique de PHP, celle recommandée par la doc de NextCloud
$ sudo dnf module enable php:remi-8.1 -y

# Eeeet enfin, on installe la bonne version de PHP : 8.1
$ sudo dnf install -y php81-php
```

```
[mael@localhost ~]$ sudo dnf config-manager --set-enabled crb
[mael@localhost ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
[mael@localhost ~]$ dnf module list php
[mael@localhost ~]$ sudo dnf module enable php:remi-8.1 -y
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```
[mael@localhost ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```

🌞 **Récupérer NextCloud**

```
[mael@localhost ~]$ sudo mkdir /var/www/tp5_nextcloud
```

```
[mael@localhost tp5_nextcloud]$ sudo curl https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip -o nextcloud.zip
```

```
[mael@localhost tp5_nextcloud]$ sudo dnf install unzip
```

```
[mael@localhost tp5_nextcloud]$ sudo unzip nextcloud.zip
```

```
[mael@localhost tp5_nextcloud]$ ls index.html 
index.html
```

```
[mael@localhost www]$ sudo chown mael mael tp5_nextcloud/
```

🌞 **Adapter la configuration d'Apache**

```
[mael@localhost ~]$ sudo nano /etc/httpd/conf/nextcloud.conf
```

```apache
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf

```
[mael@localhost ~]$ sudo systemctl restart httpd
```

## 3. Finaliser l'installation de NextCloud

```
MariaDB [nextcloud]> SHOW TABLES;
95 rows in set (0.002 sec)
```
