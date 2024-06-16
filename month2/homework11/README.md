1.Включить отображение меню Grub.

Для отображения меню нужно отредактировать конфигурационный файл.
vagrant@nginx:~$ sudo nano /etc/default/grub

смотрим, что файл отредактирован
vagrant@nginx:~$ sudo cat /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=0
#GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=10
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT==" net.ifnames=0 biosdevname=0"
GRUB_CMDLINE_LINUX=""

# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"

# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command `vbeinfo'
#GRUB_GFXMODE=640x480

# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY="true"

# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"

Обновляем конфигурацию загрузчика и перезагружаемся для проверки.


vagrant@nginx:~$ sudo update-grub
Sourcing file `/etc/default/grub'
Sourcing file `/etc/default/grub.d/init-select.cfg'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-5.15.0-91-generic
Found initrd image: /boot/initrd.img-5.15.0-91-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
done

vagrant@nginx:~$ sudo reboot

2. Попасть в систему без пароля несколькими способами.
при выборе ядра для загрузки нажать 'e'
2.1 init=/bin/bash
По руководству все получилось, добавил init=/bin/bash, попал в систему, перемонтировал корневую в rw.

2.2 Recovery mode
тоже все получилось по руководству
способ Recovery mode более простой

3. Установить систему с LVM, после чего переименовать VG

vagrant@nginx:~$ sudo -i
root@nginx:~# vgs
  VG        #PV #LV #SN Attr   VSize    VFree
  ubuntu-vg   1   1   0 wz--n- <126.00g 63.00g
 
root@nginx:~# vgrename ubuntu-vg ubuntu-otus
  Volume group "ubuntu-vg" successfully renamed to "ubuntu-otus"

nano /boot/grub/grub.cfg 
  
root@nginx:~# cat /boot/grub/grub.cfg | grep otus
        linux   /vmlinuz-5.15.0-91-generic root=/dev/mapper/ubuntu--otus-ubuntu--lv ro  = net.ifnames=0 biosdevname=0
                linux   /vmlinuz-5.15.0-91-generic root=/dev/mapper/ubuntu--otus-ubuntu--lv ro  = net.ifnames=0 biosdevname=0
                linux   /vmlinuz-5.15.0-91-generic root=/dev/mapper/ubuntu--otus-ubuntu--lv ro recovery nomodeset dis_ucode_ldr

vagrant@nginx:~$ sudo vgs
  VG          #PV #LV #SN Attr   VSize    VFree
  ubuntu-otus   1   1   0 wz--n- <126.00g 63.00g
  
 