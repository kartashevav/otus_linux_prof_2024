Vagrentfile запускает ubuntu2204 создает скрипт для проверки прав на аутентификацию.
Так как задание делал в четверг, чтоб не изменять время на машине, изменил условие скрипта, пользователям группы admin разрешен логин в четверг и воскресенье.

Скрипт отработал, в логах видно, что при подключении пользователя otus, скрипт завершается с exit code 1
```
Aug 15 19:59:07 ubuntu2204 sshd[2180]: pam_exec(sshd:auth): Calling /usr/local/bin/login.sh ...
Aug 15 19:59:07 ubuntu2204 sshd[2177]: Accepted password for otusadm from 10.0.2.2 port 55091 ssh2
Aug 15 19:59:07 ubuntu2204 sshd[2177]: pam_unix(sshd:session): session opened for user otusadm(uid=1001) by (uid=0)
Aug 15 19:59:07 ubuntu2204 systemd-logind[745]: New session 6 of user otusadm.
Aug 15 19:59:07 ubuntu2204 systemd: pam_unix(systemd-user:session): session opened for user otusadm(uid=1001) by (uid=0)
Aug 15 19:59:11 ubuntu2204 sshd[2177]: pam_unix(sshd:session): session closed for user otusadm
Aug 15 19:59:11 ubuntu2204 systemd-logind[745]: Session 6 logged out. Waiting for processes to exit.
Aug 15 19:59:11 ubuntu2204 systemd-logind[745]: Removed session 6.
Aug 15 19:59:23 ubuntu2204 sshd[2242]: pam_exec(sshd:auth): Calling /usr/local/bin/login.sh ...
Aug 15 19:59:23 ubuntu2204 sshd[2237]: pam_exec(sshd:auth): /usr/local/bin/login.sh failed: exit code 1
Aug 15 19:59:25 ubuntu2204 sshd[2237]: Failed password for otus from 10.0.2.2 port 55093 ssh2
Aug 15 19:59:29 ubuntu2204 sshd[2237]: error: Received disconnect from 10.0.2.2 port 55093:13: Unable to authenticate [preauth]
Aug 15 19:59:29 ubuntu2204 sshd[2237]: Disconnected from authenticating user otus 10.0.2.2 port 55093 [preauth]
```
