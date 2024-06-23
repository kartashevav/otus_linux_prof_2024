1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова

создаём файл с конфигурацией
root@nginx:~# cat /etc/default/watchlog
WORD="ALERT"
LOG=/var/log/watchlog.log

создаем лог для анализа путем копирования 
root@nginx:~# cp /var/log/syslog /var/log/watchlog.log
добавляем кллючевое слово
root@nginx:~# cat /var/log/watchlog.log | grep ALERT
Jun 16 18:51:14 ubuntu2204 systemd[1]: ALERT Failed to start OpenBSD Secure Shell server.

Создадим скрипт:
root@nginx:~# cat /opt/watchlog.sh
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi

root@nginx:~# chmod +x /opt/watchlog.sh

Создадим юнит для сервиса:
root@nginx:~# cat /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/default/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG

Создадим юнит для таймера:
root@nginx:~# cat /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target

root@nginx:~# tail -f /var/log/syslog
Jun 23 17:13:23 nginx systemd[2871]: Reached target Sockets.
Jun 23 17:13:23 nginx systemd[2871]: Reached target Basic System.
Jun 23 17:13:23 nginx systemd[1]: Started User Manager for UID 1000.
Jun 23 17:13:23 nginx systemd[1]: Started Session 20 of User vagrant.
Jun 23 17:13:23 nginx systemd[2871]: Reached target Main User Target.
Jun 23 17:13:23 nginx systemd[2871]: Startup finished in 100ms.
Jun 23 17:14:02 nginx systemd[1]: Starting My watchlog service...
Jun 23 17:14:02 nginx root: Sun Jun 23 05:14:02 PM UTC 2024: I found word, Master!
Jun 23 17:14:02 nginx systemd[1]: watchlog.service: Deactivated successfully.
Jun 23 17:14:02 nginx systemd[1]: Finished My watchlog service.
Jun 23 17:14:59 nginx systemd[1]: Starting My watchlog service...
Jun 23 17:14:59 nginx root: Sun Jun 23 05:14:59 PM UTC 2024: I found word, Master!
Jun 23 17:14:59 nginx systemd[1]: watchlog.service: Deactivated successfully.
Jun 23 17:14:59 nginx systemd[1]: Finished My watchlog service.

2.Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта

root@nginx:~# apt update
root@nginx:~# apt install spawn-fcgi php php-cgi php-cli \
>  apache2 libapache2-mod-fcgid -y

Необходимо создать файл с настройками для будущего сервиса
root@nginx:~# mkdir /etc/spawn-fcgi
root@nginx:~# vi /etc/spawn-fcgi/fcgi.conf
root@nginx:~# cat /etc/spawn-fcgi/fcgi.conf
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u www-data -g www-data -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"

Создаем юнит файл
root@nginx:~# vi /etc/systemd/system/spawn-fcgi.service
root@nginx:~# cat /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target

Запускаем
root@nginx:~# systemctl start spawn-fcgi
root@nginx:~# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: enabled)
     Active: active (running) since Sun 2024-06-23 17:46:29 UTC; 7s ago
   Main PID: 12495 (php-cgi)
      Tasks: 33 (limit: 710)
     Memory: 18.7M
        CPU: 21ms
     CGroup: /system.slice/spawn-fcgi.service
             ├─12495 /usr/bin/php-cgi
             ├─12496 /usr/bin/php-cgi
             ├─12497 /usr/bin/php-cgi
             ├─12498 /usr/bin/php-cgi
             ├─12499 /usr/bin/php-cgi
             ├─12500 /usr/bin/php-cgi
             ├─12501 /usr/bin/php-cgi
             ├─12502 /usr/bin/php-cgi
             ├─12503 /usr/bin/php-cgi
             ├─12504 /usr/bin/php-cgi
             ├─12505 /usr/bin/php-cgi
             ├─12506 /usr/bin/php-cgi
             ├─12507 /usr/bin/php-cgi
             ├─12508 /usr/bin/php-cgi
             ├─12509 /usr/bin/php-cgi
             ├─12510 /usr/bin/php-cgi
             ├─12511 /usr/bin/php-cgi
             ├─12512 /usr/bin/php-cgi
             ├─12513 /usr/bin/php-cgi
             ├─12514 /usr/bin/php-cgi
             ├─12515 /usr/bin/php-cgi
			 
3. Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно
Для запуска нескольких экземпляров сервиса модифицируем исходный service для использования различной конфигурации, а также PID-файлов.
root@nginx:~# vi /etc/systemd/system/nginx@.service
root@nginx:~# cat /etc/systemd/system/nginx@.service
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx-%I.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target

Создаем конфиги для экземпляров nginx

root@nginx:~# vi /etc/nginx/nginx-first.conf
root@nginx:~# cat /etc/nginx/nginx-first.conf
pid /run/nginx-first.pid;
events {
}
http {
        server {
                listen 9001;
        }
}
root@nginx:~# cp /etc/nginx/nginx-first.conf /etc/nginx/nginx-second.conf
root@nginx:~# vi /etc/nginx/nginx-second.conf
root@nginx:~# cat /etc/nginx/nginx-second.conf
pid /run/nginx-second.pid;
events {
}
http {
        server {
                listen 9002;
        }
}
root@nginx:~# systemctl start nginx@first
root@nginx:~# systemctl start nginx@second

root@nginx:~# ss -tnulp | grep nginx
tcp   LISTEN 0      511           0.0.0.0:9001      0.0.0.0:*    users:(("nginx",pid=13353,fd=6),("nginx",pid=13352,fd=6))                                                                                                                                    
tcp   LISTEN 0      511           0.0.0.0:9002      0.0.0.0:*    users:(("nginx",pid=13375,fd=6),("nginx",pid=13374,fd=6))                                                                                                                                    