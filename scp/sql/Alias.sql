alias whoami=set serverout on exec dbms_output.put_line(sys_context('userenv', 'session_user'));

------------------------------------------------------------------------------------------------------------------------------------------------------------

alias dft=SELECT c.name                                          PDB,
       d.status                                                  status,
       d.tablespace_name                                         name,
       d.contents                                                TYPE,
       d.extent_management                                       extent_mgt,
       d.segment_space_management                                segment_mgt,
       to_char ( NVL (a.bytes / 1024 / 1024, 0)  ,   'fm9999999.90')                       ts_size,
       NVL (a.bytes - NVL (f.bytes, 0), 0) / 1024 / 1024         used,
       to_char(NVL (f.bytes / 1024 / 1024, 0)  , 'fm9999999.90')                          free,
       to_char (NVL ((a.bytes - NVL (f.bytes, 0)) / a.bytes * 100, 0), 'fm9999999.90') pct_used    ,
       c.CON_ID
  FROM sys.cdb_tablespaces  d,
       v$containers         c,
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
       AND d.con_id = c.con_id
       AND UPPER (c.name) LIKE UPPER (:1)
       AND UPPER (d.tablespace_name) LIKE UPPER (:2)
UNION ALL
SELECT c.name                                                PDB,
       d.status                                              status,
       d.tablespace_name                                     name,
       d.contents                                            TYPE,
       d.extent_management                                   extent_mgt,
       d.segment_space_management                            segment_mgt,
	          to_char(NVL (a.bytes / 1024 / 1024, 0)   , 'fm9999999.90')                     ts_size,
       -- NVL (a.bytes / 1024 / 1024, 0)                        ts_size,
       NVL (t.bytes / 1024 / 1024, 0)                        used,
       to_char(NVL (a.bytes - NVL (t.bytes / 1024 / 1024, 0), 0) , 'fm9999999.90')    free,
       to_char(NVL (t.bytes / a.bytes * 100, 0) / 1024 / 1024 , 'fm9999999.90') pct_used    ,
       c.CON_ID
  FROM sys.cdb_tablespaces  d,
       v$containers         c,
       (  SELECT tablespace_name, SUM (bytes / 1024 / 1024) bytes
            FROM cdb_temp_files
        GROUP BY tablespace_name) a,
       (  SELECT tablespace_name, SUM (bytes_cached) bytes
            FROM v$temp_extent_pool
        GROUP BY tablespace_name) t
 WHERE     d.tablespace_name = a.tablespace_name(+)
       AND d.tablespace_name = t.tablespace_name(+)
       AND d.extent_management LIKE 'LOCAL'
       AND d.contents LIKE 'TEMPORARY'
       AND d.con_id = c.con_id
       AND UPPER (c.name) LIKE UPPER (:1)
       AND UPPER (d.tablespace_name) LIKE UPPER (:2)
ORDER BY pdb, pct_used desc;


------------------------------------------------------------------------------------------------------------------------------------------------------------

alias acl_path =SELECT ANY_PATH FROM RESOURCE_VIEW WHERE ANY_PATH LIKE :1 ;
alias acl1 =SELECT c.con_id ,c.name PDB,a.host, a.lower_port, a.upper_port, a.acl FROM   cdb_network_acls a ,v$containers c where        a.con_id=c.con_id        AND upper(c.name) LIKE UPPER (:1) order by 1;
alias acl2 = SELECT c.con_id ,c.name PDB,a.acl,        a.principal,        a.privilege,        a.is_grant,        TO_CHAR(a.start_date, 'DD-MON-YYYY') AS start_date,        TO_CHAR(a.end_date, 'DD-MON-YYYY') AS end_date FROM   cdb_network_acl_privileges a,v$containers c where        a.con_id=c.con_id AND upper(c.name) LIKE UPPER (:1) 	order by 1; 

------------------------------------------------------------------------------------------------------------------------------------------------------------

alias dfc=select c.name ,a.* from ( select s.con_id ,sum(s.bytes/1024/1024/1024) "Size in GB" from cdb_segments s group by s.con_id) a ,v$containers c where a.con_id=c.con_id and upper(c.name)  LIKE UPPER (:1);

alias dfca=SELECT "RESERVED_SPACE(MB)", "RESERVED_SPACE(MB)" - "FREE_SPACE(MB)" "USED_SPACE(MB)","FREE_SPACE(MB)","DATABASE SIZE(GB)" FROM( SELECT (SELECT SUM(BYTES/(1014*1024*1024)) FROM cdb_DATA_FILES) "RESERVED_SPACE(MB)", (SELECT SUM(BYTES/(1024*1024*1024)) FROM cdb_FREE_SPACE) "FREE_SPACE(MB)", (SELECT SUM(BYTES/(1024*1024*1024)) FROM cdb_SEGMENTS) "DATABASE SIZE(GB)" FROM DUAL );






------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------













