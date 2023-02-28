# Partie 1 : Partitionnement du serveur de stockage

🌞 **Partitionner le disque à l'aide de LVM**

```
[mael@localhost ~]$ sudo pvcreate /dev/sdb
[sudo] password for user1: 
  Physical volume "/dev/sdb" successfully created.
```

```
[mael@localhost ~]$ sudo pvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb82e9ad1-30a0508e_ PVID bTTF5ek2AUZ2PZjuz1mLgyDy39lqp5wo last seen on /dev/sda2 not found.
  PV         VG Fmt  Attr PSize PFree
  /dev/sdb      lvm2 ---  2.00g 2.00g
```

```
[mael@localhost ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
```

```
[mael@localhost ~]$ sudo vgs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb82e9ad1-30a0508e_ PVID bTTF5ek2AUZ2PZjuz1mLgyDy39lqp5wo last seen on /dev/sda2 not found.
  VG      #PV #LV #SN Attr   VSize  VFree 
  storage   1   0   0 wz--n- <2.00g <2.00g
```

```
[mael@localhost ~]$ sudo lvcreate -l 100%FREE storage 
  Logical volume "lvol0" created.
```

```
[mael@localhost ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBb82e9ad1-30a0508e_ PVID bTTF5ek2AUZ2PZjuz1mLgyDy39lqp5wo last seen on /dev/sda2 not found.
  LV    VG      Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvol0 storage -wi-a----- <2.00g  
```

🌞 **Formater la partition**

```
[mael@localhost ~]$ sudo mkfs -t ext4 /dev/storage/lvol0 
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 695e4d6e-dd62-4494-b7f6-ba52c34dfd37
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done 
```

🌞 **Monter la partition**

```
[mael@localhost ~]$ sudo mkdir /mnt/storage
```

```
[mael@localhost ~]$ sudo mount /dev/storage/lvol0 /mnt/storage/
```

```
[mael@localhost ~]$ df -h | grep storage
/dev/mapper/storage-lvol0  2.0G   24K  1.9G   1% /mnt/storage
```

```
[mael@localhost ~]$ sudo nano /etc/fstab 
[mael@localhost ~]$ sudo umount /mnt/storage/
[mael@localhost ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/mnt/storage             : successfully mounted
```

# Partie 2 : Serveur de partage de fichiers

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

```
[mael@localhost ~]$ sudo dnf install nfs-utils
```

```
[mael@localhost ~]$ sudo mkdir /mnt/storage/site_web_1 -p
[mael@localhost ~]$ ls -dl /mnt/storage/site_web_1/
drwxr-xr-x. 2 root root 4096 Dec  6 14:42 /mnt/storage/site_web_1/
[mael@localhost ~]$ sudo chown nobody /mnt/storage/site_web_1/
```

```
[mael@localhost ~]$ sudo mkdir /mnt/storage/site_web_2 -p
[mael@localhost ~]$ ls -dl /mnt/storage/site_web_2/
drwxr-xr-x. 2 root root 4096 Dec  6 14:43 /mnt/storage/site_web_2/
[mael@localhost ~]$ sudo chown nobody /mnt/storage/site_web_2/
```

- contenu du fichier `/etc/exports`

```
  GNU nano 5.6.1                     /etc/exports                               
/mnt/storage 10.4.1.5(rw,sync,no_subtree_check)
```

```
[mael@localhost ~]$ sudo systemctl enable nfs-server
[mael@localhost ~]$ sudo systemctl start nfs-server
[mael@localhost ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendo>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Tue 2022-12-06 16:15:26 CET; 5min ago
   Main PID: 924 (code=exited, status=0/SUCCESS)
        CPU: 41ms
```

```
[mael@localhost ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client ssh
```

```
[mael@localhost ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[mael@localhost ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[mael@localhost ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[mael@localhost ~]$ sudo firewall-cmd --reload
success
```

```
[mael@localhost ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

```
[mael@localhost ~]$ sudo dnf install nfs-utils
```

- contenu du fichier `/etc/fstab` dans le compte-rendu notamment

**Ok, on a fini avec la partie 2, let's head to [the part 3](./../part3/README.md).**

