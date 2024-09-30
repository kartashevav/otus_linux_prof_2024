### Настройка виртульных машин и osfp с "дорогим" интерфейсом и симметричным роутингом
Настройку машин производим при помощи vagrantfile, на всех машинах создаем по 4 интерфейса. 
Переменную symmetric_routing устанавливаем в значение true.
Сразу предполагаем, что линк между router1 и router2 будет "дорогим",то есть резервным с точки зрения доступности сети 192.168.10.0/24 с router2 и 192.168.20.0/24 c router1.
И так как symmetric_routing=true, то ospf cost на линке r1-r2 будет 1000 с обеих сторон.
Проверяем
```
router1# sh ip route 192.168.20.1
Routing entry for 192.168.20.0/24
  Known via "ospf", distance 110, metric 135, best
  Last update 00:16:09 ago
  * 10.100.12.2, via eth2, weight 1

router1# traceroute 192.168.20.1
traceroute to 192.168.20.1 (192.168.20.1), 30 hops max, 60 byte packets
 1  10.100.12.2 (10.100.12.2)  0.487 ms  0.423 ms  0.411 ms
 2  192.168.20.1 (192.168.20.1)  0.703 ms  0.694 ms  0.686 ms
 
router2# sh ip route 192.168.10.1
Routing entry for 192.168.10.0/24
  Known via "ospf", distance 110, metric 135, best
  Last update 00:17:16 ago
  * 10.100.11.1, via eth2, weight 1

router2# traceroute 192.168.10.1
traceroute to 192.168.10.1 (192.168.10.1), 30 hops max, 60 byte packets
 1  10.100.11.1 (10.100.11.1)  0.525 ms  0.473 ms  0.464 ms
 2  192.168.10.1 (192.168.10.1)  0.938 ms  0.929 ms  0.922 ms
```
### Настройка ассиметричного роутинга
Меняем значение symmetric_routing=false.
Запускаем playbook, проверям те же маршруты на router1 и на router2.
```
router1# sh ip route 192.168.20.1
Routing entry for 192.168.20.0/24
  Known via "ospf", distance 110, metric 135, best
  Last update 00:00:17 ago
  * 10.100.12.2, via eth2, weight 1

router1# traceroute 192.168.20.1
traceroute to 192.168.20.1 (192.168.20.1), 30 hops max, 60 byte packets
 1  10.100.12.2 (10.100.12.2)  0.506 ms  0.470 ms  0.462 ms
 2  192.168.20.1 (192.168.20.1)  0.738 ms  0.729 ms  0.718 ms
 
 router2# sh ip route 192.168.10.1
Routing entry for 192.168.10.0/24
  Known via "ospf", distance 110, metric 90, best
  Last update 00:00:54 ago
  * 10.100.10.1, via eth1, weight 1

router2# traceroute 192.168.10.1
traceroute to 192.168.10.1 (192.168.10.1), 30 hops max, 60 byte packets
 1  192.168.10.1 (192.168.10.1)  0.787 ms  0.726 ms  0.716 ms

```
Видим, что так как на router1 ничего не изменилось, а на router2 метрика интерфейса eth1 уменьшилась до 45, маршрут до сети 192.168.10.0/24 стал доступн через eht1
