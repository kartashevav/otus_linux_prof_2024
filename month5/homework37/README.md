### 1. Настройка VLAN на хостах
В моем стенде используются 2 машины на Centos 8 и 5 машин на Ubuntu 22
VLAN настраиваем на ubuntu, после запуска playbook проверяем статус интерфейсов и ip саязность
vlan 2 между testClient1 и testServer1
vlan 3 между testClient2 и testServer2
```
root@testClient1:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
... 

4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:eb:28:80 brd ff:ff:ff:ff:ff:ff
    altname enp0s19
    inet 192.168.50.21/24 brd 192.168.50.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feeb:2880/64 scope link
       valid_lft forever preferred_lft forever
5: vlan2@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:cb:70:d8 brd ff:ff:ff:ff:ff:ff
    inet 10.10.20.254/24 brd 10.10.20.255 scope global vlan2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fecb:70d8/64 scope link
       valid_lft forever preferred_lft forever
```

```
root@testServer1:~# ip ad
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:8c:69:41 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 metric 100 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 85836sec preferred_lft 85836sec
    inet6 fe80::a00:27ff:fe8c:6941/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:c0:c3:76 brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet6 fe80::a00:27ff:fec0:c376/64 scope link
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:fb:4d:cb brd ff:ff:ff:ff:ff:ff
    altname enp0s19
    inet 192.168.50.22/24 brd 192.168.50.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fefb:4dcb/64 scope link
       valid_lft forever preferred_lft forever
5: vlan2@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:c0:c3:76 brd ff:ff:ff:ff:ff:ff
    inet 10.10.20.1/24 brd 10.10.20.255 scope global vlan2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fec0:c376/64 scope link
       valid_lft forever preferred_lft forever
```

```
root@testClient1:~# arp -a
? (10.10.20.1) at 08:00:27:c0:c3:76 [ether] on vlan2

root@testClient1:~# ping 10.10.20.1
PING 10.10.20.1 (10.10.20.1) 56(84) bytes of data.
64 bytes from 10.10.20.1: icmp_seq=1 ttl=64 time=0.358 ms
64 bytes from 10.10.20.1: icmp_seq=2 ttl=64 time=0.357 ms
^C
--- 10.10.20.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1003ms
rtt min/avg/max/mdev = 0.357/0.357/0.358/0.000 ms
```
Связность по vlan2 работает.

Проверяем связность во vlan3
```
root@testClient2:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever

...

3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:7a:24:de brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet6 fe80::a00:27ff:fe7a:24de/64 scope link
       valid_lft forever preferred_lft forever
5: vlan3@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:7a:24:de brd ff:ff:ff:ff:ff:ff
    inet 10.10.20.254/24 brd 10.10.20.255 scope global vlan3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe7a:24de/64 scope link
       valid_lft forever preferred_lft forever
root@testClient2:~#
```

```
root@testServer2:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
...

3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:09:51:92 brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet6 fe80::a00:27ff:fe09:5192/64 scope link
       valid_lft forever preferred_lft forever
5: vlan3@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:09:51:92 brd ff:ff:ff:ff:ff:ff
    inet 10.10.20.1/24 brd 10.10.20.255 scope global vlan3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe09:5192/64 scope link
       valid_lft forever preferred_lft forever
```

```
root@testClient2:~# ping 10.10.20.1
PING 10.10.20.1 (10.10.20.1) 56(84) bytes of data.
64 bytes from 10.10.20.1: icmp_seq=1 ttl=64 time=0.600 ms
64 bytes from 10.10.20.1: icmp_seq=2 ttl=64 time=0.394 ms
^C
--- 10.10.20.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.394/0.497/0.600/0.103 ms
root@testClient2:~# arp -a
? (10.10.20.1) at 08:00:27:09:51:92 [ether] on vlan3
```
Связность по vlan3 работает.

### 2. Настройка LACP между хостами inetRouter и centralRouter
После запуска playbook проверяем интерфейсы и работу bond
```
[root@inetRouter ~]# ip a
...
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc fq_codel master bond0 state UP group default qlen 1000
    link/ether 08:00:27:35:e0:0c brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc fq_codel master bond0 state UP group default qlen 1000
    link/ether 08:00:27:67:c6:47 brd ff:ff:ff:ff:ff:ff
...

6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:35:e0:0c brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global noprefixroute bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe35:e00c/64 scope link
       valid_lft forever preferred_lft forever

[root@inetRouter ~]# ping 192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=0.634 ms
64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=0.382 ms
^C
--- 192.168.255.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 11ms
rtt min/avg/max/mdev = 0.382/0.508/0.634/0.126 ms
```
Выключаем один из интерфейсов и проверяем, что связность работает.
```
[root@inetRouter ~]# ip link set down eth1
[root@inetRouter ~]# ip a

...

3: eth1: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc fq_codel master bond0 state DOWN group default qlen 1000
    link/ether 08:00:27:35:e0:0c brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc fq_codel master bond0 state UP group default qlen 1000
    link/ether 08:00:27:67:c6:47 brd ff:ff:ff:ff:ff:ff

[root@inetRouter ~]# ping 192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=0.512 ms
64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=0.444 ms
^C
--- 192.168.255.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 17ms
rtt min/avg/max/mdev = 0.444/0.478/0.512/0.034 ms
```
Настройка завершена.
