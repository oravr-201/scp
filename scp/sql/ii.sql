
prompt
prompt


set sqlprompt "&_i_inst@&_user> "
set termout on
set termout on
COLUMN id_plus_exp FORMAT 990 HEADING i
COLUMN parent_id_plus_exp FORMAT 990 HEADING p
COLUMN plan_plus_exp FORMAT a60
COLUMN object_node_plus_exp FORMAT a8
COLUMN other_tag_plus_exp FORMAT a29
COLUMN other_plus_exp FORMAT a44
col HOSTNAME for a35
col BLOCKED for a7
col STARTUP_TIME for a19
select I.STATUS,I.DATABASE_STATUS DB_STATUS,D.open_mode,d.protection_mode,D.database_role,I.LOGINS,D.FLASHBACK_ON,d.log_mode,
to_char(I.STARTUP_TIME,'DD-MON-YY HH24:MI:SS') STARTUP_TIME from gv$instance I,v$database D ;

@pdb_stat.sql

