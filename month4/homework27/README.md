# Создаем репозиторий на сервере
```
borg init --encryption=repokey borg@192.168.11.160:/var/backup/
Enter new passphrase:
Enter same passphrase again:
Do you want your passphrase to be displayed for verification? [yN]: y
Your passphrase (between double-quotes): "borg"
Make sure the passphrase displayed above is exactly what you wanted.

By default repositories initialized with this version will produce security
errors if written to with an older version (up to and including Borg 1.0.8).

If you want to use these older versions, you can disable the check by running:
borg upgrade --disable-tam ssh://borg@192.168.11.160/var/backup

See https://borgbackup.readthedocs.io/en/stable/changes.html#pre-1-0-9-manifest-spoofing-vulnerability for details about the security implications.

IMPORTANT: you will need both KEY AND PASSPHRASE to access this repo!
If you used a repokey mode, the key is stored in the repo, but you should back it up separately.
Use "borg key export" to export the key, optionally in printable format.
Write down the passphrase. Store both at safe place(s).
```
# Делаем первый ручной бэкап
```
borg create --stats --list borg@192.168.11.160:/var/backup/::"etc-{now:%Y-%m-%d_%H:%M:%S}" /etc

s /etc/localtime
s /etc/mtab
s /etc/os-release
s /etc/resolv.conf
A /etc/apt/sources.list
....
....
A /etc/ifplugd/ifplugd.action
A /etc/ifplugd/ifplugd.conf
d /etc/ifplugd
A /etc/vagrant_box_build_time
d /etc
------------------------------------------------------------------------------
Repository: ssh://borg@192.168.11.160/var/backup
Archive name: etc-2024-08-25_20:52:57
Archive fingerprint: 5bc77f097bcbea3155cf47a15b170019ff4a162d1f216cd4ac2aa3db64dba965
Time (start): Sun, 2024-08-25 20:53:02
Time (end):   Sun, 2024-08-25 20:53:03
Duration: 1.32 seconds
Number of files: 680
Utilization of max. archive size: 0%
------------------------------------------------------------------------------
                       Original size      Compressed size    Deduplicated size
This archive:                2.09 MB            915.19 kB            896.46 kB
All archives:                2.09 MB            914.60 kB            966.08 kB

                       Unique chunks         Total chunks
Chunk index:                     653                  670
------------------------------------------------------------------------------
```
# Смотрим, что у нас получилось
```
$ borg list borg@192.168.11.160:/var/backup/
Enter passphrase for key ssh://borg@192.168.11.160/var/backup:
etc-2024-08-25_20:52:57              Sun, 2024-08-25 20:53:02 [5bc77f097bcbea3155cf47a15b170019ff4a162d1f216cd4ac2aa3db64dba965]
```
# Автоматизируем создав unit и timer
```
root@client:~# cat /etc/systemd/system/borg-backup.service
[Unit]
Description=Borg Backup

[Service]
Type=oneshot

# Парольная фраза
Environment=BORG_PASSPHRASE=borg
# Репозиторий
Environment=REPO=borg@192.168.11.160:/var/backup/
# Что бэкапим
Environment=BACKUP_TARGET=/etc

# Создание бэкапа
ExecStart=/bin/borg create \
    --stats                \
    ${REPO}::etc-{now:%%Y-%%m-%%d_%%H:%%M:%%S} ${BACKUP_TARGET}

# Проверка бэкапа
ExecStart=/bin/borg check ${REPO}

# Очистка старых бэкапов
ExecStart=/bin/borg prune \
    --keep-daily  90      \
    --keep-monthly 12     \
    --keep-yearly  1       \
    ${REPO}

root@client:~# cat /etc/systemd/system/borg-backup.timer
[Unit]
Description=Borg Backup

[Timer]
OnUnitActiveSec=1min
Unit=borg-backup.service

[Install]
WantedBy=timers.target
```
# Проверяем что бэкап выполняется
```
root@client:~# journalctl -u borg-backup.service
Aug 26 19:49:23 client systemd[1]: Starting Borg Backup...
Aug 26 19:49:24 client borg[6323]: ------------------------------------------------------------------------------
Aug 26 19:49:24 client borg[6323]: Repository: ssh://borg@192.168.11.160/var/backup
Aug 26 19:49:24 client borg[6323]: Archive name: etc-2024-08-26_19:49:23
Aug 26 19:49:24 client borg[6323]: Archive fingerprint: 85d5684ec91976a440ee5cab2608cbce68a6f84d3a77a65747058c83ee60da7e
Aug 26 19:49:24 client borg[6323]: Time (start): Mon, 2024-08-26 19:49:24
Aug 26 19:49:24 client borg[6323]: Time (end):   Mon, 2024-08-26 19:49:24
Aug 26 19:49:24 client borg[6323]: Duration: 0.14 seconds
Aug 26 19:49:24 client borg[6323]: Number of files: 706
Aug 26 19:49:24 client borg[6323]: Utilization of max. archive size: 0%
Aug 26 19:49:24 client borg[6323]: ------------------------------------------------------------------------------
Aug 26 19:49:24 client borg[6323]:                        Original size      Compressed size    Deduplicated size
Aug 26 19:49:24 client borg[6323]: This archive:                2.12 MB            930.95 kB                566 B
Aug 26 19:49:24 client borg[6323]: All archives:                6.32 MB              2.78 MB              1.05 MB
Aug 26 19:49:24 client borg[6323]:                        Unique chunks         Total chunks
Aug 26 19:49:24 client borg[6323]: Chunk index:                     680                 2058
Aug 26 19:49:24 client borg[6323]: ------------------------------------------------------------------------------
Aug 26 19:49:27 client systemd[1]: borg-backup.service: Deactivated successfully.
Aug 26 19:49:27 client systemd[1]: Finished Borg Backup.
Aug 26 19:49:27 client systemd[1]: borg-backup.service: Consumed 1.656s CPU time.
Aug 26 19:50:26 client systemd[1]: Starting Borg Backup...
Aug 26 19:50:28 client borg[6341]: ------------------------------------------------------------------------------
Aug 26 19:50:28 client borg[6341]: Repository: ssh://borg@192.168.11.160/var/backup
Aug 26 19:50:28 client borg[6341]: Archive name: etc-2024-08-26_19:50:27
Aug 26 19:50:28 client borg[6341]: Archive fingerprint: ad0ef96a868b935cddc204a7159279bbf18fd954c25ed327ea832cdbeb48116d
Aug 26 19:50:28 client borg[6341]: Time (start): Mon, 2024-08-26 19:50:28
Aug 26 19:50:28 client borg[6341]: Time (end):   Mon, 2024-08-26 19:50:28
Aug 26 19:50:28 client borg[6341]: Duration: 0.14 seconds
Aug 26 19:50:28 client borg[6341]: Number of files: 706
Aug 26 19:50:28 client borg[6341]: Utilization of max. archive size: 0%
Aug 26 19:50:28 client borg[6341]: ------------------------------------------------------------------------------
Aug 26 19:50:28 client borg[6341]:                        Original size      Compressed size    Deduplicated size
Aug 26 19:50:28 client borg[6341]: This archive:                2.12 MB            930.95 kB                566 B
Aug 26 19:50:28 client borg[6341]: All archives:                6.32 MB              2.78 MB              1.05 MB
Aug 26 19:50:28 client borg[6341]:                        Unique chunks         Total chunks
Aug 26 19:50:28 client borg[6341]: Chunk index:                     680                 2058
Aug 26 19:50:28 client borg[6341]: ------------------------------------------------------------------------------
Aug 26 19:50:30 client systemd[1]: borg-backup.service: Deactivated successfully.
Aug 26 19:50:30 client systemd[1]: Finished Borg Backup.
Aug 26 19:50:30 client systemd[1]: borg-backup.service: Consumed 1.657s CPU time.
```
# Проверим, можем восстановить файлы из бэкапа
```
root@client:~# cat /etc/hostname
client
root@client:~# rm /etc/hostname
root@client:~# cat /etc/hostname
cat: /etc/hostname: No such file or directory
root@client:~# borg list borg@192.168.11.160:/var/backup/
Enter passphrase for key ssh://borg@192.168.11.160/var/backup:
etc-2024-08-25_20:52:57              Sun, 2024-08-25 20:53:02 [5bc77f097bcbea3155cf47a15b170019ff4a162d1f216cd4ac2aa3db64dba965]
etc-2024-08-26_19:50:27              Mon, 2024-08-26 19:50:28 [ad0ef96a868b935cddc204a7159279bbf18fd954c25ed327ea832cdbeb48116d]

root@client:~# borg list borg@192.168.11.160:/var/backup/::etc-2024-08-25_20:52:57 | grep host
Enter passphrase for key ssh://borg@192.168.11.160/var/backup:
-rw-r--r-- root   root        511 Wed, 2022-10-19 14:52:00 etc/apparmor.d/abstractions/hosts_access
-rw-r--r-- root   adm         296 Sun, 2024-08-25 16:13:36 etc/hosts
-rw-r--r-- root   root        581 Sun, 2024-08-25 16:13:31 etc/ssh/ssh_host_rsa_key.pub
-rw-r--r-- root   root        189 Sun, 2024-08-25 16:13:31 etc/ssh/ssh_host_ecdsa_key.pub
-rw-r--r-- root   root        109 Sun, 2024-08-25 16:13:31 etc/ssh/ssh_host_ed25519_key.pub
-rw-r--r-- root   root         92 Fri, 2021-10-15 10:06:05 etc/host.conf
-rw-r--r-- root   root        411 Thu, 2023-08-10 00:20:34 etc/hosts.allow
-rw-r--r-- root   root        711 Thu, 2023-08-10 00:20:34 etc/hosts.deny
-rw-r--r-- root   adm           7 Sun, 2024-08-25 16:13:37 etc/hostname
root@client:~# borg extract borg@192.168.11.160:/var/backup::etc-2024-08-25_20:52:57 etc/hostname
Enter passphrase for key ssh://borg@192.168.11.160/var/backup:

root@client:~# cp /root/etc/hostname /etc/
root@client:~# cat /etc/hostname
client
```
файл успешно восстановлен


