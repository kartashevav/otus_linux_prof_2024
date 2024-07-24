### 2.Обеспечение работоспособности приложения при включенном SELinux

По заданию поднимаем две машины ns01 и client, так как это старый centos 7, стандартные репозитории не работают, меняим url репозитория в провижинге vagrantfile.

Так как у меня хостовая машина на Windows, для ansible буду использовать отдельную машину на Ubuntu, которая осталась от старых домашек.

Копируем файлы из репозитория на локальную машину, в папку которая подключается к ansible server как shared.
Копируем файл playbook.yml и папку files. Создаем файл hosts, который будем использовать как inventory.
```
d:\VM_vagrant\ansible_server>dir
 Том в устройстве D имеет метку DATA
 Серийный номер тома: 881C-D0EE

 Содержимое папки d:\VM_vagrant\ansible_server

24.07.2024  22:07    <DIR>          .
24.07.2024  22:07    <DIR>          ..
19.07.2024  22:50    <DIR>          .vagrant
23.07.2024  21:20    <DIR>          files
24.07.2024  21:34               106 hosts
21.11.2022  15:22             2 939 playbook.yml
24.07.2024  21:26               826 Vagrantfile

d:\VM_vagrant\ansible_server>type hosts
[dns]
ns01 ansible_host=192.168.50.10 ansible_port=22
client ansible_host=192.168.50.15 ansible_port=22
```
Устанавливаем пакет sshpass для ansible, чтоб можно было подключится с паролем, н использую ssh-key.
```
root@ansible-server:~# apt-get install sshpass
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  sshpass
0 upgraded, 1 newly installed, 0 to remove and 146 not upgraded.
Need to get 11.7 kB of archives.
After this operation, 35.8 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble/universe amd64 sshpass amd64 1.09-1 [11.7 kB]
Fetched 11.7 kB in 0s (80.3 kB/s)
Selecting previously unselected package sshpass.
(Reading database ... 130002 files and directories currently installed.)
Preparing to unpack .../sshpass_1.09-1_amd64.deb ...
Unpacking sshpass (1.09-1) ...
Setting up sshpass (1.09-1) ...
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
```
Запускаем playbook.
```
root@ansible-server:~# ansible-playbook -i /vagrant/hosts -u vagrant -k /vagrant/playbook.yml
SSH password:

PLAY [all] *************************************************************************************************************
TASK [Gathering Facts] *************************************************************************************************
ok: [ns01]
ok: [client]

TASK [install packages] ************************************************************************************************
changed: [client]
changed: [ns01]

PLAY [ns01] ************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [ns01]

TASK [copy named.conf] *************************************************************************************************
changed: [ns01]

TASK [copy master zone dns.lab] ****************************************************************************************
changed: [ns01] => (item=/vagrant/files/ns01/named.dns.lab)
changed: [ns01] => (item=/vagrant/files/ns01/named.dns.lab.view1)

TASK [copy dynamic zone ddns.lab] **************************************************************************************
changed: [ns01]

TASK [copy dynamic zone ddns.lab.view1] ********************************************************************************
changed: [ns01]

TASK [copy master zone newdns.lab] *************************************************************************************
changed: [ns01]

TASK [copy rev zones] **************************************************************************************************
changed: [ns01]

TASK [copy resolv.conf to server] **************************************************************************************
changed: [ns01]

TASK [copy transferkey to server] **************************************************************************************
changed: [ns01]

TASK [set /etc/named permissions] **************************************************************************************
changed: [ns01]

TASK [set /etc/named/dynamic permissions] ******************************************************************************
changed: [ns01]

TASK [ensure named is running and enabled] *****************************************************************************
changed: [ns01]

PLAY [client] **********************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [client]

TASK [copy resolv.conf to the client] **********************************************************************************
changed: [client]

TASK [copy rndc conf file] *********************************************************************************************
changed: [client]

TASK [copy motd to the client] *****************************************************************************************
changed: [client]

TASK [copy transferkey to client] **************************************************************************************
changed: [client]

PLAY RECAP *************************************************************************************************************
client                     : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ns01                       : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
Дальше по методичке
Подключимся к клиенту:
```
d:\VM_vagrant\SElinux\task2>vagrant ssh client
Last failed login: Wed Jul 24 19:14:11 UTC 2024 from 192.168.50.20 on ssh:notty
There were 6 failed login attempts since the last successful login.
###############################
### Welcome to the DNS lab! ###
###############################

- Use this client to test the enviroment
- with dig or nslookup. Ex:
    dig @192.168.50.10 ns01.dns.lab

- nsupdate is available in the ddns.lab zone. Ex:
    nsupdate -k /etc/named.zonetransfer.key
    server 192.168.50.10
    zone ddns.lab
    update add www.ddns.lab. 60 A 192.168.50.15
    send

- rndc is also available to manage the servers
    rndc -c ~/rndc.conf reload

###############################
### Enjoy! ####################
###############################
```
Попробуем внести изменения в зону:
```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
> quit
[vagrant@client ~]$
```
Изменения внести не получилось. Давайте посмотрим логи SELinux, чтобы понять в чём может быть проблема.

Посмотрим на ns01, что пишет audit2why
```
[vagrant@ns01 ~]$ sudo -i
[root@ns01 ~]# cat /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1721848907.168:1732): avc:  denied  { create } for  pid=4532 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.
```	
В логах мы видим, что ошибка в контексте безопасности. Вместо типа named_t используется тип etc_t.
Проверим данную проблему в каталоге /etc/named:
```
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:etc_t:s0       .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
-rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
-rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab
[root@ns01 ~]#
```
Тут мы также видим, что контекст безопасности неправильный. Проблема заключается в том, что конфигурационные файлы лежат в другом каталоге. Посмотреть в каком каталоги должны лежать, файлы, чтобы на них распространялись правильные политики SELinux можно с помощью команды: semanage fcontext -l | grep named
```
[root@ns01 ~]# semanage fcontext -l | grep named
/etc/rndc.*                                        regular file       system_u:object_r:named_conf_t:s0
```
Изменим тип контекста безопасности для каталога /etc/named: chcon -R -t named_zone_t /etc/named
```
[root@ns01 ~]# chcon -R -t named_zone_t /etc/named
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:named_zone_t:s0 .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
```
Попробуем снова внести изменения с клиента: 
```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
> quit
[vagrant@client ~]$ dig www.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.16 <<>> www.ddns.lab
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19932
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.                  IN      A

;; ANSWER SECTION:
www.ddns.lab.           60      IN      A       192.168.50.15

;; AUTHORITY SECTION:
ddns.lab.               3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10

;; Query time: 1 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Wed Jul 24 19:32:21 UTC 2024
;; MSG SIZE  rcvd: 96

[vagrant@client ~]$
```
Видим, что изменения применились.

