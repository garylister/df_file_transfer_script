#!/bin/bash

# script to transfer files and update file options from one dwarf fortress game folder to another

# make sure that name is not set 
unset name

#this will show the usage message if only one parameter is provided
while getopts n:o:h option
do
case "${option}"
in
h) echo -e "usage: df_file_transfer -n <new df base folder> -o <old df base folder>\nexample: df_file_transfer -n df_linux_47.05 #-o df_linux_47.04" 
    exit;;
n) NEW=${OPTARG};;
o) OLD=${OPTARG};;
esac
done

# check if the length of name is zero and show the usage if it is
# this shows usage if no options are passed
if [ -z $name ]
then
 echo -e "usage: df_file_transfer -n <new df base folder> -o <old df base folder>\nexample: df_file_transfer -n df_linux_47.05 #-o df_linux_47.04"
 exit
fi

INIT_DIR="/data/init";
ART_DIR="/data/art";

# set error checking
set -e;

# arrays of default init and art files
DFLT_INIT_FILES=("announcements.txt" "arena.txt" "colors.txt" "d_init.txt" "init.txt" "interface.txt" "world_gen.txt");
DFLT_ART_FILES=("curses_640x300.bmp" "cusres_640x300.png" "curses_800x600.bmp" "curses_800x600.png" "curses_square_16x16.bmp" "curses_square_16x16.png" "font.ttf" "font license.txt" "mouse.bmp" "mouse.png");

# variables to store the files from the old and new game files
OLD_INIT_FILES=();
NEW_INIT_FILES=();

OLD_ART_FILES=();
NEW_ART_FILES=();

# variables to store the directory paths for the old and new game files
OLD_INIT_PATH=$OLD$INIT_DIR/;
NEW_INIT_PATH=$NEW$INIT_DIR/;

OLD_ART_PATH=$OLD$ART_DIR/;
NEW_ART_PATH=$NEW$ART_DIR/;

# check if both directories exist
if [ -d $NEW ] && [ -d $OLD ]; then

	for entry in "$OLD_INIT_PATH"*
		do
#		echo ${entry#${OLD_INIT_PATH}} 
#		[[ ${OLD_INIT_INIT[*]} =~ ${entry#${OLD_INIT_PATH}} ]] && echo 'yes' || echo 'no'

# check if the value is not a directory using the full path and a substring for if it is 
# not already in the array.  the "(^|[[:space:]])" and "($|[[:space:]])" are needed for 
# exact match

			if [[ ! -d ${entry} ]] && [[ ! ${DFLT_INIT_FILES[*]} =~ (^|[[:space:]])${entry#${OLD_INIT_PATH}}($|[[:space:]]) ]]; then

# if not add the substring to the array

			  OLD_INIT_FILES+=( ${entry#${OLD_INIT_PATH}});
#		else next
			fi
	done
	#printf "%s\n" ${DFLT_INIT_FILES[*]}
	#printf "%s\n" ${OLD_INIT_FILES[*]}

	for entry in "NEW_INIT_PATH"*
		do
			if [[ ! -d ${entry} ]] && [[ ! ${DFLT_INIT_FILES[*]} =~ (^|[[:space:]])${entry#${NEW_INIT_PATH}}($|[[:space:]]) ]]; then

# if not add the substring to the array

			  NEW_INIT_FILES+=( ${entry#${NEW_INIT_PATH}});
			fi
	done	
#	printf "%s\n" ${DFLT_INIT_FILES[*]}
#	printf "%s\n" ${NEW_INIT_FILES[*]}

# find the files in the old directory that are not in the new directory.  These should be backups from
# any changes like from some texture packs.  you want to do this first since the non-backed up files
# could have changes that you won't be able to revert if they are all the changed files 

	for entry in ${OLD_INIT_FILES[*]}
		do
			if [[ ! ${NEW_INIT_FILES[*]} =~ (^|[[:space:]])${OLD_INIT_FILES[*]}}($|[[:space:]]) ]]; then
#			printf "%s\n" ${entry%.txt*}.txt
#				printf "%s\n" $NEW_INIT_PATH${entry%.txt*}.txt $NEW_INIT_PATH${entry}	

# make a copy of the base file from the new directory with the name from the old directory, so you're not
# copying the old file over it.  
				cp $NEW_INIT_PATH${entry%.txt*}.txt $NEW_INIT_PATH${entry}

# add a new line to the end of the old file and the new file if it doesn't already exist, 
# so diff doesn't complain
				tail -c1 < $OLD_INIT_PATH/${entry}| read -r _ || echo >> $OLD_INIT_PATH/${entry}
				tail -c1 < $NEW_INIT_PATH/${entry}| read -r _ || echo >> $NEW_INIT_PATH/${entry}

# update the new file from the old file
				diff -e $NEW_INIT_PATH/${entry} $OLD_INIT_PATH/${entry}  | (cat && echo w) |  ed - $NEW_INIT_PATH/${entry} 
			fi
	done

# now you can update the non-backed up default files 

	for entry in ${DFLT_INIT_FILES[*]}
		do

# make a copy of the original default files in the new directory just incase

#				printf "%s\n" $NEW_INIT_PATH${entry}

				cp $NEW_INIT_PATH${entry} $NEW_INIT_PATH${entry}.DFLT

# add a new line to the end of the old file and the new file if it doesn't already exist,
# so diff doesn't complain
				tail -c1 < $OLD_INIT_PATH/${entry}| read -r _ || echo >> $OLD_INIT_PATH/${entry}
				tail -c1 < $NEW_INIT_PATH/${entry}| read -r _ || echo >> $NEW_INIT_PATH/${entry}

# update the new default file from the old file
				diff -e $NEW_INIT_PATH/${entry} $OLD_INIT_PATH/${entry}  | (cat && echo w) |  ed - $NEW_INIT_PATH/${entry}; 
			
	done

# copy any macro files from the old directory	

cp $OLD_INIT_PATH/macros/* $NEW_INIT_PATH/macros/

# find the art files in the old directory that are not the default art files and copy them to the new directory
	
	for entry in "$OLD_ART_PATH"*
		do
			if [[ ! ${DFLT_ART_FILES[*]} =~ (^|[[:space:]])${entry#${OLD_ART_PATH}}($|[[:space:]]) ]]; then
			# printf "%s\n" $OLD_ART_PATH${entry#${OLD_ART_PATH}}
			cp $OLD_ART_PATH${entry#${OLD_ART_PATH}} $NEW_ART_PATH
			fi
	done
#	printf "%s\n" ${OLD_ART_FILES[*]};







else 

# show which of the directories does not exist

	[ ! -d $NEW ] && echo $NEW does not exist;
	[ ! -d $OLD ] && echo $OLD does not exist;
	exit 1;
fi

