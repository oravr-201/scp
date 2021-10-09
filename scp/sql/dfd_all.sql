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
PROMPT | Report   : Datafiles details   ( by www.oravr.in )                     |
PROMPT | Instance : &instance_name on &i_host_name
PROMPT +------------------------------------------------------------------------+


SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN tablespace      FORMAT a30                 HEADING 'Tablespace Name / File Class'
COLUMN filename        FORMAT a75                 HEADING 'Filename'
COLUMN filesize        FORMAT 9,999,999,999,999   HEADING 'File Size'
COLUMN autoextensible  FORMAT a4                  HEADING 'Auto'
COLUMN increment_by    FORMAT 999,999,999,999     HEADING 'Next'
COLUMN maxbytes        FORMAT 999,999,999,999     HEADING 'Max'
col pdb for a12
BREAK ON report

COMPUTE sum OF filesize  ON report

SELECT /*+ ordered */
    c.name PDB,d.tablespace_name                     tablespace
  , d.file_name                           filename
  , (d.bytes/1024/1024)                               filesize
  , d.autoextensible                      autoextensible
  , (d.increment_by * e.value)/1024/1024              increment_by
  ,(d.maxbytes/1024/1024/1024)                            maxbytes
FROM
    sys.cdb_data_files d,  v$containers c
  , v$datafile v
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
WHERE
  (d.file_name = v.name)
  and d.con_id=c.con_id
  AND upper(c.name) like upper('%&1%')
UNION
SELECT
   c.name PDB, d.tablespace_name                     tablespace 
  , d.file_name                           filename
  , (d.bytes/1024/1024)                               filesize
  , d.autoextensible                      autoextensible
  , (d.increment_by * e.value)/1024/1024           increment_by
  , (d.maxbytes/1024/1024/1024)                            maxbytes
FROM
    sys.cdb_temp_files d ,  v$containers c
  , (SELECT value
     FROM v$parameter 
     WHERE name = 'db_block_size') e
     where  d.con_id=c.con_id
     AND upper(c.name) like upper('%&1%')
UNION
SELECT
     '[ CDB$ROOT ]','[ ONLINE REDO LOG ]'
  , a.member
  , (b.bytes/1024/1024)
  , null
  , TO_NUMBER(null)
  , TO_NUMBER(null)
FROM
    v$logfile a
  , v$log b
WHERE
    a.group# = b.group#
UNION
SELECT
    '[ CDB$ROOT ]','[ CONTROL FILE    ]'
  , a.name
  , TO_NUMBER(null)
  , null
  , TO_NUMBER(null)
  , TO_NUMBER(null)
FROM
    v$controlfile a
ORDER BY 1,2,3
/


