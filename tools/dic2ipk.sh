#!/bin/bash
# this script packages .dic (or .dic.dz) files
# for the zbedic program on the Zaurus platform
# into .ipk (installable packages)

# ===== the filenames
INFILE=$1
EXTENSION=${INFILE#*.}
OUTFILE=`basename ${1/.$EXTENSION}`

# ===== check the syntax
if [[ "$1" == "" ]]; then
    echo "USAGE: $0 <zbedic FreeDict Dictionary>"
    exit 1
fi

# ==== is there a file-conflict
if [ -d ./home ]; then
    echo "There's already a ./home folder. Please remove that first!"
    exit 1
fi
if [ -e ./control ]; then
    echo "There's already a control file. Remove it first!"
    exit 1
fi
if [ -e ./control.tar.gz ]; then
    echo "There's already a control.tar.gz file. Remove it first!"
    exit 1
fi
if [ -e ./data.tar.gz ]; then
    echo "There's already a data.tar.gz file. Remove it first!"
    exit 1
fi

# ===== image type for the maps

# ===== make it lowercase
EXTENSION=`echo "$EXTENSION" | tr [A-Z] [a-z]`

if [[ "$EXTENSION" == "jpeg" ]]; then
    EXTENSION=jpg
fi

# ===== no converter specified?
#if [[ "`which convert`" == "" ]]; then
#    echo Cannot find the program convert!
#    exit 2
#fi
if [[ "$EXTENSION" == "" ]]; then
    echo Cannot identify the image-type or cannot find the file!
    exit 2
fi
if [ -d ./${OUTFILE} ]; then
    echo "There's already an image folder ${OUTFILE}."
    exit 2
fi


# ===== renaming files

# ===== adding overview

# ===== leaving image-folder

# ===== creating folders for ipkg

mkdir ./home
mkdir ./home/QtPalmtop
mkdir ./home/QtPalmtop/share
mkdir ./home/QtPalmtop/share/zbedic

# ===== moving the image-files into the right folder
cp ${INFILE} ./home/QtPalmtop/share/zbedic/

# ===== make a nice ipkg
DATE=$(date +"%Y%m%d")
FILE=./zbedic-${OUTFILE}_${DATE}_arm.ipk

# ===== package-information
echo -ne "Package: FreeDict-${OUTFILE}
InstalledSize: $(du -sh ./home | cut -f1)
Filename: ${FILE}
Maintainer: $(whoami)
Architecture: arm
Version: ${DATE}
Description: FreeDict ${OUTFILE} dictionary for zbedic
" > ./control

# ===== creating
tar -czf data.tar.gz ./home
tar -czf control.tar.gz ./control
tar -czf ${FILE} ./data.tar.gz ./control.tar.gz

# ===== removing temp-files
rm ./data.tar.gz ./control.tar.gz ./control

# ===== removing the NEW folders and NEW created images
rm -rf ./home
echo ${FILE}
