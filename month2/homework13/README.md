script.sh - bash скрипт, который анализирует лог, формирует файл отчета и отправляет его по email

Создадим юнит для сервиса, который будет запускать скрипт анализа логов:
```
root@nginx:~# cat /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
ExecStart=/opt/script.sh
```

Создадим юнит для таймера, который будет раз в час запускать сервис watchlog.service:
```
root@nginx:~# cat /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 1 hour

[Timer]
# Run every 1 hour
OnUnitActiveSec=3600
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
```

