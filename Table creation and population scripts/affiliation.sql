spool logs\affiliation_create.log

drop sequence affiliation_id_seq;
CREATE SEQUENCE  affiliation_id_seq  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

drop table affiliation;
create table affiliation
(
  affiliation_id number,
  affiliation_type varchar2(255),
  from_id number,
  to_id number,
  status varchar2(255),
  from_date date,
  to_date date default to_date('31.12.9999','dd.mm.yyyy')
);

alter table affiliation
add constraint pk_affiliation primary key
(
 affiliation_id
) enable;


spool off;


exit;

