# OGN-receiver-RPI-image
Process to create a Raspberry Pi SD image for OGN receiver

Main target is to provide an fast, reliable and easy way to install OGN receivers.

Latest usable image is available here: http://download.glidernet.org/seb-ogn-rpi-image

This version 0.3 is based on Raspberry Pi OS lite released the 2022-04-04 (Bullseye)

Before installing the SD card in the Pi you should update the receiver position, altitude, name, etc. in the single config file from a Windows PC in readable FAT partition (OGN-receiver.conf).

French manual: https://bit.ly/2R3CtQe

English manual: https://bit.ly/2R1cfh9

# Features
- ssh enabled. User is pi and password is configurable from single config file. (pi password login disabled by default)
- Tested with RPi3, RPi3+, Pi4, CM4, Pi Zero 2 W (but should be compatible with all RPi models)
- Filesystem OverlayFS installed
- Allows remote login from OGN core team (Pawel & Seb) => Can be disabled from config file
- Allows wifi connection from single config file
- Hardware watchdog enabled
- OGN receiver auto-upgrade
- Automatic GeoidSepar by using WW15MGH.DAC
- Bias tee management from config file
