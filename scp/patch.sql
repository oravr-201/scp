####################################################
# This script show the patch details from 11g to 19c
# Created by www.oravr.in
# git : https://github.com/oravr-201/scp.git
# Mail : info@oravr.in
# Call : +91 9762158929
#
###################################################

echo ""
echo ""
echo -e "                                                     \e[32m!!-----Welcome to OraVR (www.oravr.in)------!!\e[0m"
echo ""

VAL3=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" <<EOF
set pages 0 feedback off;
prompt
Select  substr(substr(banner, instr(banner, 'Release ')+8),1, instr(substr(banner, instr(banner, 'Release ')+8),'.')-1) my from v\$version;
exit;
EOF
)

if [ $VAL3 == 11 ]
then
${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" <<EOF
set pages 0 feedback off;
prompt
@login.sql
SELECT * FROM sys.registry\$history order by action_time DESC;
exit;
EOF
elif [ $VAL3 == 12 ]
then

${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" <<EOF > /tmp/patch.log
prompt
@@init.sql
@@i.sql

set feedback off LINESIZE 500  PAGESIZE 1000 SERVEROUT ON LONG 2000000;
COLUMN action_time FORMAT A12
COLUMN action FORMAT A10
COLUMN bundle_series FORMAT A4
COLUMN comments FORMAT A30
COLUMN description FORMAT A60
COLUMN namespace FORMAT A20
COLUMN status FORMAT A10
COLUMN version FORMAT A10
SELECT TO_CHAR(action_time, 'YYYY-MM-DD') AS action_time, action, status, description, version, patch_id, bundle_series FROM   sys.dba_registry_sqlpatch ORDER by action_time;
exit;
EOF

elif [ $VAL3 == 18 ]
then
${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" <<EOF > /tmp/patch.log
prompt
@@init.sql
@@i.sql


set feedback off LINESIZE 500  PAGESIZE 1000 SERVEROUT ON LONG 2000000;
COLUMN action_time FORMAT A20
COLUMN action FORMAT A10
COLUMN status FORMAT A10
COLUMN description FORMAT A90
COLUMN source_version FORMAT A10
COLUMN target_version FORMAT A10


alter session set "_exclude_seed_cdb_view"=FALSE;
select CON_ID,TO_CHAR(action_time, 'YYYY-MM-DD') AS action_time,PATCH_ID,PATCH_TYPE,ACTION,DESCRIPTION,SOURCE_VERSION,TARGET_VERSION   from CDB_REGISTRY_SQLPATCH  order by CON_ID, action_time, patch_id;
exit;
EOF
elif [ $VAL3 == 19 ]
then
${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" <<EOF > /tmp/patch.log
prompt
@@init.sql
@@i.sql


set feedback off LINESIZE 500  PAGESIZE 1000 SERVEROUT ON LONG 2000000;
COLUMN action_time FORMAT A20
COLUMN action FORMAT A10
COLUMN status FORMAT A10
COLUMN description FORMAT A90
COLUMN source_version FORMAT A10
COLUMN target_version FORMAT A10


alter session set "_exclude_seed_cdb_view"=FALSE;
select CON_ID,TO_CHAR(action_time, 'YYYY-MM-DD') AS action_time,PATCH_ID,PATCH_TYPE,ACTION,DESCRIPTION,SOURCE_VERSION,TARGET_VERSION   from CDB_REGISTRY_SQLPATCH  order by CON_ID, action_time, patch_id;
exit;
EOF

 else
    echo "Invalid version"
    fi

    cat /tmp/patch.log
    echo ""
    echo ""
    echo -e "                                                     \e[32m!!--------------- Thank you ----------------!!\e[0m"
    echo ""

