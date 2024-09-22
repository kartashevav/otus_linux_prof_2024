### Реализовать knocking port
Конфигурация knocking port находится в файле iptables_rules.ipv4, чтобы не ломать оступ по ssh на inetRoute с других хостов, ограничил knocking port только для ip 192.168.255.2.
После настройки всех серверов, пробую подключится по ssh с centralRouter.
Первая попытка неудачна, после подключений на knocking ports, подключение на стандартный порт успешно.
```
root@centralRouter:~# ssh vagrant@192.168.255.1
^C
root@centralRouter:~# ssh -p 11111 vagrant@192.168.255.1
^C
root@centralRouter:~# ssh -p 22222 vagrant@192.168.255.1
^C
root@centralRouter:~# ssh -p 33333 vagrant@192.168.255.1
^C
root@centralRouter:~# ssh -p 44444 vagrant@192.168.255.1
^C
root@centralRouter:~# ssh vagrant@192.168.255.1
vagrant@192.168.255.1's password:
Last login: Sun Sep 22 15:46:57 2024 from 10.0.2.2
vagrant@inetRouter:~$
```
### Проброс порта на centralServer
Для пробоса порта необходимо выключить интерфейсы eth0, на которых работает сеть управления ansible, на хостах centralRouter и centralServer. Это нужно для того, чтобы была верная маршрутизация до сети 10.0.2.0/24(сеть ansible) через inetRouter2, иначе при dst-nat приходящие пакеты приходили через inetRouter2, а исходящие в сеть 10.0.2.0/24 уходили с локального интерфейса eth0, так как сеть connected.
Для этого в playbook созданы отдельные задачи disable eth0 on centralRouter и disable eth0 on centralServer.
Port forward настраивается файлом конфигурации iptables_rules_inetRouter2.ipv4.
Получается следующая цепочка проброса портов: 127.0.0.1:8888 -> inetRouter2:8080 -> 192.168.0.2:80
После всех настроек проверяем доступность дефолтной страницы nginx с хостовой машины
```
(c) Корпорация Майкрософт (Microsoft Corporation). Все права защищены.

C:\Users\papasasha>curl 127.0.0.1:8888
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

```
