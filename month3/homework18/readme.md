## 1.Запуск nginx на нестандартном порту 3-мя разными способами
проверим, что в ОС отключен файервол:
```
[root@selinux ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)
```
	 
проверим, что конфигурация nginx настроена без ошибок:
```
[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
проверим режим работы SELinux:
```
[root@selinux ~]# getenforce
Enforcing
```
#### 1. Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool

Находим в логах информацию о блокировании порта
```
[root@selinux ~]# cat /var/log/audit/audit.log | grep nginx
type=SOFTWARE_UPDATE msg=audit(1721415873.677:839): pid=2856 uid=0 auid=1000 ses=2 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='sw="nginx-filesystem-1:1.20.1-10.el7.noarch" sw_type=rpm key_enforce=0 gpg_res=1 root_dir="/" comm="yum" exe="/usr/bin/python2.7" hostname=? addr=? terminal=? res=success'
type=SOFTWARE_UPDATE msg=audit(1721415873.862:840): pid=2856 uid=0 auid=1000 ses=2 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='sw="nginx-1:1.20.1-10.el7.x86_64" sw_type=rpm key_enforce=0 gpg_res=1 root_dir="/" comm="yum" exe="/usr/bin/python2.7" hostname=? addr=? terminal=? res=success'
type=AVC msg=audit(1721415874.099:841): avc:  denied  { name_bind } for  pid=3028 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1721415874.099:841): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=55e831b768b8 a2=10 a3=7ffc8d6a6420 items=0 ppid=1 pid=3028 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
type=SERVICE_START msg=audit(1721415874.102:842): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
```

Копируем время, в которое был записан этот лог, и, с помощью утилиты audit2why смотрим
```
[root@selinux ~]# grep 1721415874.099:841 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1721415874.099:841): avc:  denied  { name_bind } for  pid=3028 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

 Was caused by:
The boolean nis_enabled was set incorrectly.
Description:
Allow nis to enabled

Allow access by executing:
 setsebool -P nis_enabled 1
```
		
Включим параметр nis_enabled и перезапустим nginx:
```
[root@selinux ~]# setsebool -P nis_enabled on
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-07-19 19:17:37 UTC; 4s ago
  Process: 3114 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3110 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3109 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3116 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3116 nginx: master process /usr/sbin/nginx
           └─3117 nginx: worker process

Jul 19 19:17:37 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jul 19 19:17:37 selinux nginx[3110]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jul 19 19:17:37 selinux nginx[3110]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jul 19 19:17:37 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
**nginx запустился**

Вернём запрет работы nginx на порту 4881 обратно.
После отключения nis_enabled служба nginx снова не запустится.
```
[root@selinux ~]# setsebool -P nis_enabled off
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Fri 2024-07-19 19:20:44 UTC; 5s ago
  Process: 3114 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3139 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 3138 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3116 (code=exited, status=0/SUCCESS)

Jul 19 19:20:44 selinux systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Jul 19 19:20:44 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jul 19 19:20:44 selinux nginx[3139]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jul 19 19:20:44 selinux nginx[3139]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
Jul 19 19:20:44 selinux nginx[3139]: nginx: configuration file /etc/nginx/nginx.conf test failed
Jul 19 19:20:44 selinux systemd[1]: nginx.service: control process exited, code=exited status=1
Jul 19 19:20:44 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Jul 19 19:20:44 selinux systemd[1]: Unit nginx.service entered failed state.
Jul 19 19:20:44 selinux systemd[1]: nginx.service failed.
[root@selinux ~]#
```
#### 2. Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:
Поиск имеющегося типа, для http трафика:
```
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
[root@selinux ~]#
```
Добавим порт в тип http_port_t:
```
[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
[root@selinux ~]#
```
Теперь перезапустим службу nginx и проверим её работу:
```
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-07-19 19:24:05 UTC; 5s ago
  Process: 3163 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3161 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3160 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3165 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3165 nginx: master process /usr/sbin/nginx
           └─3167 nginx: worker process

Jul 19 19:24:05 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jul 19 19:24:05 selinux nginx[3161]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jul 19 19:24:05 selinux nginx[3161]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jul 19 19:24:05 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
**nginx запустился**

Удалим нестандартный порт из имеющегося типа:
```
[root@selinux ~]# semanage port -d -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
```
Проверим, что nginx снова не запустится:
```
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Fri 2024-07-19 19:25:28 UTC; 2s ago
  Process: 3163 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3187 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 3185 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3165 (code=exited, status=0/SUCCESS)

Jul 19 19:25:28 selinux systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Jul 19 19:25:28 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jul 19 19:25:28 selinux nginx[3187]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jul 19 19:25:28 selinux nginx[3187]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
Jul 19 19:25:28 selinux nginx[3187]: nginx: configuration file /etc/nginx/nginx.conf test failed
Jul 19 19:25:28 selinux systemd[1]: nginx.service: control process exited, code=exited status=1
Jul 19 19:25:28 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Jul 19 19:25:28 selinux systemd[1]: Unit nginx.service entered failed state.
Jul 19 19:25:28 selinux systemd[1]: nginx.service failed.
```
#### 3. Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:
Для этого воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту:
```
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp
```
Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль:
```
[root@selinux ~]# semodule -i nginx.pp
```
Попробуем запустить nginx, видим, что сервер работает.
```
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-07-19 19:28:43 UTC; 2s ago
  Process: 3215 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3213 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3212 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3217 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3217 nginx: master process /usr/sbin/nginx
           └─3218 nginx: worker process

Jul 19 19:28:43 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jul 19 19:28:43 selinux nginx[3213]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jul 19 19:28:43 selinux nginx[3213]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jul 19 19:28:43 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
**nginx запустился**
