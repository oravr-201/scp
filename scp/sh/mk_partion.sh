#----------------------------Start Mk_partion.sh-------------------------------------

#-- +----------------------------------------------------------------------------+
#-- |                      	     By OraVR             	                	|
#-- |                  	      info@oravr.in         	                	|
#-- |                              www.oravr.in                             	|
#-- |----------------------------------------------------------------------------|
#-- |                                                                        	|
#-- |----------------------------------------------------------------------------|
#-- | DATABASE : Oracle                                                      	|
#-- | FILE 	: Mk_partion.sh                                               	|
#-- | CLASS	: Storage                                                     	|
#-- | PURPOSE  : Create Multiple logical disk                                	|
#-- | NOTE 	: As with any code, ensure to test this script in a development   |
#-- |        	environment before attempting to run it in production.      	|
#-- +----------------------------------------------------------------------------+
#!/bin/bash
if [ $# -eq 0 ]
then
  echo "input the device"
  exit
fi
NUM_PARTITIONS=50
PARTITION_SIZE="+4096M"   
PARTITION_SIZE_P="+100M"
SED_STRING="o"
TAIL="p
w
q
"
NEW_LINE="
"
LETTER_n="n"
EXTENDED_PART_NUM=4
TGTDEV=$1
SED_STRING="$SED_STRING$NEW_LINE"
for i in $(seq $NUM_PARTITIONS)
do
  if [ $i -lt $EXTENDED_PART_NUM ]
  then
	SED_STRING="$SED_STRING$LETTER_n$NEW_LINE$NEW_LINE$NEW_LINE$NEW_LINE$PARTITION_SIZE_P$NEW_LINE"
  fi
  if [ $i -eq $EXTENDED_PART_NUM ]
  then
	SED_STRING="$SED_STRING$LETTER_n$NEW_LINE$NEW_LINE$NEW_LINE$NEW_LINE"
	SED_STRING="$SED_STRING$LETTER_n$NEW_LINE$NEW_LINE$PARTITION_SIZE$NEW_LINE"
  fi
  if [ $i -gt $EXTENDED_PART_NUM ]
  then
	SED_STRING="$SED_STRING$LETTER_n$NEW_LINE$NEW_LINE$PARTITION_SIZE$NEW_LINE"
  fi
done
SED_STRING="$SED_STRING$TAIL"
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
  $SED_STRING
EOF
########## Remove PARTITION if anything goes wrong #########################################
######dd if=/dev/zero of=/dev/sda bs=512 count=1 conv=notrunc######

#---------------------------- End  Mk_partion.sh-------------------------------------
