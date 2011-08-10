spool logs\create_user.log

drop user mdb_rep cascade;
create user mdb_rep identified by mdb default tablespace users temporary tablespace temp quota unlimited on users;
grant resource to mdb_rep;
grant create session to mdb_rep;
grant create view to mdb_rep;
grant create public synonym to mdb_rep;
grant create trigger to mdb_rep;
grant create table to mdb_rep;
grant create sequence to mdb_rep;

spool off


exit;
