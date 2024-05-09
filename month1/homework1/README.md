Загрузил машину с ядром 6.8.0-31-generic
vagrant@ubuntu:~$ uname -r
6.8.0-31-generic
Дальше, по инструкции с https://phoenixnap.com/kb/build-linux-kernel собрал ядро из исходников и обновил, при запуске машины с новым ядром столкнулся с "Kernel panic - not syncing: System is deadlocked on memory".
Нагуглил, что нужно дать машине больше оперативки, добавил и все поднялос.
Давал такие команды:
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.9.tar.xz
tar xvf linux-6.8.9.tar.xz
sudo apt-get update
sudo apt-get install git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison
cd linux-6.8.9/
cp -v /boot/config-$(uname -r) .config
make menuconfig
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
make
sudo make modules_install
vagrant@ubuntu:~/linux-6.8.9$ sudo make install
  INSTALL /boot
run-parts: executing /etc/kernel/postinst.d/dkms 6.8.9 /boot/vmlinuz-6.8.9
 * dkms: running auto installation service for kernel 6.8.9
 * dkms: autoinstall for kernel 6.8.9                                                                            [ OK ]
run-parts: executing /etc/kernel/postinst.d/initramfs-tools 6.8.9 /boot/vmlinuz-6.8.9
update-initramfs: Generating /boot/initrd.img-6.8.9
I: The initramfs will attempt to resume from /dev/sda3
I: (UUID=a1f49f9c-7d27-422b-be1d-8020a234c5b4)
I: Set the RESUME variable to override this.
run-parts: executing /etc/kernel/postinst.d/unattended-upgrades 6.8.9 /boot/vmlinuz-6.8.9
run-parts: executing /etc/kernel/postinst.d/update-notifier 6.8.9 /boot/vmlinuz-6.8.9
run-parts: executing /etc/kernel/postinst.d/vboxadd 6.8.9 /boot/vmlinuz-6.8.9
VirtualBox Guest Additions: Building the modules for kernel 6.8.9.

VirtualBox Guest Additions: Look at /var/log/vboxadd-setup.log to find out what
went wrong
run-parts: executing /etc/kernel/postinst.d/xx-update-initrd-links 6.8.9 /boot/vmlinuz-6.8.9
I: /boot/initrd.img is now a symlink to initrd.img-6.8.9
run-parts: executing /etc/kernel/postinst.d/zz-update-grub 6.8.9 /boot/vmlinuz-6.8.9
Sourcing file `/etc/default/grub'
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.9
Found initrd image: /boot/initrd.img-6.8.9
Found linux image: /boot/vmlinuz-6.8.0-31-generic
Found initrd image: /boot/initrd.img-6.8.0-31-generic
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
vagrant@ubuntu:~/linux-6.8.9$ sudo reboot

vagrant@ubuntu:~$ uname -mrs
Linux 6.8.9 x86_64
