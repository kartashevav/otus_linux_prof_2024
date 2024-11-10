# Развертывание веб приложения
По методичке создаем струкруту проекта, все конфиги файлов берем без изменений, кроме playbook.yml
Нужно изменить версию устанавливаемого docker и docker-compose, версия docker должна соответстовать используемому дистрибутиву ubuntu, в моем случае jammy stable, а docker-compose последюю версию v2.30.3. 
ansible у меня на отдельной виртуальной машине, поэтому провижига в vagrantfile нет.
playbook запускаю отдельно
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
Skipping callback 'default', as we already have a stdout callback.
Skipping callback 'minimal', as we already have a stdout callback.
Skipping callback 'oneline', as we already have a stdout callback.

PLAYBOOK: playbook.yml *************************************************************************************************
1 plays in /vagrant/playbook.yml

PLAY [DynamicWeb] ******************************************************************************************************

TASK [Install docker packages] *****************************************************************************************
task path: /vagrant/playbook.yml:6
ok: [DynamicWeb] => (item=apt-transport-https) => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"}, "ansible_loop_var": "item", "cache_update_time": 1721756553, "cache_updated": false, "changed": false, "item": "apt-transport-https"}
ok: [DynamicWeb] => (item=ca-certificates) => {"ansible_loop_var": "item", "cache_update_time": 1721756553, "cache_updated": false, "changed": false, "item": "ca-certificates"}
ok: [DynamicWeb] => (item=curl) => {"ansible_loop_var": "item", "cache_update_time": 1721756553, "cache_updated": false, "changed": false, "item": "curl"}
ok: [DynamicWeb] => (item=software-properties-common) => {"ansible_loop_var": "item", "cache_update_time": 1721756553, "cache_updated": false, "changed": false, "item": "software-properties-common"}

...

PLAY RECAP *************************************************************************************************************
DynamicWeb                 : ok=10   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
после завершения выполнения playbook  проверяем доступность web-приложений, приложения по пору 8081 и 8082 запускаются без предварительной настройки, для wordpress нужно предварительно настроить проект через web-форму.
```
C:\Users\papasasha>curl localhost:8081

<!doctype html>

<html>
    <head>
        <meta charset="utf-8">
        <title>Django: the Web framework for perfectionists with deadlines.</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" type="text/css" href="/static/admin/css/fonts.css">
        <style type="text/css">
          body, main {
            margin: 0 auto;
          }

C:\Users\papasasha>curl localhost:8082
Hello from node js server

C:\Users\papasasha>curl localhost:8083
<!doctype html>
<html lang="en-US">
<head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="profile" href="https://gmpg.org/xfn/11" />
        <title>test &#8211; Just another WordPress site</title>

```
Web-приложения супешно запустились.
