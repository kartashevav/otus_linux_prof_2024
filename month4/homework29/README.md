Так как у меня ansible-server на отдельной машине, делаю отдельные vagrantfile для pxe-server и pxe-client.
Запускаю ansible-server, потом запускаю машину с pxe-server.
Конфигурирую pxe-server через playbook, потом запускаю pxe-client и проверяю работоспособность.
```
root@ansible-server:~# ansible-playbook -k -i /vagrant/hosts /vagrant/playbook.yml
SSH password:
[WARNING]: Found both group and host with same name: pxeserver

PLAY [all] *************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [pxeserver]

TASK [Disable the ufw firewall (on Ubuntu, if configured).] ************************************************************
ok: [pxeserver]

TASK [Update the repository cache and install dnsmasq] *****************************************************************
ok: [pxeserver]

TASK [Install apache httpd] ********************************************************************************************
ok: [pxeserver]

TASK [Creates directory /srv/tftp] *************************************************************************************
ok: [pxeserver]

TASK [download and unarchive ubuntu-24.04.1-netboot] *******************************************************************
ok: [pxeserver]

TASK [config dnsmasq] **************************************************************************************************
ok: [pxeserver]

TASK [Creates directory /srv/images] ***********************************************************************************
ok: [pxeserver]

TASK [Download Ubuntu iso] *********************************************************************************************
ok: [pxeserver]

TASK [config Apache] ***************************************************************************************************
ok: [pxeserver]

TASK [enable apache site ks-server] ************************************************************************************
changed: [pxeserver]

TASK [config pxe] ******************************************************************************************************
changed: [pxeserver]

TASK [Creates directory /srv/ks] ***************************************************************************************
changed: [pxeserver]

TASK [copy user-data] **************************************************************************************************
changed: [pxeserver]

TASK [create meta-data] ************************************************************************************************
changed: [pxeserver]

TASK [restart apache2] *************************************************************************************************
changed: [pxeserver]

PLAY RECAP *************************************************************************************************************
pxeserver                  : ok=16   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```
В итоге машина загрузилась успешно, после изменения способа загрузки, зашел на машину под учетными данными otus/123
