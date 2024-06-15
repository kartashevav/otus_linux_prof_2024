sudo -i
apt install -y nfs-common
echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
FILE=/mnt/upload/check_file 
if test -f "$FILE"; then echo "$FILE exists."; fi
touch /mnt/upload/client_file
FILE_C=/mnt/upload/client_file 
if test -f "$FILE_C"; then echo "$FILE_C exists."; fi