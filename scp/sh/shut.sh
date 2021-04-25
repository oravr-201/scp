

$ORACLE_HOME/bin/./lsnrctl stop 
$ORACLE_HOME/bin/./sqlplus / as sysdba << EOF
shut immediate;
exit;
EOF
