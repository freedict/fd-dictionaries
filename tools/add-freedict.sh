#!/bin/sh

# Shell script to configure a dictionary into place.


DICTD_CONF=/etc/dictd.conf
DICT_SCRIPT=/etc/rc.d/init.d/dict

Dict_Add_Dictionary () {
    # Add a dictionary to the DICTD_CONF file
    DICT=$*
    cat >> $DICTD_CONF <<EOF
database $DICT {                          # $DICT
     data "$PWD/$DICT.dict.dz"   # $DICT
     index "$PWD/$DICT.index"    # $DICT
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
    mv /tmp/dictd.conf.tmp $DICTD_CONF           
}



Restart_Dict_Server () {
    if [ -f $DICT_SCRIPT ] ; then
    $DICT_SCRIPT stop
    $DICT_SCRIPT start
    fi
}


#
# Program starts here
#

case "$1" in 
  '--install')
	       DICT=$2
	       Dict_Add_Dictionary $DICT
	       exit 0;
	       ;;
  '--remove')
	      DICT=$2
	      Dict_Remove_Dictionary $DICT
#              Restart_Dict_Server
	      exit 0;
	      ;;
  default)
	   echo "Usage: $0 --install <dict>"
	   echo "       $0 --remove  <dict>"
	   exit 1;
	   ;;
esac

exit 1;
