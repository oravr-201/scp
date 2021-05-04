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
PROMPT | Report   : Acl Detail By www.oravr.in                                  |
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


col ANY_PATH for a100
col host for a20
col acl for a60
col PRINCIPAL for a30
col privilege for a10
COLUMN PDB         FORMAT a10

SELECT ANY_PATH
FROM RESOURCE_VIEW
--WHERE ANY_PATH LIKE '/sys/acls/dba%'
;

PROMPT
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Acl Detail By www.oravr.in                                  |
PROMPT | Instance : &instance_name on &i_host_name
PROMPT +------------------------------------------------------------------------+


SELECT c.con_id ,c.name PDB,a.host, a.lower_port, a.upper_port, a.acl
FROM   cdb_network_acls a ,v$containers c
where 
       a.con_id=c.con_id
       AND upper(c.name) like upper('%&1%') order by 1;



SELECT c.con_id ,c.name PDB,a.acl,
       a.principal,
       a.privilege,
       a.is_grant,
       TO_CHAR(a.start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(a.end_date, 'DD-MON-YYYY') AS end_date
FROM   cdb_network_acl_privileges a,v$containers c
where 
       a.con_id=c.con_id
       AND upper(c.name) like upper('%&1%')
	order by 1;


