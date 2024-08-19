Созданы три машины 
web - где работает nginx и с которого пишем логи nginx и логи audit
log - центральное хранилище rsyslog
logserver - откуда пишем все логи

логи с nginx настроил в самом конфиге nginx
```
access_log syslog:server=192.168.56.15:514,tag=nginx_access,severity=info combined;
```
для того, чтобы отправлять логи аудита
включаем модуль преобразования файлов в сообщения syslog
```
$ModLoad imfile
```
и создаем конфиг для отправки
```
$InputFileName /var/log/audit/audit.log
$InputFileTag audit_log:
$InputFileStateFile audit_log
$InputFileSeverity info
$InputFileFacility local6
$InputRunFileMonitor

local6.* @192.168.56.15:514
```
проверяем, что логи приходят
```
root@log:~# ll /var/log/rsyslog/
total 20
drwx------ 5 syslog syslog 4096 Aug 17 19:50 ./
drwxrwxr-x 9 root   syslog 4096 Aug 18 16:13 ../
drwx------ 2 syslog syslog 4096 Aug 19 18:59 log/
drwx------ 2 syslog syslog 4096 Aug 19 16:45 logserver/
drwx------ 2 syslog syslog 4096 Aug 19 20:09 web/
root@log:~# ll /var/log/rsyslog/log
log/       logserver/
root@log:~# ll /var/log/rsyslog/logserver/
total 60
drwx------ 2 syslog syslog  4096 Aug 19 16:45 ./
drwx------ 5 syslog syslog  4096 Aug 17 19:50 ../
-rw-r--r-- 1 syslog syslog  9965 Aug 19 20:17 CRON.log
-rw-r--r-- 1 syslog syslog   561 Aug 19 16:42 kernel.log
-rw-r--r-- 1 syslog syslog   773 Aug 18 16:23 rsyslogd.log
-rw-r--r-- 1 syslog syslog   142 Aug 19 16:45 snapd.log
-rw-r--r-- 1 syslog syslog   615 Aug 17 19:53 sshd.log
-rw-r--r-- 1 syslog syslog   329 Aug 17 19:53 sudo.log
-rw-r--r-- 1 syslog syslog 11486 Aug 19 20:20 systemd.log
-rw-r--r-- 1 syslog syslog   277 Aug 17 19:53 systemd-logind.log
-rw-r--r-- 1 syslog syslog   198 Aug 18 16:31 systemd-resolved.log
root@log:~# ll /var/log/rsyslog/web/
total 20
drwx------ 2 syslog syslog 4096 Aug 19 20:09 ./
drwx------ 5 syslog syslog 4096 Aug 17 19:50 ../
-rw-r--r-- 1 syslog syslog 7176 Aug 19 20:17 audit_log.log
-rw-r--r-- 1 syslog syslog  670 Aug 19 20:01 nginx_access.log
```
в каталоге rsyslog видим три папки по имени хоста, с которого пришли логи
в папке web логи с nginx
```
root@log:~# cat /var/log/rsyslog/web/nginx_access.log
2024-08-17T19:02:58+00:00 web nginx_access: 192.168.56.15 - - [17/Aug/2024:19:02:58 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
2024-08-17T19:02:59+00:00 web nginx_access: 192.168.56.15 - - [17/Aug/2024:19:02:59 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
2024-08-17T19:36:41+00:00 web nginx_access: 192.168.56.20 - - [17/Aug/2024:19:36:41 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
2024-08-17T19:36:50+00:00 web nginx_access: 192.168.56.20 - - [17/Aug/2024:19:36:50 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
2024-08-19T20:00:41+00:00 web nginx_access: 192.168.56.15 - - [19/Aug/2024:20:00:41 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.81.0"
```
и аудит
```
2024-08-19T20:10:11+00:00 web audit_log: type=SYSCALL msg=audit(1724098206.781:392): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=55be952939d0 a2=241 a3=1b6 items=2 ppid=3212 pid=6142 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts1 ses=6 comm="nano" exe="/usr/bin/nano" subj=unconfined key=(null)#035ARCH=x86_64 SYSCALL=openat AUID="vagrant" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
2024-08-19T20:10:11+00:00 web audit_log: type=CWD msg=audit(1724098206.781:392): cwd="/root"
2024-08-19T20:10:11+00:00 web audit_log: type=PATH msg=audit(1724098206.781:392): item=0 name="/etc/nginx/" inode=2360983 dev=fd:00 mode=040755 ouid=0 ogid=0 rdev=00:00 nametype=PARENT cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0#035OUID="root" OGID="root"
2024-08-19T20:10:11+00:00 web audit_log: type=PATH msg=audit(1724098206.781:392): item=1 name="/etc/nginx/nginx.conf" inode=2360992 dev=fd:00 mode=0100644 ouid=0 ogid=0 rdev=00:00 nametype=NORMAL cap_fp=0 cap_fi=0 cap_fe=0 cap_fver=0 cap_frootid=0#035OUID="root" OGID="root"
2024-08-19T20:10:11+00:00 web audit_log: type=PROCTITLE msg=audit(1724098206.781:392): proctitle=6E616E6F002F6574632F6E67696E782F6E67696E782E636F6E66
```


