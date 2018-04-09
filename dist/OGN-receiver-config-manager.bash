#!/bin/bash

# Init some variables to default values
FreqCorr="60"
GSMCenterFreq="950"
GSMGain="25"
Altitude="0"
GeoidSepar="0"

# Load config from /boot
source /boot/OGN-receiver.conf

### Generate OGN receiver config file
if [ -z "$ReceiverName" ]
then
  echo "No receiver name provided => Exiting"
  exit 1;
fi

echo "Managing configuration for receiver \"$ReceiverName\".";

if [ -f /boot/rtlsdr-ogn.conf ]
then
  echo "/boot/rtlsdr-ogn.conf exit => Using it for rtlsdr-ogn parameters (ignoring other reciver parameters)."
  cp /boot/rtlsdr-ogn.conf /home/pi/rtlsdr-ogn.conf
else
  if [ -z "$Latitude" ]
  then
    echo "No Latitude provided => Exiting"
    exit 1;
  fi

  if [ -z "$Longitude" ]
  then
    echo "No Longitude provided => Exiting"
    exit 1;
  fi
  
  echo "Generating /home/pi/rtlsdr-ogn.conf"

  cat >/home/pi/rtlsdr-ogn.conf <<EOCONFFILE
RF:
{ 
  FreqCorr = $FreqCorr;          # [ppm]      "big" R820T sticks have 40-80ppm correction factors, measure it with gsm_scan

  GSM:                     # for frequency calibration based on GSM signals
  { CenterFreq  = $GSMCenterFreq;   # [MHz] find the best GSM frequency with gsm_scan
    Gain        = $GSMGain;   # [dB]  RF input gain (beware that GSM signals are very strong !)
  } ;
} ;
Position:
{ Latitude   =   $Latitude; # [deg] Antenna coordinates
  Longitude  =   $Longitude; # [deg]
  Altitude   =        $Altitude; # [m]   Altitude above sea leavel
  GeoidSepar =        $GeoidSepar; # [m]   Geoid separation: FLARM transmits GPS altitude, APRS uses means Sea level altitude
} ;

APRS:
{ Call = "$ReceiverName";     # APRS callsign (max. 9 characters)
} ;

EOCONFFILE

fi

### Manage pi user

echo "Manage pi user"
if [ -z "$piUserPassword" ]
then
  echo "No password specified for \"pi\" user => Disabling usage of password for user \"pi\" (ssh key authentication is still possible)."
  passwd -l pi
else
  echo "Password specified for \"pi\" user => Changing its password."
  echo "pi:$piUserPassword" | chpasswd
fi

### Upgrade rtlsdr-ogn

OGNBINARYURL="http://download.glidernet.org/rpi-gpu/rtlsdr-ogn-bin-RPI-GPU-latest.tgz"

echo "Checking internet connection."
while [ 0 ] # Loop forever until we have a working internet connection
do
  /usr/bin/wget --spider --quiet $OGNBINARYURL
  if [ "$?" -eq 0 ]
  then
    break
  fi
  sleep 1
  echo "."
done
echo "Connected."

echo "Downloading and installing $OGNBINARYURL"
cd /home/pi
/usr/bin/wget $OGNBINARYURL --quiet -O - | tar xzvf -
cd rtlsdr-ogn
chown root gsm_scan
chmod a+s  gsm_scan
chown root ogn-rf
chmod a+s  ogn-rf

### Run a specific command

if [ -n "$runAtBoot" ]
then
  $runAtBoot
fi
