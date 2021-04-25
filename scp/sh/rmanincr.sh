###################################################
# This script Take RMAN Backup of a database.
#
# Uses : rman_full.sh $ORACLE_SID location  Compress(Y/N)
#		 rman_full.sh pink /home/oracle/bkp Y
#
###################################################

#############
# Description:
#############
echo
echo "=================================================="
echo "This script Take a RMAN FULL Backup of a database."
echo "=================================================="
echo
sleep 1

export ORACLE_SID=$1
export BKPLOC1=$2
export COMPRESSED=$3
export LEVEL=$4

echo $ORACLE_SID
echo $BKPLOC1
echo $COMPRESSED
echo $LEVEL
#############################
# Listing Available Databases:
#############################

# Count Instance Numbers:
INS_COUNT=$( ps -ef|grep pmon|grep -v grep|grep -v ASM|grep -v APX | wc -l )

# Exit if No DBs are running:
if [ $INS_COUNT -eq 0 ]
 then
   echo No Database Running !
   exit
fi

# Exit if the user selected a Non Listed Number:
        if [ -z "${ORACLE_SID}" ]
         then
          echo "You've Entered An INVALID ORACLE_SID"
          exit
        fi

###########################
# Getting ORACLE_HOME
###########################
  ORA_USER=`ps -ef|grep ${ORACLE_SID}|grep pmon|grep -v grep|grep -v ASM|awk '{print $1}'|tail -1`
  USR_ORA_HOME=`grep ${ORA_USER} /etc/passwd| cut -f6 -d ':'|tail -1`

## If OS is Linux:
if [ -f /etc/oratab ]
  then
  ORATAB=/etc/oratab
  ORACLE_HOME=`grep -v '^\#' $ORATAB | grep -v '^$'| grep -i "^${ORACLE_SID}:" | perl -lpe'$_ = reverse' | cut -f3 | perl -lpe'$_ = reverse' |cut -f2 -d':'`
  export ORACLE_HOME

## If OS is Solaris:
elif [ -f /var/opt/oracle/oratab ]
  then
  ORATAB=/var/opt/oracle/oratab
  ORACLE_HOME=`grep -v '^\#' $ORATAB | grep -v '^$'| grep -i "^${ORACLE_SID}:" | perl -lpe'$_ = reverse' | cut -f3 | perl -lpe'$_ = reverse' |cut -f2 -d':'`
  export ORACLE_HOME
fi

## If oratab is not exist, or ORACLE_SID not added to oratab, find ORACLE_HOME in user's profile:
if [ -z "${ORACLE_HOME}" ]
 then
  ORACLE_HOME=`grep -h 'ORACLE_HOME=\/' $USR_ORA_HOME/.bash* $USR_ORA_HOME/.*profile | perl -lpe'$_ = reverse' |cut -f1 -d'=' | perl -lpe'$_ = reverse'|tail -1`
  export ORACLE_HOME
fi

##########################################
# Exit if the user is not the Oracle Owner:
##########################################
CURR_USER=`whoami`
        if [ ${ORA_USER} != ${CURR_USER} ]; then
          echo ""
          echo "You're Running This Sctipt with User: \"${CURR_USER}\" !!!"
          echo "Please Run This Script With The Right OS User: \"${ORA_USER}\""
          echo "Script Terminated!"
          exit
        fi

#################################
# RMAN: Script Creation:
#################################
# Last RMAN Backup Info:
# #####################
export NLS_DATE_FORMAT='DD-Mon-YYYY HH24:MI:SS'
${ORACLE_HOME}/bin/sqlplus -s '/ as sysdba' << EOF
set linesize 157
PROMPT LAST RMAN BACKUP DETAILS:
PROMPT -------------------------

set linesize 160
set feedback off
col START_TIME for a15
col END_TIME for a15
col TIME_TAKEN_DISPLAY for a10
col INPUT_BYTES_DISPLAY heading "DATA SIZE" for a10
col OUTPUT_BYTES_DISPLAY heading "Backup Size" for a11
col OUTPUT_BYTES_PER_SEC_DISPLAY heading "Speed/s" for a10
col output_device_type heading "Device_TYPE" for a11
SELECT to_char (start_time,'DD-MON-YY HH24:MI') START_TIME, to_char(end_time,'DD-MON-YY HH24:MI') END_TIME, time_taken_display, status,
input_type, output_device_type,input_bytes_display, output_bytes_display, output_bytes_per_sec_display
FROM v\$rman_backup_job_details
WHERE end_time = (select max(end_time) from v\$rman_backup_job_details);

EOF

while [  $BKPLOC1 ]
        do
                /bin/mkdir -p ${BKPLOC1}/RMANBKP_${ORACLE_SID}/`date '+%F'`
                BKPLOC=${BKPLOC1}/RMANBKP_${ORACLE_SID}/`date '+%F'`

                if [ ! -d "${BKPLOC}" ]; then
                 echo "Provided Backup Location is NOT Exist/Writable !"
                 echo
                 echo "Please Provide a VALID Backup Location:"
                 echo "--------------------------------------"
                else
                 break
                fi
        done


while [ $COMPRESSED ]
        do
                case $COMPRESSED in
                  ""|y|Y|yes|YES|Yes) COMPRESSED=" AS COMPRESSED BACKUPSET "; echo "COMPRESSED BACKUP ENABLED.";break ;;
                  n|N|no|NO|No) COMPRESSED="";break ;;
                  *) echo "Please enter a VALID answer [Y|N]" ;;
                esac
        done


while [ $LEVEL ]
        do
                case $LEVEL in
                  ""|y|Y|yes|YES|Yes) LEVEL=" LEVEL=0 ";RMANSCRIPT=${BKPLOC}/RMAN_FULL_${ORACLE_SID}.rman;RMANLOG=${BKPLOC}/rmanlogfull.`date '+%a'`;break ;;
                   n|N|no|NO|No)      LEVEL=" LEVEL=1 ";RMANSCRIPT=${BKPLOC}/RMAN_INCR_${ORACLE_SID}.rman;RMANLOG=${BKPLOC}/rmanlogINCR.`date '+%a'`;break ;;
                  *) echo "Please enter a VALID answer [Y|N]" ;;
                esac
	done
echo "run {" > ${RMANSCRIPT}
echo "allocate channel c1 type disk;" >> ${RMANSCRIPT}
echo "allocate channel c2 type disk;" >> ${RMANSCRIPT}
echo "allocate channel c3 type disk;" >> ${RMANSCRIPT}
echo "allocate channel c4 type disk;" >> ${RMANSCRIPT}
echo "CHANGE ARCHIVELOG ALL CROSSCHECK;" >> ${RMANSCRIPT}
echo "DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;" >> ${RMANSCRIPT}
echo "BACKUP ${COMPRESSED} INCREMENTAL $LEVEL FORMAT '${BKPLOC}/%d_%t_%s_%p' TAG='FULLBKP'" >> ${RMANSCRIPT}
#echo "BACKUP ${COMPRESSED} INCREMENTAL LEVEL=0 FORMAT '${BKPLOC}/%d_%t_%s_%p' TAG='FULLBKP'" >> ${RMANSCRIPT}
echo "FILESPERSET 100 DATABASE PLUS ARCHIVELOG delete  all input;" >> ${RMANSCRIPT}
echo "BACKUP FORMAT '${BKPLOC}/%d_%t_%s_%p' TAG='CONTROL_BKP' CURRENT CONTROLFILE;" >> ${RMANSCRIPT}
echo "SQL \"ALTER DATABASE BACKUP CONTROLFILE TO TRACE AS ''$BKPLOC/controlfile.trc'' REUSE\";" >> ${RMANSCRIPT}
echo "SQL \"CREATE PFILE=''$BKPLOC/init$ORACLE_SID.ora'' FROM SPFILE\";" >> ${RMANSCRIPT}
echo "release channel c1;" >> ${RMANSCRIPT}
echo "release channel c2;" >> ${RMANSCRIPT}
echo "release channel c3;" >> ${RMANSCRIPT}
echo "release channel c4;" >> ${RMANSCRIPT}
echo "}" >> ${RMANSCRIPT}
echo "RMAN BACKUP SCRIPT CREATED."
echo
sleep 1
echo "Backup Location is: ${BKPLOC}"
echo
sleep 1
echo "Starting Up RMAN Backup Job ..."
echo
sleep 1
$ORACLE_HOME/bin/rman target / cmdfile=${RMANSCRIPT} | tee ${RMANLOG}
echo
echo "Backup Job is DONE."
echo
echo "Backup Location is: ${BKPLOC}"
echo "Check the LOGFILE: ${RMANLOG}"
echo

###############
# END OF SCRIPT
###############


