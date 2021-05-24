GOLDENGATE_HOME=/acfs/goldengate/
ORACLE_HOME=/opt/oracle/app/orcl/product/19.3.0.1/db
LD_LIBRARY_PATH=${ORACLE_HOME}/lib
export LD_LIBRARY_PATH
MAIL=info@oravr.in

rm -rf /tmp/vbstatus_1 /tmp/vbstatus_2 /tmp/vb_status.log1 tmp/vb_status.log2 /tmp/pp1 /tmp/pp2 /tmp/vb_s.log;touch /tmp/vb_s.log

${GOLDENGATE_HOME}/ggsci -s << EOF > /tmp/vb_status.log1
info all
EOF

sleep 10

${GOLDENGATE_HOME}/ggsci -s << EOF > /tmp/vb_status.log2
info all
EOF

PPL=`cat /tmp/vb_status.log1 |grep  PP |  awk -F" " '{print $3}'`
for P in $PPL
do
export PUMP=$P
${GOLDENGATE_HOME}/ggsci -s << EOF > /tmp/pp1
info $PUMP
EOF
A=`cat /tmp/pp1  | sed -n '3 p' | awk -F" " '{print $2}'`
B=`cat /tmp/pp1 | grep RBA| awk  -F" " '{print $4}'`
echo "$A --- $B" >> /tmp/vbstatus_1
done


PPL=`cat /tmp/vb_status.log2 |grep  PP |  awk -F" " '{print $3}'`
for P in $PPL
do
export PUMP=$P
${GOLDENGATE_HOME}/ggsci -s << EOF > /tmp/pp2
info $PUMP
EOF
A=`cat /tmp/pp2  | sed -n '3 p' | awk -F" " '{print $2}'`
B=`cat /tmp/pp2 | grep RBA| awk  -F" " '{print $4}'`
echo "$A --- $B" >> /tmp/vbstatus_2
done


while IFS= read -r line1 && IFS= read -r line2 <&3; do
if [[ $line1 == $line2  ]]
then
  echo $"Status ok $line1"
else
echo "$line1                   $line2" > /tmp/vb_s.log
fi
done < /tmp/vbstatus_1  3< /tmp/vbstatus_2



variable=`cat /tmp/vb_s.log | wc -l `
if [[ $variable -eq 0 ]]
then
  echo "Process not in stale"
else
        echo "$HOST  PUMP Process in Stale state " | mail -s "$HOST  PUMP Process in Stale state"   $MAIL < /tmp/vb_s.log
        
fi

