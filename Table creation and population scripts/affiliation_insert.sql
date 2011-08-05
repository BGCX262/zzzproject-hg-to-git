spool logs\affiliation_insert.log

delete from affiliation;

--insert senkams mapping
insert into affiliation values(affiliation_id_seq.nextval,'EMPL_GEO',1,2,'ACTV',to_date('01.01.2000','dd.mm.yyyy'),to_date('31.12.9999','dd.mm.yyyy'));
insert into affiliation values(affiliation_id_seq.nextval,'EMPL_GEO',2,4,'ACTV',to_date('01.01.2000','dd.mm.yyyy'),to_date('31.12.9999','dd.mm.yyyy'));
insert into affiliation values(affiliation_id_seq.nextval,'EMPL_GEO',3,1,'ACTV',to_date('01.01.2000','dd.mm.yyyy'),to_date('31.12.9999','dd.mm.yyyy'));
insert into affiliation values(affiliation_id_seq.nextval,'EMPL_GEO',4,3,'ACTV',to_date('01.01.2000','dd.mm.yyyy'),to_date('31.12.9999','dd.mm.yyyy'));
insert into affiliation values(affiliation_id_seq.nextval,'EMPL_GEO',27,5,'ACTV',to_date('01.01.2000','dd.mm.yyyy'),to_date('31.12.9999','dd.mm.yyyy'));


commit;

spool off;


exit;

