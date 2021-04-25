$ORACLE_HOME/bin/./sqlplus / as sysdba << EOF
alter system switch logfile;
/
alter system checkpoint;
/
exit
EOF
