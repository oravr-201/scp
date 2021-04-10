COLUMN name NEW_VALUE name NOPRINT;
select  name from v$containers where con_id=&1;
alter session set container=&name;
@login
