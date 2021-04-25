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
       AND tablespace_name='CLAIM_INDEX' -- << change the tablespace name to reclaim the datafile size
)   
WHERE  High_Water_Mark <> current_size_in_GB;
