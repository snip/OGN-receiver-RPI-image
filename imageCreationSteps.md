## Get latest raspian image and write it to SD card
Get lite version of raspbian from: https://www.raspberrypi.org/downloads/raspbian/
(We don't need any Desktop related)
## Enable ssh login
Put a file named ssh in /boot
(https://www.raspberrypi.org/documentation/remote-access/ssh/)
## Boot RPi with this SD card
Upgrade system:
```
apt-get update
apt-get dist-upgrade
rpi-update
```
Update hostname to `ogn-receiver` thanks to `raspi-config`
## Install standard OGN lib & softs + standard config
```
apt-get update
apt-get install rtl-sdr libconfig9 libjpeg8 fftw3-dev procserv telnet ntpdate ntp lynx
```
* Apply DVB-T blacklist
```
cat >> /etc/modprobe.d/rtl-glidernet-blacklist.conf <<EOF
blacklist rtl2832
blacklist r820t
blacklist rtl2830
blacklist dvb_usb_rtl28xxu
EOF
```

* Install service
```
wget https://raw.githubusercontent.com/snip/OGN-receiver-RPI-image/master/dist/rtlsdr-ogn -O /etc/init.d/rtlsdr-ogn
wget https://raw.githubusercontent.com/snip/OGN-receiver-RPI-image/master/dist/rtlsdr-ogn-service.conf -O /etc/rtlsdr-ogn-service.conf
chmod +x /etc/init.d/rtlsdr-ogn
update-rc.d rtlsdr-ogn defaults
```

## Manage /boot/OGN-receiver.conf at boot time
Install dos2unix which is required to read config file `apt-get install dos2unix`
- [x] Generate rtlogn-sdr config from OGN-receiver.conf
- [x] If exist use /boot/rtlsdr-ogn.conf at boot
- [x] Disable pi user password login (only ssh key login)
- [x] Change pi user password & allow password login
- [x] Option to run a specific command at each boot

```
wget https://raw.githubusercontent.com/snip/OGN-receiver-RPI-image/master/dist/OGN-receiver.conf -O /boot/OGN-receiver.conf 
wget https://raw.githubusercontent.com/snip/OGN-receiver-RPI-image/master/dist/OGN-receiver-config-manager -O /root/OGN-receiver-config-manager 
chmod +x /root/OGN-receiver-config-manager
```

## Manage rtlsdr-ogn auto upgrade
Download at each rtlsdr-ogn startup.

## Manage optional remote admin
```
apt-get install autossh
ssh-keygen
cat ~/.ssh/id_rsa.pub 
wget "https://raw.githubusercontent.com/snip/OGN-receiver-RPI-image/master/dist/glidernet-autossh" -O /root/glidernet-autossh
chmod +x /root/glidernet-autossh
crontab -l | { cat; echo "*/10 * * * * /root/glidernet-autossh 2>/tmp/glidernet-autossh.log"; } | crontab -
```

as pi:
```
mkdir .ssh
wget "http://autossh.glidernet.org/~glidernet-adm/id_rsa.pub" -O .ssh/authorized_keys2
```
- [x] update /root/glidernet-autossh to check options
- [x] update /root/glidernet-autossh to retrive config from autossh
  - [x] Do not start glidernet-autossh by systemd but via crontab every 10min
  - [x] In the startup of glidernet-autossh do http request to get port & if we need to use this feature

## Manage self-update
Example taken from: https://github.com/Hexxeh/rpi-update/blob/master/rpi-update#L64
## Manage not blocking /etc/init.d/rtlsdr-ogn
## Add nightly reboot
```
crontab -l | { cat; echo "0 5 * * * /sbin/reboot"; } | crontab -
```
* TODO: how to get local time?

Maybe with https://ipsidekick.com/json or https://ipapi.co/timezone/ ? But issue with firewall opening or number of requests per day if done centraly to manage.
## Manage firstboot ? => Do we realy need it?
* To create hosts ssh keys on rw SD card. Then activate RO?
* In any cases root's ssh keys need to be the same for autossh remote admin.
* We need to expend FS at first boot => Do we realy need it? Don't think so.
```
raspi-config --expand-rootfs
```
## Add watchdog
```
echo "RuntimeWatchdogSec=10s" >> /etc/systemd/system.conf
echo "ShutdownWatchdogSec=4min" >> /etc/systemd/system.conf
```
See: https://www.raspberrypi.org/forums/viewtopic.php?f=29&t=147501&start=25#p1254069
And to check if it working well, to generate a kernel panic: `echo c > /proc/sysrq-trigger`
## Disable swap
```
sudo systemctl stop dphys-swapfile
sudo systemctl disable dphys-swapfile
sudo apt-get purge dphys-swapfile
```
## Add RO FS
```
cd /sbin
wget https://github.com/ppisa/rpi-utils/raw/master/init-overlay/sbin/init-overlay
wget https://github.com/ppisa/rpi-utils/raw/master/init-overlay/sbin/overlayctl
chmod +x init-overlay overlayctl
mkdir /overlay
overlayctl install
cat >> /etc/profile <<EOF
echo "----------------------"
source /dev/stdin < <(dos2unix < /boot/OGN-receiver.conf)
echo "OGN receiver \$ReceiverName"
echo "Read-only file system (overlay) status:"
/sbin/overlayctl status
echo "To manage it (as root): overlayctl disable | overlayctl enable | overlayctl status"
echo "----------------------"
EOF
reboot
```
(from: http://wiki.glidernet.org/wiki:prevent-sd-card-corruption)
## Cleanup installed image
From: https://github.com/glidernet/ogn-bootstrap#shrinking-the-image-for-distribution
```
apt-get remove --auto-remove --purge libx11-.*
apt-get remove deborphan
apt-get autoremove
apt-get autoclean
apt-get clean
rm -rf /var/log/*
dd if=/dev/zero of=file-filling-disk-with-0 bs=1M
rm file-filling-disk-with-0
```

Optional: Remove history.

## Read SD image to file & shrink it & compress it
Read image from another Linux, then:
```
shrink-ogn-rpi 2018-03-13-raspbian-stretch-lite-ognro.img
zip -9 2018-03-13-raspbian-stretch-lite-ognro.zip 2018-03-13-raspbian-stretch-lite-ognro.img
```
