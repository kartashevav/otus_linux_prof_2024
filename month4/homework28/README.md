### 1. Теоретическая часть
В задании даны следующие сети:
Сеть office1
- 192.168.2.0/26      - dev
- 192.168.2.64/26     - test servers
- 192.168.2.128/26    - managers
- 192.168.2.192/26    - office hardware

Сеть office2
- 192.168.1.0/25      - dev
- 192.168.1.128/26    - test servers
- 192.168.1.192/26    - office hardware

Сеть central
- 192.168.0.0/28     - directors
- 192.168.0.32/28    - office hardware
- 192.168.0.64/26    - wifi

После выяислений, получается такая таблица, в которой указаны все исподьзуемые и свободные сети.
|     Name                           | Network                  | Netmask         | N   | Hostmin         | Hostmax         | Broadcast        |
|------------------------------------|--------------------------|-----------------|-----|-----------------|-----------------|------------------|
| Central Network                    |                          |                 |     |                 |                 |                  |
| Directors                          | 192.168.0.0/28           | 255.255.255.240 | 14  | 192.168.0.1     | 192.168.0.14    | 192.168.0.15     |
| **free**                           | 192.168.0.16/28          | 255.255.255.240 | 14  | 192.168.0.17    | 192.168.0.30    | 192.168.0.31     |
| Office   hardware                  | 192.168.0.32/28          | 255.255.255.240 | 14  | 192.168.0.33    | 192.168.0.46    | 192.168.0.47     |
| **free**                           | 192.168.0.48/28          | 255.255.255.240 | 14  | 192.168.0.49    | 192.168.0.62    | 192.168.0.63     |
| Wifi(mgt   network)                | 192.168.0.64/26          | 255.255.255.192 | 62  | 192.168.0.65    | 192.168.0.126   | 192.168.0.127    |
| **free**                           | 192.168.0.128/25         | 255.255.255.128 | 128 | 192.168.0.129   | 192.168.0.254   | 192.168.0.255    |
| Office 1 network                   |                          |                 |     |                 |                 |                  |
| Dev                                | 192.168.2.0/26           | 255.255.255.192 | 62  | 192.168.2.1     | 192.168.2.62    | 192.168.2.63     |
| Test                               | 192.168.2.64/26          | 255.255.255.192 | 62  | 192.168.2.65    | 192.168.2.126   | 192.168.2.127    |
| Managers                           | 192.168.2.128/26         | 255.255.255.192 | 62  | 192.168.2.129   | 192.168.2.190   | 192.168.2.191    |
| Office   hardware                  | 192.168.2.192/26         | 255.255.255.192 | 62  | 192.168.2.193   | 192.168.2.254   | 192.168.2.255    |
| Office 2 network                   |                          |                 |     |                 |                 |                  |
| Dev                                | 192.168.1.0/25           | 255.255.255.128 | 126 | 192.168.1.1     | 192.168.1.126   | 192.168.1.127    |
| Test                               | 192.168.1.128/26         | 255.255.255.192 | 62  | 192.168.1.129   | 192.168.1.190   | 192.168.1.191    |
| Office                             | 192.168.1.192/26         | 255.255.255.192 | 62  | 192.168.1.193   | 192.168.1.254   | 192.168.1.255    |
| InetRouter — CentralRouter network |                          |                 |     |                 |                 |                  |
| Inet   — central                   | 192.168.255.0/30         | 255.255.255.252 | 2   | 192.168.255.1   | 192.168.255.2   | 192.168.255.3    |
| **free**                           | 192.168.255.4/30         | 255.255.255.252 | 2   | 192.168.255.5   | 192.168.255.6   | 192.168.255.7    |
| **free**                           | 192.168.255.8/29         | 255.255.255.248 | 6   | 192.168.255.9   | 192.168.255.14  | 192.168.255.15   |
| **free**                           | 192.168.255.16/28        | 255.255.255.240 | 14  | 192.168.255.17  | 192.168.255.30  | 192.168.255.31   |
| **free**                           | 192.168.255.32/27        | 255.255.255.224 | 30  | 192.168.255.33  | 192.168.255.62  | 192.168.255.63   |
| **free**                           |        192.168.255.64/26 | 255.255.255.192 | 62  | 192.168.255.65  | 192.168.255.126 | 192.168.255.127  |
| **free**                           | 192.168.255.128/25       | 255.255.255.128 | 126 | 192.168.255.129 | 192.168.255.254 | 192.168.255.255  |

### 2. Практическая часть

После включения всех виртуальных машин настраиваем их через anisble.
playbook запускаем командой  ansible-playbook -vv -i /vagrant/hosts /vagrant/playbook.yml
```
root@ansible-server:~# ansible-playbook -vv -i /vagrant/hosts /vagrant/playbook.yml
ansible-playbook [core 2.16.6]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible-playbook
  python version = 3.12.3 (main, Apr 10 2024, 05:33:47) [GCC 13.2.0] (/usr/bin/python3)
  jinja version = 3.1.3
  libyaml = True
Using /etc/ansible/ansible.cfg as config file
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
Skipping callback 'default', as we already have a stdout callback.
Skipping callback 'minimal', as we already have a stdout callback.
Skipping callback 'oneline', as we already have a stdout callback.

PLAYBOOK: playbook.yml ********************************************************************************************************************************************************************************************
1 plays in /vagrant/playbook.yml

PLAY [all] ********************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
task path: /vagrant/playbook.yml:2
ok: [centralRouter]
ok: [office1Server]
ok: [inetRouter]
ok: [office2Server]
ok: [office2Router]
ok: [centralServer]
ok: [office1Router]

TASK [Set up NAT on inetRouter] ***********************************************************************************************************************************************************************************
task path: /vagrant/playbook.yml:5
skipping: [centralRouter] => (item={'src': 'iptables_rules.ipv4', 'dest': '/etc/iptables_rules.ipv4', 'mode': '0644'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/iptables_rules.ipv4", "mode": "0644", "src": "iptables_rules.ipv4"}, "skip_reason": "Conditional result was False"}
skipping: [centralRouter] => (item={'src': 'iptables_restore', 'dest': '/etc/network/if-pre-up.d/iptables', 'mode': '0755'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/network/if-pre-up.d/iptables", "mode": "0755", "src": "iptables_restore"}, "skip_reason": "Conditional result was False"}
skipping: [centralRouter] => {"changed": false, "msg": "All items skipped"}
skipping: [office1Router] => (item={'src': 'iptables_rules.ipv4', 'dest': '/etc/iptables_rules.ipv4', 'mode': '0644'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/iptables_rules.ipv4", "mode": "0644", "src": "iptables_rules.ipv4"}, "skip_reason": "Conditional result was False"}
skipping: [office1Router] => (item={'src': 'iptables_restore', 'dest': '/etc/network/if-pre-up.d/iptables', 'mode': '0755'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/network/if-pre-up.d/iptables", "mode": "0755", "src": "iptables_restore"}, "skip_reason": "Conditional result was False"}
skipping: [office1Router] => {"changed": false, "msg": "All items skipped"}
skipping: [office2Router] => (item={'src': 'iptables_rules.ipv4', 'dest': '/etc/iptables_rules.ipv4', 'mode': '0644'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/iptables_rules.ipv4", "mode": "0644", "src": "iptables_rules.ipv4"}, "skip_reason": "Conditional result was False"}
skipping: [office2Router] => (item={'src': 'iptables_restore', 'dest': '/etc/network/if-pre-up.d/iptables', 'mode': '0755'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/network/if-pre-up.d/iptables", "mode": "0755", "src": "iptables_restore"}, "skip_reason": "Conditional result was False"}
skipping: [office2Router] => {"changed": false, "msg": "All items skipped"}
skipping: [centralServer] => (item={'src': 'iptables_rules.ipv4', 'dest': '/etc/iptables_rules.ipv4', 'mode': '0644'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/iptables_rules.ipv4", "mode": "0644", "src": "iptables_rules.ipv4"}, "skip_reason": "Conditional result was False"}
skipping: [centralServer] => (item={'src': 'iptables_restore', 'dest': '/etc/network/if-pre-up.d/iptables', 'mode': '0755'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/network/if-pre-up.d/iptables", "mode": "0755", "src": "iptables_restore"}, "skip_reason": "Conditional result was False"}
skipping: [office1Server] => (item={'src': 'iptables_rules.ipv4', 'dest': '/etc/iptables_rules.ipv4', 'mode': '0644'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/iptables_rules.ipv4", "mode": "0644", "src": "iptables_rules.ipv4"}, "skip_reason": "Conditional result was False"}
skipping: [office1Server] => (item={'src': 'iptables_restore', 'dest': '/etc/network/if-pre-up.d/iptables', 'mode': '0755'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/network/if-pre-up.d/iptables", "mode": "0755", "src": "iptables_restore"}, "skip_reason": "Conditional result was False"}
skipping: [centralServer] => {"changed": false, "msg": "All items skipped"}
skipping: [office1Server] => {"changed": false, "msg": "All items skipped"}
skipping: [office2Server] => (item={'src': 'iptables_rules.ipv4', 'dest': '/etc/iptables_rules.ipv4', 'mode': '0644'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/iptables_rules.ipv4", "mode": "0644", "src": "iptables_rules.ipv4"}, "skip_reason": "Conditional result was False"}
skipping: [office2Server] => (item={'src': 'iptables_restore', 'dest': '/etc/network/if-pre-up.d/iptables', 'mode': '0755'})  => {"ansible_loop_var": "item", "changed": false, "false_condition": "(ansible_hostname == \"inetRouter\")", "item": {"dest": "/etc/network/if-pre-up.d/iptables", "mode": "0755", "src": "iptables_restore"}, "skip_reason": "Conditional result was False"}
skipping: [office2Server] => {"changed": false, "msg": "All items skipped"}
changed: [inetRouter] => (item={'src': 'iptables_rules.ipv4', 'dest': '/etc/iptables_rules.ipv4', 'mode': '0644'}) => {"ansible_loop_var": "item", "changed": true, "checksum": "16305f06c896de0b171ad0824c12b4234046a830", "dest": "/etc/iptables_rules.ipv4", "gid": 0, "group": "root", "item": {"dest": "/etc/iptables_rules.ipv4", "mode": "0644", "src": "iptables_rules.ipv4"}, "md5sum": "8a5e572d5987067f5c148e298f451b00", "mode": "0644", "owner": "root", "size": 470, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478079.8896902-4455-122851680569810/source", "state": "file", "uid": 0}
changed: [inetRouter] => (item={'src': 'iptables_restore', 'dest': '/etc/network/if-pre-up.d/iptables', 'mode': '0755'}) => {"ansible_loop_var": "item", "changed": true, "checksum": "57472b57e63425b72d5fa24eddc246c8a3544121", "dest": "/etc/network/if-pre-up.d/iptables", "gid": 0, "group": "root", "item": {"dest": "/etc/network/if-pre-up.d/iptables", "mode": "0755", "src": "iptables_restore"}, "md5sum": "5bcc127af63a69474c1920da6e84eb12", "mode": "0755", "owner": "root", "size": 60, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478080.771033-4455-213114001155646/source", "state": "file", "uid": 0}

TASK [set up forward packages across routers] *********************************************************************************************************************************************************************
task path: /vagrant/playbook.yml:16
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
redirecting (type: modules) ansible.builtin.sysctl to ansible.posix.sysctl
skipping: [centralServer] => {"changed": false, "false_condition": "'routers' in group_names", "skip_reason": "Conditional result was False"}
skipping: [office1Server] => {"changed": false, "false_condition": "'routers' in group_names", "skip_reason": "Conditional result was False"}
skipping: [office2Server] => {"changed": false, "false_condition": "'routers' in group_names", "skip_reason": "Conditional result was False"}
ok: [office2Router] => {"changed": false}
ok: [inetRouter] => {"changed": false}
ok: [office1Router] => {"changed": false}
ok: [centralRouter] => {"changed": false}

TASK [disable default route] **************************************************************************************************************************************************************************************
task path: /vagrant/playbook.yml:22
skipping: [inetRouter] => {"changed": false, "false_condition": "(ansible_hostname != \"inetRouter\")", "skip_reason": "Conditional result was False"}
changed: [centralRouter] => {"changed": true, "checksum": "4731cf67a2def9f27aad9a97173a43154182a750", "dest": "/etc/netplan/00-installer-config.yaml", "gid": 0, "group": "root", "md5sum": "0d5036e15b256c18ba6afbc93e485d63", "mode": "0644", "owner": "root", "size": 133, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478081.8472254-4509-42126707887956/source", "state": "file", "uid": 0}
changed: [office1Router] => {"changed": true, "checksum": "4731cf67a2def9f27aad9a97173a43154182a750", "dest": "/etc/netplan/00-installer-config.yaml", "gid": 0, "group": "root", "md5sum": "0d5036e15b256c18ba6afbc93e485d63", "mode": "0644", "owner": "root", "size": 133, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478081.8943992-4510-200276051336371/source", "state": "file", "uid": 0}
changed: [office2Router] => {"changed": true, "checksum": "4731cf67a2def9f27aad9a97173a43154182a750", "dest": "/etc/netplan/00-installer-config.yaml", "gid": 0, "group": "root", "md5sum": "0d5036e15b256c18ba6afbc93e485d63", "mode": "0644", "owner": "root", "size": 133, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478081.955811-4514-10317935980808/source", "state": "file", "uid": 0}
changed: [centralServer] => {"changed": true, "checksum": "4731cf67a2def9f27aad9a97173a43154182a750", "dest": "/etc/netplan/00-installer-config.yaml", "gid": 0, "group": "root", "md5sum": "0d5036e15b256c18ba6afbc93e485d63", "mode": "0644", "owner": "root", "size": 133, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478082.0361047-4525-242529514239968/source", "state": "file", "uid": 0}
changed: [office1Server] => {"changed": true, "checksum": "4731cf67a2def9f27aad9a97173a43154182a750", "dest": "/etc/netplan/00-installer-config.yaml", "gid": 0, "group": "root", "md5sum": "0d5036e15b256c18ba6afbc93e485d63", "mode": "0644", "owner": "root", "size": 133, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478082.09206-4528-3549180878478/source", "state": "file", "uid": 0}
changed: [office2Server] => {"changed": true, "checksum": "4731cf67a2def9f27aad9a97173a43154182a750", "dest": "/etc/netplan/00-installer-config.yaml", "gid": 0, "group": "root", "md5sum": "0d5036e15b256c18ba6afbc93e485d63", "mode": "0644", "owner": "root", "size": 133, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478082.160918-4532-188459674088224/source", "state": "file", "uid": 0}

TASK [add default gateway for centralRouter] **********************************************************************************************************************************************************************
task path: /vagrant/playbook.yml:30
changed: [inetRouter] => {"changed": true, "checksum": "48c0237b41ee0a7bb53aa65af19a1846059a5014", "dest": "/etc/netplan/50-vagrant.yaml", "gid": 0, "group": "root", "md5sum": "81e1a3cd9a7561e752db86198bcf72c5", "mode": "0644", "owner": "root", "size": 343, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478082.8327577-4599-136443883186199/source", "state": "file", "uid": 0}
changed: [centralRouter] => {"changed": true, "checksum": "6ec896bc6781bcf9db2d60b8c93d0f6a0351e365", "dest": "/etc/netplan/50-vagrant.yaml", "gid": 0, "group": "root", "md5sum": "97a0427bc870303d524a12655e0f9143", "mode": "0644", "owner": "root", "size": 567, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478082.8783956-4601-43452597073157/source", "state": "file", "uid": 0}
changed: [office1Router] => {"changed": true, "checksum": "54cfd0b77b225e15b00d5ae029e40a8638a53127", "dest": "/etc/netplan/50-vagrant.yaml", "gid": 0, "group": "root", "md5sum": "eab927985cf8fb36b75946a3801807a6", "mode": "0644", "owner": "root", "size": 380, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478082.9387178-4605-218898837453206/source", "state": "file", "uid": 0}
changed: [office2Router] => {"changed": true, "checksum": "df259771d99849f0d8c4f421743fe3f0ca87e6e6", "dest": "/etc/netplan/50-vagrant.yaml", "gid": 0, "group": "root", "md5sum": "343ab24b58b1a55ab1dfd273db7bbbe5", "mode": "0644", "owner": "root", "size": 328, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478083.0020149-4611-88090883238885/source", "state": "file", "uid": 0}
changed: [centralServer] => {"changed": true, "checksum": "5c4ba300cd34e362332ea36a3bc6f50277f33176", "dest": "/etc/netplan/50-vagrant.yaml", "gid": 0, "group": "root", "md5sum": "0a2fa1c9842cc8677e927bc5f2222643", "mode": "0644", "owner": "root", "size": 170, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478083.0619395-4616-266573397676054/source", "state": "file", "uid": 0}
changed: [office1Server] => {"changed": true, "checksum": "dda624b6567ad018d3c71b36b7387615b1dade3e", "dest": "/etc/netplan/50-vagrant.yaml", "gid": 0, "group": "root", "md5sum": "c0defe9d75cfa17dcc64b1246cd6a524", "mode": "0644", "owner": "root", "size": 174, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478083.1413822-4622-152971756896382/source", "state": "file", "uid": 0}
changed: [office2Server] => {"changed": true, "checksum": "c65472a4c210c79a7726005cd0629731755435f8", "dest": "/etc/netplan/50-vagrant.yaml", "gid": 0, "group": "root", "md5sum": "4a993af551936d002ec17e3b56feb007", "mode": "0644", "owner": "root", "size": 170, "src": "/home/vagrant/.ansible/tmp/ansible-tmp-1725478083.2281158-4630-273942206032205/source", "state": "file", "uid": 0}

TASK [restart all hosts] ******************************************************************************************************************************************************************************************
task path: /vagrant/playbook.yml:37

^C [ERROR]: User interrupted execution
```
Все задачи выполнились успешно, но почему-то не дождался итогового результата, выполнение зависло на перезагрузке всех хостов.
Проверяем таблицу маршрутизации на каждом, проверяем связность внутренних сетей и выход в интернет через inetRouter.
После настройки проверил хосты, все настройки применились.
# inetRouter
```
root@inetRouter:~#
root@inetRouter:~# ip r
default via 10.0.2.2 dev eth0 proto dhcp src 10.0.2.15 metric 100
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.2 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
192.168.0.0/24 via 192.168.255.2 dev eth1 proto static
192.168.1.0/24 via 192.168.255.2 dev eth1 proto static
192.168.2.0/24 via 192.168.255.2 dev eth1 proto static
192.168.255.0/30 dev eth1 proto kernel scope link src 192.168.255.1
192.168.255.0/24 via 192.168.255.2 dev eth1 proto static
```
# centralRouter
```
root@centralRouter:~# ip r
default via 192.168.255.1 dev eth1 proto static
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
192.168.0.0/28 dev eth2 proto kernel scope link src 192.168.0.1
192.168.0.32/28 dev eth3 proto kernel scope link src 192.168.0.33
192.168.0.64/26 dev eth4 proto kernel scope link src 192.168.0.65
192.168.1.0/24 via 192.168.255.6 dev eth6 proto static
192.168.2.0/24 via 192.168.255.10 dev eth5 proto static
192.168.255.0/30 dev eth1 proto kernel scope link src 192.168.255.2
192.168.255.4/30 dev eth6 proto kernel scope link src 192.168.255.5
192.168.255.8/30 dev eth5 proto kernel scope link src 192.168.255.9
```
# office1Router
```
root@office1Router:~# ip r
default via 192.168.255.9 dev eth1 proto static
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
192.168.2.0/26 dev eth2 proto kernel scope link src 192.168.2.1
192.168.2.64/26 dev eth3 proto kernel scope link src 192.168.2.65
192.168.2.128/26 dev eth4 proto kernel scope link src 192.168.2.129
192.168.2.192/26 dev eth5 proto kernel scope link src 192.168.2.193
192.168.255.8/30 dev eth1 proto kernel scope link src 192.168.255.10
```
# office2Router
```
root@office2Router:~# ip r
default via 192.168.255.5 dev eth1 proto static
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
192.168.1.0/25 dev eth2 proto kernel scope link src 192.168.1.1
192.168.1.128/26 dev eth3 proto kernel scope link src 192.168.1.129
192.168.1.192/26 dev eth4 proto kernel scope link src 192.168.1.193
192.168.255.4/30 dev eth1 proto kernel scope link src 192.168.255.6
```
# centralServer
```
root@centralServer:~# ip r
default via 192.168.0.1 dev eth1 proto static
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
192.168.0.0/28 dev eth1 proto kernel scope link src 192.168.0.2
```
# office1Server
```
root@office1Server:~# ip r
default via 192.168.2.129 dev eth1 proto static
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
192.168.2.128/26 dev eth1 proto kernel scope link src 192.168.2.130vice: Consumed 1.657s CPU time.
```
# office2Server
```
root@office2Server:~# ip r
default via 192.168.1.1 dev eth1 proto static
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
10.0.2.3 dev eth0 proto dhcp scope link src 10.0.2.15 metric 100
192.168.1.0/25 dev eth1 proto kernel scope link src 192.168.1.2
```
# Проверка
C office1Server пингуем office2Server и centralServer
```
root@office1Server:~# ping 192.168.1.2
PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
64 bytes from 192.168.1.2: icmp_seq=1 ttl=61 time=1.27 ms
64 bytes from 192.168.1.2: icmp_seq=2 ttl=61 time=1.15 ms
64 bytes from 192.168.1.2: icmp_seq=3 ttl=61 time=1.14 ms
64 bytes from 192.168.1.2: icmp_seq=4 ttl=61 time=1.29 ms
^C
--- 192.168.1.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 1.143/1.212/1.290/0.066 ms
root@office1Server:~# ping 192.168.0.2
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
64 bytes from 192.168.0.2: icmp_seq=1 ttl=62 time=0.967 ms
64 bytes from 192.168.0.2: icmp_seq=2 ttl=62 time=0.784 ms
^C
--- 192.168.0.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.784/0.875/0.967/0.091 ms
```
С office1Server пингуем интернет
```
root@office1Server:~# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=105 time=26.0 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=105 time=25.4 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 25.367/25.680/25.994/0.313 ms
root@office1Server:~# traceroute 8.8.8.8
traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
 1  _gateway (192.168.2.129)  0.497 ms  0.524 ms  0.560 ms
 2  192.168.255.9 (192.168.255.9)  0.829 ms  0.817 ms  0.732 ms
 3  192.168.255.1 (192.168.255.1)  1.224 ms  1.264 ms  1.320 ms
 4  10.0.2.2 (10.0.2.2)  1.693 ms  1.683 ms  1.641 ms
 5  * * *
 6  * * *
 7  * * *
 8  * * *
```


