spool logs\access_control_insert.log

delete from access_control;


insert into access_control values(access_id_seq.nextval,1,0,0,'ADMINISTRATOR',1,null); --Home Page
insert into access_control values(access_id_seq.nextval,1,0,0,'ADMINISTRATOR',7,null); --Home Page

commit;

spool off;


exit;

