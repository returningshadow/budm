#!/bin/bash

# budm version 0.3
# copyright 2014 Reid Wicks under GPLv3
# That's there because I think I need to put it there.

# consulted while creating this script:
# reddit user antenore (http://www.reddit.com/r/linux/comments/1v36dv/i_want_to_create_a_graphical_program_that_will/ceoazx6)
# the manpage for zenity (December 2011)
# https://help.gnome.org/users/zenity/stable/ (2014-01-13)
# the manpage for bash (2010 December 28)
# 

# tweaked by Troy Denton on a whim.  Now contains basic input validation, and only allows you to select an unmounted drive.

zenity --warning --title="Warning!" --text="This program is a beta. Please proceed at your own risk. Use of this program may result in data loss. If you aren't willing to risk it, or do not understand the risks, please close this program."

#get list of all drives (not partitions) that are NOT mounted.  Very likely we do not want to format those ones.

mounted_drives=$(df -h | sed -ne '/^\/dev/ s/[0-9].*//gp')
valid_drives=""
for i in $(ls /dev/sd?)
do
	is_valid=1
	for j in $mounted_drives
	do
		if [ $i == $j ]; then
			is_valid=0
		fi	
	done
	if [[ $is_valid -eq 1 ]]; then
		valid_drives="$valid_drives $i"
	fi
done


#exit if there are no valid drives
if [ -z $valid_drives ]; then
	zenity --warning --title="Warning!" --text="To flash a disk, there must be at least one unmounted disk present.  Please be sure to eject the drive you wish to flash."
	exit 1
fi

# add a second column to each entry for zenity to display properly
drive_choices=$(echo $valid_drives | sed -ne 's/^/FALSE /p')


drive=$( zenity  --list --title="Disk selection" --text "Pick disk to flash:" --radiolist  --column "" --column "Disk" $drive_choices )
iso=$( zenity --file-selection --title="Please select the .iso you want to burn" --file-filter=*.iso )

#make sure they actually selected something...
if [ -z "$iso" ]; then
	zenity --warning --title="Warning!" --text="No file selected, now exiting..."
	exit 1
fi

zenity --info --title="Filename" --text="The file you selected is $iso."

#TODO final confirmation
#TODO need to write new partition table?


#TODO comment below :)

sudo mkfs.vfat -I $drive && sudo dd if="$iso" of=$drive oflag=direct bs=10M | zenity --progress --title="Creating bootable USB device" --text="The creation of your bootable USB device is in progress..." --pulsate --auto-close
zenity --info --title="Done!" --text="Your drive, created from file \"$iso\", is now bootable!"
exit 0
