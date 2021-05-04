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
select c.name ,a.* from ( select s.con_id ,sum(s.bytes/1024/1024/1024) "Size in GB" from 
cdb_segments s group by s.con_id) a ,v$containers c where a.con_id=c.con_id and upper(c.name) like upper('%&1%');

