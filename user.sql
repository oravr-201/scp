SET TERMOUT OFF;
COLUMN instance_name NEW_VALUE instance_name NOPRINT;
COLUMN i_host_name NEW_VALUE i_host_name NOPRINT;
select
        s.username                      i_username,
--  i.instance_name i_instance_name,
  (CASE WHEN TO_NUMBER(SUBSTR(i.version, 1, instr(i.version,'.',1)-1)) >= 12 THEN (SELECT SYS_CONTEXT('userenv', 'con_name') FROM dual)||'-'||i.instance_name ELSE i.instance_name END) instance_name,
        i.host_name                     i_host_name
  from
        v$session s,
        v$instance i;
SET TERMOUT ON;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : user  details                                          |
PROMPT | Instance : &instance_name on &i_host_name
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    280
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
col pdb for a10
col username for a25
COLUMN ACCOUNT_STATUS    FORMAT a18   HEADING 'STATUS'
COLUMN LOCK_DATE    FORMAT a16   HEADING 'LOCK_DATE'
COLUMN DEFAULT_TABLESPACE    FORMAT a10   HEADING 'DT'
COLUMN TEMPORARY_TABLESPACE    FORMAT a10   HEADING 'TT'
COLUMN LOCAL_TEMP_TABLESPACE    FORMAT a10   HEADING 'LTT'
COLUMN PROFILE    FORMAT a20   HEADING 'PROFILE'
COLUMN COMMON    FORMAT a3   HEADING 'C'
COLUMN PASSWORD_CHANGE_DATE    FORMAT a16   HEADING 'PCD'

  SELECT u.CON_ID,
         c.name PDB,
         u.USERNAME,
         u.ACCOUNT_STATUS,
         u.PROFILE,
        -- TO_CHAR (CREATED, 'YYYYMMDD_HHMISS') CREATED,
	u.created,
         u.DEFAULT_TABLESPACE,
         u.TEMPORARY_TABLESPACE,
         u.LOCAL_TEMP_TABLESPACE,
         TO_CHAR (LOCK_DATE, 'YYYYMMDD_HHMISS') LOCK_DATE,
         TO_CHAR (EXPIRY_DATE, 'YYYYMMDD_HHMISS') EXPIRY_DATE,
         u.COMMON,
         TO_CHAR (LAST_LOGIN, 'YYYYMMDD_HHMISS') LAST_LOGIN,
          u.USER_ID
    --to_char(PASSWORD_CHANGE_DATE, 'YYYYMMDD HHMISS') PASSWORD_CHANGE_DATE
    FROM cdb_users u, v$containers c
   WHERE u.con_id = c.con_id AND UPPER (c.name) LIKE UPPER ('%&1%')
ORDER BY 1,
         2,
         3,
         4;
