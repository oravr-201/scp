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
PROMPT | Report   : Tablespace shrink  i  by www.oravr.in )                     |
PROMPT | Instance : &instance_name on &i_host_name
PROMPT +------------------------------------------------------------------------+



SET LINES 32000
SET PAGES 200
COL SCRIPT_RECLAIM FOR A100
COL FILE_NAME FOR A60
COL TABLESPACE_NAME FOR A15



SELECT File_ID, Tablespace_name, file_name, High_Water_Mark, current_size_in_GB,
    'ALTER DATABASE DATAFILE '''||file_name||''' resize '|| High_Water_Mark|| 'M;' script_reclaim
FROM
(
    WITH v_file_info
         AS (SELECT FILE_NAME, FILE_ID, BLOCK_SIZE
               FROM dba_tablespaces tbs, dba_data_files df
              WHERE tbs.tablespace_name = df.tablespace_name)
    SELECT A.FILE_ID,
           A.FILE_NAME,
           A.TABLESPACE_NAME,
           CEIL ( (NVL (hwm, 1) * v_file_info.block_size) / 1024 / 1024) High_Water_Mark,
           CEIL (BLOCKS * v_file_info.block_size / 1024 / 1024 /2014) current_size_in_GB
      FROM dba_data_files A,
           v_file_info,
           (  SELECT file_id, MAX (block_id + BLOCKS - 1) hwm
                FROM dba_extents
            GROUP BY file_id) b
     WHERE A.file_id = b.file_id(+)
       AND A.file_id = v_file_info.file_id
       AND UPPER (TABLESPACE_NAME) LIKE UPPER ('%&1%') -- << change the tablespace name to reclaim the datafile size
)   
WHERE  High_Water_Mark <> current_size_in_GB;
