# constants
# -------------------------------------------------------------------------
GOLDENGATE_HOME=/acfs/goldengate/
ORACLE_HOME=/opt/oracle/app/orcl/product/19.3.0.1/db
# no more editting pas this point
# -------------------------------------------------------------------------
LD_LIBRARY_PATH=${ORACLE_HOME}/lib
export LD_LIBRARY_PATH

export LAG_THRESHOLD=$1

cd ${GOLDENGATE_HOME}

# start golden gate with eof and execute 'info all' and
#golden_gate_infoall=`${GOLDENGATE_HOME}/ggsci << EOF > /tmp/ggsci_status.log
#info all
#EOF`

${GOLDENGATE_HOME}/ggsci -s << EOF > /tmp/ggsci_status.log
info all
EOF

rm -rf /tmp/gghtml.lag;touch /tmp/gghtml.lag
########################################################################################################################

# ********************************************
# Monitoring Godlengate processes and lag time
# ********************************************
cat /tmp/ggsci_status.log | grep -v PPNWTW |grep -v RPTWOW| grep -v  RPTWOWLG| grep -v RPRWOW| grep -v RPRWOWLG | egrep 'MANAGER|EXTRACT|REPLICAT'| tr ":" " " | while read LINE
do
  case $LINE in
    *)
    PROCESS_TYPE=`echo $LINE | awk -F" " '{print $1}'`
    PROCESS_STATUS=`echo $LINE | awk -F" " '{print $2}'`
    if [ "$PROCESS_TYPE" == "MANAGER" ]
    then
       if [ "$PROCESS_STATUS" != "RUNNING" ]
       then
           SUBJECT="ALERT ... Goldengate process \"$PROCESS_TYPE\" is $PROCESS_STATUS on `uname -n`($ORACLE_SID)"
           mailx -s "$SUBJECT" $MAIL_LIST < $GOLDENGATE_HOME/dirrpt/MGR.rpt
           exit 1
       else
           continue
       fi
    elif [ "$PROCESS_TYPE" == "JAGENT" ]
    then
       if [ "$PROCESS_STATUS" != "RUNNING" ]
       then
           SUBJECT="WARNING ... Goldengate process \"$PROCESS_TYPE\" is $PROCESS_STATUS on `uname -n`"
           mailx -s "$SUBJECT" $MAIL_LIST < $GOLDENGATE_HOME/dirrpt/JAGENT.rpt
       fi
    else
       PROCESS_NAME=`echo $LINE | awk -F" " '{print $3}'`
       LAG_HH=`echo $LINE | awk -F" " '{print $4}'`
       LAG_MM=`echo $LINE | awk -F" " '{print $5}'`
       LAG_SS=`echo $LINE | awk -F" " '{print $6}'`
       CKPT_HH=`echo $LINE | awk -F" " '{print $7}'`
       CKPT_MM=`echo $LINE | awk -F" " '{print $8}'`
       CKPT_SS=`echo $LINE | awk -F" " '{print $9}'`

           if [ "$PROCESS_STATUS" != "RUNNING" ]
       then
          echo  ${PROCESS_TYPE} ${PROCESS_NAME} ${PROCESS_STATUS}  "${LAG_HH}:${LAG_MM}:${LAG_SS}" "${CKPT_HH}:${CKPT_MM}:${CKPT_SS}"  >> /tmp/gghtml.lag
        else
           if [ $LAG_HH -gt 00 -o $LAG_MM -ge 10 ];
           then
           echo     ${PROCESS_TYPE} ${PROCESS_NAME} ${PROCESS_STATUS}  "${LAG_HH}:${LAG_MM}:${LAG_SS}" "${CKPT_HH}:${CKPT_MM}:${CKPT_SS}"  "${LAG_HH}" "${LAG_MM}" >> /tmp/gghtml.lag
          fi
      fi
    fi
  esac
done

sh /home/goldengate/scripts/gghtml.sh > /home/goldengate/scripts/mail.html
V=`wc -l /tmp/gghtml.lag | awk -F" " '{print $1}'`
if [ $V -gt 00 ]
       then
outputFile="/home/goldengate/scripts/mail.html"
(
echo "From: noreply@oravr.in"
echo "To: info@oravr.in"
echo "MIME-Version: 1.0"
echo "Subject:  Replication lag   `date +%b-%d-%Y-%T`"
echo "Content-Type: text/html"
echo " "
echo " "
echo " "
echo " "
cat $outputFile
) | /usr/sbin/sendmail -t

else
exit 1
fi

