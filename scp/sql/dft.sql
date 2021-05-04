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
PROMPT | Report   : Tablespace details  ( by www.oravr.in )                     |
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

COLUMN status      FORMAT a9                 HEADING 'Status'
COLUMN name        FORMAT a30                HEADING 'Tablespace Name'
COLUMN type        FORMAT a15                HEADING 'TS Type'
COLUMN extent_mgt  FORMAT a10                HEADING 'Ext. Mgt.'
COLUMN segment_mgt FORMAT a10                HEADING 'Seg. Mgt.'
COLUMN ts_size     FORMAT 9,999,999,999,999  HEADING 'Tablespace Size'
COLUMN used        FORMAT 9,999,999,999,999  HEADING 'Used (in MB)'
COLUMN free        FORMAT 9,999,999,999,999  HEADING 'Free (in MB)'
COLUMN pct_used    FORMAT 999                HEADING 'Pct. Used'
COLUMN PDB         FORMAT a10        

BREAK ON report

COMPUTE sum OF ts_size  ON report
COMPUTE sum OF used     ON report
COMPUTE sum OF free     ON report
COMPUTE avg OF pct_used ON report

/* Formatted on 3/29/2021 4:11:08 PM (QP5 v5.267.14150.38599) */
SELECT c.name PDB,d.status status,
       d.tablespace_name name,
       d.contents TYPE,
       d.extent_management extent_mgt,
       d.segment_space_management segment_mgt,
       NVL (a.bytes/1024/1024, 0) ts_size,
       NVL (a.bytes - NVL (f.bytes, 0), 0)/1024/1024 used-- , NVL(f.bytes, 0)                                     free
       ,
       NVL ( (a.bytes - NVL (f.bytes, 0)) / a.bytes * 100, 0) pct_used
       ,c.CON_ID
  FROM sys.cdb_tablespaces d,  v$containers c,
       (  SELECT tablespace_name, SUM (bytes) bytes
            FROM cdb_data_files
        GROUP BY tablespace_name) a,
       (  SELECT tablespace_name, SUM (bytes) bytes
            FROM dba_free_space
        GROUP BY tablespace_name) f
 WHERE     d.tablespace_name = a.tablespace_name(+)
       AND d.tablespace_name = f.tablespace_name(+)
       AND NOT (    d.extent_management LIKE 'LOCAL'
                AND d.contents LIKE 'TEMPORARY')
                and d.con_id=c.con_id 
       AND upper(c.name) like upper('%&1%')
UNION ALL
SELECT c.name PDB,d.status status,
       d.tablespace_name name,
       d.contents TYPE,
       d.extent_management extent_mgt,
       d.segment_space_management segment_mgt,
       NVL (a.bytes/1024/1024, 0) ts_size,
       NVL (t.bytes/1024/1024, 0) used-- , NVL(a.bytes - NVL(t.bytes,0), 0) free
       ,
       NVL (t.bytes / a.bytes * 100, 0)/1024/1024 pct_used
       ,c.CON_ID
  FROM sys.cdb_tablespaces d, v$containers c,
       (  SELECT tablespace_name, SUM (bytes) bytes
            FROM cdb_temp_files
        GROUP BY tablespace_name) a,
       (  SELECT tablespace_name, SUM (bytes_cached) bytes
            FROM v$temp_extent_pool
        GROUP BY tablespace_name) t
 WHERE     d.tablespace_name = a.tablespace_name(+)
       AND d.tablespace_name = t.tablespace_name(+)
       AND d.extent_management LIKE 'LOCAL'
       AND d.contents LIKE 'TEMPORARY'
       and d.con_id=c.con_id
       AND upper(c.name) like upper('%&1%')
ORDER BY 10
/

