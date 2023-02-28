# TP 3 : We do a little scripting

# I. Script carte d'identité

```bash
mael@pc:/srv/idcard$ sudo ./idcard.sh 
Machine name : pc
OS Ubuntu 22.04.1 LTS and kernel version is Linux 5.15.0-53-generic
IP : 10.33.19.79/22
RAM : 4,1Gi RAM restante sur 7,6Gi RAM totale
Disque : 360G space left
Top 5 processes by RAM usage :
  - /snap/brave/187/opt/brave.com/brave/brave
  - /snap/discord/145/usr/share/discord/Discord
  - /usr/bin/gnome-shell
  - /snap/code/113/usr/share/code/code
  - /snap/brave/187/opt/brave.com/brave/brave
Listening ports :
  -631 users:(("cupsd",pid=1446,fd=7))
  -6463 users:(("Discord",pid=5282,fd=30))
  -34855 users:(("code",pid=6510,fd=81))
  -3306 users:(("mariadbd",pid=1405,fd=19))
  -111 users:(("rpcbind",pid=1149,fd=4),("systemd",pid=1,fd=250))
  -53 users:(("systemd-resolve",pid=1151,fd=14))

Here is your random cat : ./cat.jpg
```

📁 **Fichier `/srv/idcard/idcard.sh`**

# II. Script youtube-dl

```
mael@pc:/srv/yt$ sudo ./yt.sh https://www.youtube.com/watch?v=jNQXAC9IVRw
Video https://www.youtube.com/watch?v=jNQXAC9IVRw was downloaded.
File path : /srv/yt/downloads/Me-at-the-zoo/Me-at-the-zoo
```

```
mael@pc:/srv/yt$ cat /var/log/yt/download.log 
[11/29/22 15:02:12] Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded. File path : /srv/yt/downloads/One-Second-Video/One-Second-Video
[11/29/22 15:03:29] Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded. File path : /srv/yt/downloads/tomato-anxiety/tomato-anxiety
[11/29/22 15:05:39] Video https://www.youtube.com/watch?v=jNQXAC9IVRw was downloaded. File path : /srv/yt/downloads/Me-at-the-zoo/Me-at-the-zoo
```

📁 **Le script `/srv/yt/yt.sh`**

📁 **Le fichier de log `/srv/yt/download.log`**

# III. MAKE IT A SERVICE

YES. Yet again. **On va en faire un [service](../../cours/notions/serveur/README.md#ii-service).**

L'idée :

➜ plutôt que d'appeler la commande à la main quand on veut télécharger une vidéo, **on va créer un service qui les téléchargera pour nous**

➜ le service devra **lire en permanence dans un fichier**

- s'il trouve une nouvelle ligne dans le fichier, il vérifie que c'est bien une URL de vidéo youtube
  - si oui, il la télécharge, puis enlève la ligne
  - sinon, il enlève juste la ligne

➜ **qui écrit dans le fichier pour ajouter des URLs ? Bah vous !**

- vous pouvez écrire une liste d'URL, une par ligne, et le service devra les télécharger une par une

---

Pour ça, procédez par étape :

- **partez de votre script précédent** (gardez une copie propre du premier script, qui doit être livré dans le dépôt git)
  - le nouveau script s'appellera `yt-v2.sh`
- **adaptez-le pour qu'il lise les URL dans un fichier** plutôt qu'en argument sur la ligne de commande
- **faites en sorte qu'il tourne en permanence**, et vérifie le contenu du fichier toutes les X secondes
  - boucle infinie qui :
    - lit un fichier
    - effectue des actions si le fichier n'est pas vide
    - sleep pendant une durée déterminée
- **il doit marcher si on précise une vidéo par ligne**
  - il les télécharge une par une
  - et supprime les lignes une par une
- **une fois que tout ça fonctionne, enfin, créez un service** qui lance votre script :
  - créez un fichier `/etc/systemd/system/yt.service`. Il comporte :
    - une brève description
    - un `ExecStart` pour indiquer que ce service sert à lancer votre script
    - une clause `User=` pour indiquer quel utilisateur doit lancer le script

```bash
[Unit]
Description=<Votre description>

[Service]
ExecStart=<Votre script>
User=<User>

[Install]
WantedBy=multi-user.target
```

> Pour rappel, après la moindre modification dans le dossier `/etc/systemd/system/`, vous devez exécuter la commande `sudo systemctl daemon-reload` pour dire au système de lire les changements qu'on a effectué.

Vous pourrez alors interagir avec votre service à l'aide des commandes habituelles `systemctl` :

- `systemctl status yt`
- `sudo systemctl start yt`
- `sudo systemctl stop yt`

## Rendu

📁 **Le script `/srv/yt/yt-v2.sh`**

📁 **Fichier `/etc/systemd/system/yt.service`**

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

- un `systemctl status yt` quand le service est en cours de fonctionnement
- un extrait de `journalctl -xe -u yt`

> Hé oui les commandes `journalctl` fonctionnent sur votre service pour voir les logs ! Et vous devriez constater que c'est vos `echo` qui pop. En résumé, **le STDOUT de votre script, c'est devenu les logs du service !**