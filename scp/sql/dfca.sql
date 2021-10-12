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
PROMPT | Report   : Database size details  ( by www.oravr.in )                  |
PROMPT | Instance : &instance_name on &i_host_name   
PROMPT +------------------------------------------------------------------------+

PROMPT 
PROMPT 
BREAK ON report
col name for a10
COMPUTE sum OF "Size in GB"  ON report
SELECT *
  FROM (SELECT a.*,
               a.RESERVED_SPACE_MB - b.FREE_SPACE_MB     "USED_SPACE",
               b.FREE_SPACE_MB,
               c.DATABASE_SIZE_GB
          FROM (  SELECT c.name,
                         SUM (BYTES / (1024 * 1024 * 1024))    "RESERVED_SPACE_MB"
                    FROM cdb_DATA_FILES d, v$containers c
                   WHERE d.con_id = c.con_id 
                GROUP BY c.name) a
               JOIN
               (  SELECT c.name,
                         SUM (BYTES / (1024 * 1024 * 1024))     "FREE_SPACE_MB"
                    FROM cdb_FREE_SPACE d, v$containers c
                   WHERE d.con_id = c.con_id
                GROUP BY c.name) b
                   ON (a.name = b.name)
               JOIN
               (  SELECT c.name,
                         SUM (BYTES / (1024 * 1024 * 1024))    "DATABASE_SIZE_GB"
                    FROM cdb_SEGMENTS d, v$containers c
                   WHERE d.con_id = c.con_id
                GROUP BY c.name) c
                   ON (a.name = c.name)) where  UPPER (name) LIKE UPPER ( '%&1%')