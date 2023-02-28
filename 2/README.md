# TP2 : Appréhender l'environnement Linux

## 1. Analyse du service

🌞 **S'assurer que le service `sshd` est démarré**

```
systemctl status sshd
```

```
 sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-11-22 16:41:09 CET; 3min 46s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 721 (sshd)
      Tasks: 1 (limit: 5904)
     Memory: 5.5M
        CPU: 174ms
     CGroup: /system.slice/sshd.service
             └─721 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Nov 22 16:41:09 localhost systemd[1]: Starting OpenSSH server daemon...
Nov 22 16:41:09 localhost sshd[721]: Server listening on 0.0.0.0 port 22.
Nov 22 16:41:09 localhost sshd[721]: Server listening on :: port 22.
Nov 22 16:41:09 localhost systemd[1]: Started OpenSSH server daemon.
Nov 22 16:42:00 localhost.localdomain sshd[887]: Accepted password for mael from 10.4.1.0 port 46680 ssh2
Nov 22 16:42:00 localhost.localdomain sshd[887]: pam_unix(sshd:session): session opened for user mael(uid=1000) by (uid=0)
```

🌞 **Analyser les processus liés au service SSH**

```
[mael@localhost ~]$ ps -ef | grep sshd
root         721       1  0 16:41 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         887     721  0 16:41 ?        00:00:00 sshd: mael [priv]
mael         891     887  0 16:41 ?        00:00:00 sshd: mael@pts/0
mael         922     892  0 16:52 pts/0    00:00:00 grep --color=auto sshd
```

🌞 **Déterminer le port sur lequel écoute le service SSH**

```
[mael@localhost ~]$ sudo ss -alnpt | grep sshd
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=721,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=721,fd=4))
```

🌞 **Consulter les logs du service SSH**

```
[mael@localhost ~]$ journalctl -xe | grep sshd
Nov 22 16:41:07 localhost systemd[1]: Created slice Slice /system/sshd-keygen.
░░ Subject: A start job for unit sshd-keygen@ecdsa.service has finished successfully
░░ A start job for unit sshd-keygen@ecdsa.service has finished successfully.
░░ Subject: A start job for unit sshd-keygen@ed25519.service has finished successfully
░░ A start job for unit sshd-keygen@ed25519.service has finished successfully.
░░ Subject: A start job for unit sshd-keygen@rsa.service has finished successfully
░░ A start job for unit sshd-keygen@rsa.service has finished successfully.
Nov 22 16:41:08 localhost systemd[1]: Reached target sshd-keygen.target.
░░ Subject: A start job for unit sshd-keygen.target has finished successfully
░░ A start job for unit sshd-keygen.target has finished successfully.
░░ Subject: A start job for unit sshd.service has begun execution
░░ A start job for unit sshd.service has begun execution.
Nov 22 16:41:09 localhost sshd[721]: Server listening on 0.0.0.0 port 22.
Nov 22 16:41:09 localhost sshd[721]: Server listening on :: port 22.
░░ Subject: A start job for unit sshd.service has finished successfully
░░ A start job for unit sshd.service has finished successfully.
Nov 22 16:41:44 localhost.localdomain sudo[879]:     mael : TTY=tty1 ; PWD=/home/mael ; USER=root ; COMMAND=/bin/systemctl status sshd
Nov 22 16:42:00 localhost.localdomain sshd[887]: Accepted password for mael from 10.4.1.0 port 46680 ssh2
Nov 22 16:42:00 localhost.localdomain sshd[887]: pam_unix(sshd:session): session opened for user mael(uid=1000) by (uid=0)
```

```
[mael@localhost ~]$ sudo tail -n 10 /var/log/secure 
[sudo] password for mael: 
Nov 22 16:55:05 localhost sudo[924]: pam_unix(sudo:auth): authentication failure; logname=mael uid=1000 euid=0 tty=/dev/pts/0 ruser=mael rhost=  user=mael
Nov 22 16:55:11 localhost unix_chkpwd[928]: password check failed for user (mael)
Nov 22 16:55:17 localhost unix_chkpwd[930]: password check failed for user (mael)
Nov 22 16:55:19 localhost sudo[924]:    mael : 3 incorrect password attempts ; TTY=pts/0 ; PWD=/home/mael ; USER=root ; COMMAND=/sbin/ss -alnpt
Nov 22 16:55:25 localhost sudo[931]:    mael : TTY=pts/0 ; PWD=/home/mael ; USER=root ; COMMAND=/sbin/ss -alnpt
Nov 22 16:55:25 localhost sudo[931]: pam_unix(sudo:session): session opened for user root(uid=0) by mael(uid=1000)
Nov 22 16:55:25 localhost sudo[931]: pam_unix(sudo:session): session closed for user root
Nov 22 16:56:02 localhost sudo[936]:    mael : TTY=pts/0 ; PWD=/home/mael ; USER=root ; COMMAND=/sbin/ss -alnpt
Nov 22 16:56:02 localhost sudo[936]: pam_unix(sudo:session): session opened for user root(uid=0) by mael(uid=1000)
Nov 22 16:56:02 localhost sudo[936]: pam_unix(sudo:session): session closed for user root
```

## 2. Modification du service

🌞 **Identifier le fichier de configuration du serveur SSH**

```
[mael@localhost ~]$ ls -l /etc/ssh/
-rw-r--r--. 1 root root       1921 Sep 20 20:46 ssh_config
```

🌞 **Modifier le fichier de conf**

```
[mael@localhost ~]$ cat /etc/ssh/sshd_config | grep Port
    Port 30868
```

```
[mael@localhost ~]$ sudo firewall-cmd --add-port=30868/tcp --permanent
success
[mael@localhost ~]$ sudo firewall-cmd --remove-service=ssh --permanent
success
```

```
[mael@localhost ~]$ sudo firewall-cmd --reload
success
[mael@localhost ~]$ sudo firewall-cmd --list-all | grep ports
  ports: 30868/tcp
```

🌞 **Redémarrer le service**

```
[mael@localhost ~]$ sudo systemctl restart sshd
```

🌞 **Effectuer une connexion SSH sur le nouveau port**

```
mael@pc:~$ ssh mael@10.4.1.2 -p 30868
mael@10.4.1.2's password: 
Last login: Fri Nov 25 15:11:57 2022 from 10.4.1.0
[mael@localhost ~]$ 
```

# II. Service HTTP

## 1. Mise en place

🌞 **Installer le serveur NGINX**

```
[mael@localhost ~]$ sudo dnf install nginx
```

🌞 **Démarrer le service NGINX**

```
[mael@localhost ~]$ sudo systemctl start nginx
```

🌞 **Déterminer sur quel port tourne NGINX**

```
[mael@localhost ~]$ sudo ss -alnpt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=10784,fd=6),("nginx",pid=10783,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=10784,fd=7),("nginx",pid=10783,fd=7))
```

```
[mael@localhost ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```

🌞 **Déterminer les processus liés à l'exécution de NGINX**

```
[mael@localhost ~]$ ps -ef | grep nginx
root       10783       1  0 18:58 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      10784   10783  0 18:58 ?        00:00:00 nginx: worker process
mael       10827     914  0 19:02 pts/0    00:00:00 grep --color=auto nginx
```

🌞 **Euh wait**

```
mael@pc:~$ curl 10.4.1.2 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
10    <title>HTTP Server Test Page powered by: Rocky Linux</title>
0    <style type="text/css">
  7620  100  7620    0     0  2250k      0 --:--:-- --:--:-- --:--:-- 2480k
curl: (23) Failed writing body
```

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```
[mael@localhost ~]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 Oct 31 16:37 /etc/nginx/nginx.conf
```

🌞 **Trouver dans le fichier de conf**

```
[mael@localhost ~]$ cat /etc/nginx/nginx.conf | grep server -A 10
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

```
[mael@localhost ~]$ cat /etc/nginx/nginx.conf | grep include
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;

```

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

```
[mael@localhost ~]$ sudo mkdir /var/www
[mael@localhost ~]$ sudo mkdir /var/www/tp2_linux
[mael@localhost ~]$ sudo nano /var/www/tp2_linux/index.html
[mael@localhost ~]$ sudo cat /var/www/tp2_linux/index.html 
<h1>MEOW mon premier serveur web</h1>
```

🌞 **Adapter la conf NGINX**

```
[mael@localhost ~]$ echo $RANDOM
12939
[mael@localhost ~]$ sudo nano /etc/nginx/conf.d/site.conf
[mael@localhost ~]$ sudo cat /etc/nginx/conf.d/site.conf 
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen 12939;

  root /var/www/tp2_linux;
}
```

```
[mael@localhost ~]$ sudo firewall-cmd --add-port=12939/tcp --permanent
success
[mael@localhost ~]$ sudo firewall-cmd --reload
success
[mael@localhost ~]$ sudo systemctl restart nginx
```

🌞 **Visitez votre super site web**

```
mael@pc:~$ curl 10.4.1.2:12939
<h1>MEOW mon premier serveur web</h1>
```

# III. Your own services

## 1. Au cas où vous auriez oublié

```
[mael@localhost ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[mael@localhost ~]$ sudo firewall-cmd --reload
success
```

```
[mael@localhost ~]$ nc -l 8888
a
b
```

```
mael@pc:~$ nc 10.4.1.2 8888
a
b
```

## 2. Analyse des services existants

🌞 **Afficher le fichier de service SSH**

```
[mael@localhost ~]$ sudo systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
```

```
[mael@localhost ~]$ cat /usr/lib/systemd/system/sshd.service | grep ExecStart=
ExecStart=/usr/sbin/sshd -D $OPTIONS
```

🌞 **Afficher le fichier de service NGINX**

```
[mael@localhost ~]$ cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```

## 3. Création de service

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

```
[mael@localhost ~]$ echo $RANDOM
11742
[mael@localhost ~]$ sudo nano /etc/systemd/system/tp2_nc.service
[mael@localhost ~]$ cat /etc/systemd/system/tp2_nc.service 
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 11742
```

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

```
[mael@localhost ~]$ sudo systemctl daemon-reload
```

🌞 **Démarrer notre service de ouf**

```
[mael@localhost ~]$ sudo systemctl start tp2_nc
```

🌞 **Vérifier que ça fonctionne**

```
[mael@localhost ~]$ sudo systemctl status tp2_nc
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Tue 2022-12-13 23:25:58 CET; 6s ago
```

```
[mael@localhost ~]$ sudo ss -alnpt | grep nc
LISTEN 0      10           0.0.0.0:11742      0.0.0.0:*    users:(("nc",pid=1132,fd=4))                           
LISTEN 0      10              [::]:11742         [::]:*    users:(("nc",pid=1132,fd=3))
```

```
[mael@localhost ~]$ sudo firewall-cmd --add-port=11742/tcp --permanent
success
[mael@localhost ~]$ sudo firewall-cmd --reload
success
```

🌞 **Les logs de votre service**

```
[mael@localhost ~]$ sudo journalctl -xe -u tp2_nc | grep Start
Nov 24 23:25:58 localhost.localdomain systemd[1]: Started Super netcat tout fou.
```

```
[mael@localhost ~]$ sudo journalctl -xe -u tp2_nc | grep localhost
Nov 24 23:29:56 localhost.localdomain nc[1132]: a
Nov 24 23:29:56 localhost.localdomain nc[1132]: a
Nov 24 23:29:56 localhost.localdomain nc[1132]: a
```

```
[mael@localhost ~]$ sudo journalctl -xe -u tp2_nc | grep Deactivated
Nov 24 23:29:57 localhost.localdomain systemd[1]: tp2_nc.service: Deactivated successfully.
```

🌞 **Affiner la définition du service**

```
[mael@localhost ~]$ sudo nano /etc/systemd/system/tp2_nc.service
[mael@localhost ~]$ cat /etc/systemd/system/tp2_nc.service 
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 11742
Restart=always
[mael@localhost ~]$ sudo systemctl daemon-reload
```
