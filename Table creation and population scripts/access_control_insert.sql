spool logs\access_control_insert.log

delete from access_control;


insert into access_control values(access_id_seq.nextval,1,0,0,'ADMINISTRATOR','HOME_PAGE'); 
insert into access_control values(access_id_seq.nextval,1,0,0,'ADMINISTRATOR','DICTIONARY_PAGE'); 
insert into access_control values(access_id_seq.nextval,1,0,0,'ADMINISTRATOR','HOME_PAGE_REGION_PAGES'); 
insert into access_control values(access_id_seq.nextval,1,0,0,'ADMINISTRATOR','ANALYTIC_REPORTS_TAB'); 

commit;

spool off;


exit;

