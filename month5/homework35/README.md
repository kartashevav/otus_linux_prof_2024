### 1. TUN/TAP режимы VPN
Настройку машин производим при помощи vagrantfile и ansible.
После настройки проверяем скорость черех vpn в режиме TAP.
```
tap0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.10.10.2  netmask 255.255.255.0  broadcast 0.0.0.0
        inet6 fe80::14ae:3cff:fe72:4800  prefixlen 64  scopeid 0x20<link>
        ether da:68:38:10:da:a5  txqueuelen 1000  (Ethernet)
        RX packets 7  bytes 566 (566.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 8  bytes 656 (656.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
		
root@client:~# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  5] local 10.10.10.2 port 41988 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec  94.0 MBytes   158 Mbits/sec   60   1.22 MBytes
[  5]   5.00-10.00  sec  92.5 MBytes   155 Mbits/sec    3   1.05 MBytes
[  5]  10.00-15.00  sec  91.2 MBytes   153 Mbits/sec    0   1.07 MBytes
[  5]  15.00-20.00  sec  91.2 MBytes   153 Mbits/sec    0   1.24 MBytes
[  5]  20.00-25.00  sec  92.5 MBytes   155 Mbits/sec    4   1.21 MBytes
[  5]  25.00-30.00  sec  92.5 MBytes   155 Mbits/sec    1   1.02 MBytes
[  5]  30.00-35.00  sec  92.5 MBytes   155 Mbits/sec    0   1.06 MBytes
[  5]  35.00-40.00  sec  92.5 MBytes   155 Mbits/sec    0   1.16 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec   739 MBytes   155 Mbits/sec   68             sender
[  5]   0.00-40.22  sec   737 MBytes   154 Mbits/sec                  receiver

iperf Done.
```
Получаем среднюю скорость 155 Мбит/с.

Меняем режим vpn на TUN и тестируем скорость.
```
tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1500
        inet 10.10.10.2  netmask 255.255.255.0  destination 10.10.10.2
        inet6 fe80::36b9:265:9760:b686  prefixlen 64  scopeid 0x20<link>
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 500  (UNSPEC)
        RX packets 2  bytes 96 (96.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3  bytes 144 (144.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
		
root@client:~# iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  5] local 10.10.10.2 port 48164 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec  99.1 MBytes   166 Mbits/sec   37    522 KBytes
[  5]   5.00-10.00  sec  96.9 MBytes   163 Mbits/sec    0    626 KBytes
[  5]  10.00-15.00  sec  98.4 MBytes   165 Mbits/sec    1    632 KBytes
[  5]  15.00-20.00  sec  97.1 MBytes   163 Mbits/sec    1    555 KBytes
[  5]  20.00-25.00  sec  96.2 MBytes   161 Mbits/sec    1    521 KBytes
[  5]  25.00-30.00  sec  96.1 MBytes   161 Mbits/sec    1    481 KBytes
[  5]  30.00-35.00  sec  96.8 MBytes   162 Mbits/sec    0    599 KBytes
[  5]  35.00-40.00  sec  97.2 MBytes   163 Mbits/sec    4    605 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec   778 MBytes   163 Mbits/sec   45             sender
[  5]   0.00-40.07  sec   776 MBytes   163 Mbits/sec                  receiver

iperf Done.
```
Видимм, что в режиме tun скорость выше, могу предположить, что это связано с тем, что интерфейс tap - это ethernet bridge и для передачи пакета он целиком инкапсулируется в туннель, вместе с ethernet заголовком, что увеличивает нагрузку и снижает скорость.

Тогда как в режиме tun в туннель инкапсулируются только данные без ethernet заголовка.

### 2. RAS на базе OpenVPN
Настройку машин производим при помощи vagrantfile и ansible.
После настройки проверяем, что клиент подклчен
```
root@server:~# cat /var/log/openvpn.log | grep client
2024-10-06 15:21:48 192.168.56.20:1194 VERIFY OK: depth=0, CN=client
2024-10-06 15:21:48 192.168.56.20:1194 [client] Peer Connection Initiated with [AF_INET]192.168.56.20:1194
2024-10-06 15:21:48 client/192.168.56.20:1194 MULTI_sva: pool returned IPv4=10.10.10.6, IPv6=(Not enabled)
2024-10-06 15:21:48 client/192.168.56.20:1194 MULTI: Learn: 10.10.10.6 -> client/192.168.56.20:1194
2024-10-06 15:21:48 client/192.168.56.20:1194 MULTI: primary virtual IP for client/192.168.56.20:1194: 10.10.10.6
2024-10-06 15:21:48 client/192.168.56.20:1194 Data Channel: using negotiated cipher 'AES-256-GCM'
2024-10-06 15:21:48 client/192.168.56.20:1194 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
2024-10-06 15:21:48 client/192.168.56.20:1194 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
2024-10-06 15:21:48 client/192.168.56.20:1194 SENT CONTROL [client]: 'PUSH_REPLY,route 10.10.10.0 255.255.255.0,topology net30,ping 10,ping-restart 120,ifconfig 10.10.10.6 10.10.10.5,peer-id 0,cipher AES-256-GCM' (status=1)


root@server:~# cat /var/log/openvpn-status.log
OpenVPN CLIENT LIST
Updated,2024-10-06 15:23:50
Common Name,Real Address,Bytes Received,Bytes Sent,Connected Since
client,192.168.56.20:1194,4072,4074,2024-10-06 15:21:48
ROUTING TABLE
Virtual Address,Common Name,Real Address,Last Ref
10.10.10.6,client,192.168.56.20:1194,2024-10-06 15:22:22
GLOBAL STATS
Max bcast/mcast queue length,1
END

```
Видим, что клиент успешно подклчился.
Проверяем связность.
```
root@client:~# ip r
default via 10.0.2.2 dev enp0s3 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100
10.0.2.3 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100
10.10.10.0/24 via 10.10.10.5 dev tun0
10.10.10.5 dev tun0 proto kernel scope link src 10.10.10.6
192.168.50.0/24 dev enp0s9 proto kernel scope link src 192.168.50.20
192.168.56.0/24 dev enp0s8 proto kernel scope link src 192.168.56.20
root@client:~# ping 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.639 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.779 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.645 ms
^C
--- 10.10.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2038ms
rtt min/avg/max/mdev = 0.639/0.687/0.779/0.064 ms
```
RAS успешно настроен.
