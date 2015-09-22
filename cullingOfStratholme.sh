#!/bin/bash

set -e
PWD="$(pwd)"

declare -a ADDONS

ADDONS[0]=https://addon.theunderminejournal.com/TheUndermineJournal.zip
ADDONS[1]=http://www.wowinterface.com/downloads/info7017-LightHeaded.html
ADDONS[2]=https://s3.amazonaws.com/WoW-Pro/WoWPro+v6.2.2.zip
ADDONS[3]=http://www.curse.com/addons/wow/raidachievement_oldmodules/download
ADDONS[4]=http://www.curse.com/addons/wow/raidachievement_pandaria/download
ADDONS[5]=http://www.curse.com/addons/wow/raidachievement/download
ADDONS[6]=http://www.curse.com/addons/wow/clique/download
ADDONS[7]=http://www.curse.com/addons/wow/altoholic/download
ADDONS[8]=http://www.curse.com/addons/wow/npcscan-overlay/download
ADDONS[9]=http://www.curse.com/addons/wow/master-plan/download
ADDONS[10]=http://www.curse.com/addons/wow/npcscan/download
ADDONS[11]=http://www.curse.com/addons/wow/handynotes/download
ADDONS[12]=http://www.curse.com/addons/wow/recount/download
ADDONS[13]=http://www.curse.com/addons/wow/deadly-boss-mods/download
ADDONS[14]=http://www.curse.com/addons/wow/grail/download
ADDONS[15]=http://www.curse.com/addons/wow/tomtom/download
ADDONS[16]=http://www.curse.com/addons/wow/lorewalkers-helper/download
ADDONS[17]=http://www.curse.com/addons/wow/lorewalkers/download
ADDONS[18]=http://www.curse.com/addons/wow/handynotes_lorewalkers/download
ADDONS[19]=http://www.curse.com/addons/wow/loremasteraddon/download
ADDONS[20]=http://www.curse.com/addons/wow/dark-soil/download
ADDONS[21]=http://www.curse.com/addons/wow/finders-keepers/download
ADDONS[22]=http://www.curse.com/addons/wow/vludstillergifts/download
ADDONS[23]=http://www.curse.com/addons/wow/arl/download
ADDONS[24]=http://www.curse.com/addons/wow/weakauras-2/download
ADDONS[25]=http://www.curse.com/addons/wow/blood-shield-tracker/download
ADDONS[26]=http://www.curse.com/addons/wow/bagsync/download
ADDONS[27]=http://www.curse.com/addons/wow/pawn/download
ADDONS[28]=http://www.curse.com/addons/wow/mmz/download
ADDONS[29]=http://www.curse.com/addons/wow/crossrealmassist/download

#Default WoW install path on OSX
ADDONPATH=/Applications/World\ of\ Warcraft/Interface/AddOns

GREEN="$(tput setaf 2)"
CRESET="$(tput sgr0)"

function getAddonProvider {
	#echo "Finding Addon Provider for URL: ${GREEN}$1${CRESET}"
	local PROVIDER="$(echo $1 | grep -E -o '\w+\.com')"
	echo $PROVIDER
	#PROVIDER="$(echo $1 | grep -E -o 'w+.com')"
	#echo $PROVIDER
}

function dlWowIAddon {
	echo "Updating Addon from wowinterface.com..."

	#Get the URL to download the file
	local DLURL="http://www.wowinterface.com/downloads/getfile.php?id=$(wget -q $1 -O - | grep landing | grep -E -o 'fileid=\d+' | uniq | cut -f2 -d=)"
	echo "Download URL: ${GREEN}$DLURL${CRESET}"

	#Set the name of the file manually
	local ZFILE=addon.zip
	echo "Zip File: ${GREEN}$ZFILE${CRESET}"

	#Get the name of just the zip file
	local ZDIRNAME=wow_interface_addon

	#Remove the temp dir if it exists
	rm -rfv /tmp/CoS/tmpAddon

	#Re-create the dir
	mkdir -p /tmp/CoS/tmpAddon

	#Download the file
	echo "Downloading file: ${GREEN}$DLURL${CRESET}"
	wget -O /tmp/CoS/$ZFILE $DLURL

	#Unzip the file to a temp directory
	ZDIRNAME=tmpCurseDl
	echo "Unzipping file: ${GREEN}/tmp/$ZFILE${CRESET} to ${GREEN}/tmp/$ZDIRNAME${CRESET}"
	unzip -o /tmp/CoS/$ZFILE -d /tmp/CoS/tmpAddon

	#Copy only new files into the Addon directory
	rsync -hvrPt /tmp/CoS/tmpAddon/ "$ADDONPATH"
}

function printList {
	ADDONCOUNT=0
	for i in "${ADDONS[@]}";
	do
		echo "$ADDONCOUNT - $i"
		ADDONCOUNT=$((ADDONCOUNT + 1))

	done
	exit
}

function parseFileName {
	local FILENAME="$(echo $1 | grep -E -o '[A-Z,a-z,0-9,\._+-]*\.zip$')"
	echo $FILENAME
}

function parseDirName {
	local DIRNAME="$(echo $1 | sed -E 's/.{4}$/ /g')"
}

function parseAddonDirName {
	echo "parse!"
	#Get the name of the addon directory from the zip file
	#local ADDONDIR="$(unzip -l /tmp/$ZFILE | grep -E -o '   \w+\/' | sort | uniq | grep -E -o '\w+')"
	#echo "Searching Addon archive and found directory named: ${GREEN}$ADDONDIR${CRESET}"
}

function dlCurseAddon {
	echo "Updating Addon from curse.com..."
	#Get the URL to download the file
	local DLURL="$(wget -q $1 -O - | grep "If your download" | grep -E -o 'http://.*\.zip')"
	echo "Download URL: ${GREEN}$DLURL${CRESET}"

	#Get the name of the file itself
	local ZFILE=$(parseFileName $DLURL)
	echo "Zip File: ${GREEN}$ZFILE${CRESET}"

	#Get the name of just the zip file
	local ZDIRNAME=$(parseDirName $ZFILE)

	#Remove the temp dir if it exists
	rm -rfv /tmp/CoS/tmpAddon

	#Re-create the dir
	mkdir -p /tmp/CoS/tmpAddon

	#Download the file
	echo "Downloading file: ${GREEN}$DLURL${CRESET}"
	cd /tmp/CoS
	wget -N $DLURL

	#Unzip the file to a temp directory
	ZDIRNAME=tmpCurseDl
	echo "Unzipping file: ${GREEN}/tmp/$ZFILE${CRESET} to ${GREEN}/tmp/$ZDIRNAME${CRESET}"
	unzip -o /tmp/CoS/$ZFILE -d /tmp/CoS/tmpAddon

	#Copy only new files into the Addon directory
	rsync -hvrPt /tmp/CoS/tmpAddon/ "$ADDONPATH"
}

function dlIndy {
	echo "Updating Independent Addon..."
	#Get the URL to download the file
	local DLURL=$1
	echo "Download URL: ${GREEN}$DLURL${CRESET}"

	#Get the name of the file itself
	local ZFILE=$(parseFileName $DLURL)
	echo "Zip File: ${GREEN}$ZFILE${CRESET}"

	#Get the name of just the zip file
	local ZDIRNAME=$(parseDirName $ZFILE)

	#Remove the temp dir if it exists
	rm -rfv /tmp/CoS/tmpAddon

	#Re-create the dir
	mkdir -p /tmp/CoS/tmpAddon

	#Download the file
	echo "Downloading file: ${GREEN}$DLURL${CRESET}"
	cd /tmp/CoS
	wget -N $DLURL

	#Unzip the file to a temp directory
	ZDIRNAME=tmpCurseDl
	echo "Unzipping file: ${GREEN}/tmp/$ZFILE${CRESET} to ${GREEN}/tmp/$ZDIRNAME${CRESET}"
	unzip -o /tmp/CoS/$ZFILE -d /tmp/CoS/tmpAddon

	#Copy only new files into the Addon directory
	rsync -hvrPt /tmp/CoS/tmpAddon/ "$ADDONPATH"
}

function dlAddon {
	echo "Finding Addon Provider for URL: ${GREEN}$1${CRESET}"
	PROVIDER=$(getAddonProvider $1)
	echo "Found Provider: ${GREEN}$PROVIDER${CRESET}"
	
	if [ "$PROVIDER" == "curse.com" ]
	then
		dlCurseAddon $1
	elif [ "$PROVIDER" == "wowinterface.com" ]
	then
	  dlWowIAddon $1
	elif [ "$PROVIDER" == "github.com" ]
	then
	  echo "github"
	else
	  dlIndy $1
	fi
}

#function getGitAddons {

#}

if [ "$1" != "" ]
then
	if [ "$1" == "list" ]
	then
		printList
	else
		ADDONURL=${ADDONS[$1]}
		dlAddon $ADDONURL
	fi
else
	for i in "${ADDONS[@]}";
	do
		dlAddon $i
	done
fi

cd $PWD