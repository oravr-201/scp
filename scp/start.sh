

$ORACLE_HOME/bin/./lsnrctl start 
$ORACLE_HOME/bin/./sqlplus / as sysdba << EOF
startup;
alter pluggable database all open;
exit;
EOF
