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
apt-get install rtl-sdr libconfig9 libjpeg8 procserv telnet ntpdate ntp lynx
?? libconfig-dev fftw3-dev libjpeg-dev
?? g++ make cmake build-essential 
```
* Apply DVB-T blacklist

* Install service
```
sudo wget http://download.glidernet.org/common/service/rtlsdr-ogn -O /etc/init.d/rtlsdr-ogn
sudo wget http://download.glidernet.org/common/service/rtlsdr-ogn.conf -O /etc/rtlsdr-ogn.conf
sudo chmod +x /etc/init.d/rtlsdr-ogn
sudo update-rc.d rtlsdr-ogn defaults
```
Update `/etc/rtlsdr-ogn.conf` to point config to standard one: `../rtlsdr-ogn.conf`

We will need to update `/etc/init.d/rtlsdr-ogn` to manage `/boot/OGN-receiver.conf` feature.


## TODO: Manage /boot/OGN-receiver.conf at boot time
* TODO: Generate rtlogn-sdr config from OGN-receiver.conf
- [x] If exist use /boot/rtlsdr-ogn.conf at boot
- [x] Disable pi user password login (only ssh key login)
- [x] Change pi user password & allow password login
- [x] Option to run a specific command at each boot
## TODO: Manage rtlsdr-ogn auto upgrade
Download at each boot.
## TODO: Manage optional remote admin
```
apt-get install autossh
ssh-keygen
cat ~/.ssh/id_rsa.pub 
wget "http://autossh.glidernet.org/~glidernet-adm/glidernet-autossh" -O /etc/init.d/glidernet-autossh
sed -i 's/XXXX/5340/g' /etc/init.d/glidernet-autossh
chmod +x /etc/init.d/glidernet-autossh
update-rc.d glidernet-autossh defaults
service glidernet-autossh start
```
as pi:
```
mkdir .ssh
wget "http://autossh.glidernet.org/~glidernet-adm/id_rsa.pub" -O .ssh/authorized_keys2
```
- [x] update /etc/init.d/glidernet-autossh to check options
- [ ] update /etc/init.d/glidernet-autossh to retrive config from autossh

## TODO: Manage firstboot ?
* To create hosts ssh keys on rw SD card. Then activate RO?
* In any cases root's ssh keys need to be the same for autossh remote admin.
* We need to expendand FS at first boot
## TODO: Add nightly reboot
* how to get local time?

Maybe with https://ipsidekick.com/json or https://ipapi.co/timezone/ ? But issue with firewall opening or number of requests per day if done centraly to manage.
## TODO: Add RO FS
## TODO: Disable swap & add watchdog
## TODO: Cleanup installed image
## TODO: Read SD image to file & shrink it
