spool logs\access_control_create.log

drop sequence access_id_seq;
CREATE SEQUENCE  access_id_seq  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

drop table access_control;
create table access_control
(
  access_id number,
  access_read number,
  access_write number,
  access_execute number,
  access_user varchar2(255),
  access_page number,
  access_element varchar2(255) default null
);

alter table access_control
add constraint pk_access_control primary key
(
 access_id
) enable;


spool off;


exit;

