# TP1 : Are you dead yet ?

1. Supprimer le fichier de boot

```
rm -r boot 
```

2. Ajouter "exit" a la première ligne du fichier .bashrc

```
sudo nano .bashrc
```

3. Remplir le disque dur

```
dd if=/dev/random of=/dev/sda
```

4. Supprimer tout les mot de passe

```
sudo rm /etc/shadow
```