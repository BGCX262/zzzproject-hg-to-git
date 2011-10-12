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
  access_object varchar2(255)
);

alter table access_control
add constraint pk_access_control primary key
(
 access_id
) enable;

create or replace function is_ok(p_object_name varchar2) return number
is
 l_control number;
begin
 if v('APP_USER') <> 'ADMINISTRATOR' then return 1; end if;
 select access_read into l_control from access_control where  access_user = v('APP_USER')
 and access_object = p_object_name;
 if l_control = 1 then return 1;
  else return 0;
 end if;
end;
/


spool off;


exit;

