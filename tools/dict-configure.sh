#!/bin/sh

# Shell script to configure a dictionary into place.


DICTD_CONF=/etc/dictd.conf
DICT_SCRIPT=/etc/rc.d/init.d/dict
GDICT_CONF=/var/lib/gdict-dicts.conf

Dict_Add_Dictionary () {
    # Add a dictionary to the DICTD_CONF file
    DICT=$*
    cat >> $DICTD_CONF >> EOF
database $DICT { 
     data "/usr/lib/dict/$DICT.dict.dz"   # $DICT
     index "/usr/lib/dict/$DICT.index"    # $DICT
     access {                             # $DICT
	allow *                           # $DICT
     }                                    # $DICT
}                                         # $DICT 
EOF
    Restart_Dict_Server
}


Dict_Remove_Dictionary () {
    # Remove a dictionary from the DICTD_CONF file
    DICT=$*
    grep -v $DICT $DICTD_CONF > /tmp/dictd.conf.tmp
    mv /tmp/dictd.conf.tmp > /tmp/dictd.conf.tmp
}


Restart_Dict_Server () {
    if [ -f $DICT_SCRIPT ] ; then
    $DICT_SCRIPT stop
    $DICT_SCRIPT start
}

Gdict_Add_Dictionary () {
  DICT=$1
  LANG=$2
  cat GDICT_CONF << EOF
(define-gdict-dict "$LANG" "$DICT") ; installed by dict-$LANG
EOF
}

Gdict_Remove_Dictionary () {
  LANG=$1
grep -v "dict-$DICT" $GDICT_CONF > /tmp/gdict-dicts.conf
mv /tmp/gdict-dicts.conf $GDICT_CONF
}

#
# Program starts here
#

case "$1" in 
  '--install')
	       DICT=$2
	       LANG=$4
	       Dict_Add_Dictionary $DICT
	       GDict_Add_Dictionary $DICT $LANG
	       exit 0;
	       ;;
  '--remove')
	      DICT=$2
	      Dict_Remove_Dictionary $DICT
	      Gdict_Remove_Dictionary $DICT
	      exit 0;
	      ;;
  default)
	   echo "Usage: $0 --install <dict> --lang <langcode>, or"
	   echo "       $0 --remove  <dict>"
	   exit 1;
	   ;;
esac

exit 1;