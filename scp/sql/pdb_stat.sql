/* Formatted on 4/25/21 12:09:00 PM (QP5 v5.326) */

prompt 

--@@init.sql
--@@i.sql
set feedback off LINESIZE 500  PAGESIZE 1000 SERVEROUT ON LONG 2000000; 
COLUMN NAME FORMAT A15
COLUMN "Database Uptime" FORMAT A30
COLUMN OPEN_TIME FORMAT A35
COLUMN CREATION_TIME FORMAT A25
COLUMN version FORMAT A10

SELECT c.con_id,
       c.dbid,
       c.name,
       c.open_mode,
       c.RESTRICTED,
       TO_CHAR(c.creation_time, 'DD-MON-YYYY HH24:MI:SS') AS creation_time,
       c.open_time,
          FLOOR (SYSDATE - CAST (c.open_time AS DATE))
       || ' Days '
       || FLOOR (
                (  (SYSDATE - CAST (c.open_time AS DATE))
                 - FLOOR (SYSDATE - CAST (c.open_time AS DATE)))
              * 24)
       || 'hours '
       || ROUND (
                (  (  SYSDATE
                    - CAST (c.open_time AS DATE)
                    - FLOOR (SYSDATE - CAST (c.open_time AS DATE)) * 24)
                 - FLOOR (
                       (  SYSDATE
                        - CAST (c.open_time AS DATE)
                        - FLOOR (SYSDATE - CAST (c.open_time AS DATE)) * 24)))
              * 60)
       || ' minutes'
           "Database Uptime",
       c.TOTAL_SIZE / 1024 / 1024 / 1024
           "Size_GB"
  FROM v$containers c;

prompt 

