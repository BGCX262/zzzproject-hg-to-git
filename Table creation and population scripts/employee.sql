spool logs\employee_create.log

drop sequence employee_id_seq;
CREATE SEQUENCE  employee_id_seq  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

drop table employee;
create table employee
(
  employee_id number,
  employee_parent number,
  employee_type varchar2(100),
  employee_name varchar2(1024),
  employee_bu varchar2(100)
);

alter table employee
add constraint pk_employee primary key
(
  employee_id
) enable;

alter table employee
add constraint fk_employee foreign key (employee_parent) references employee(employee_id) on delete cascade;

create or replace view all_employees as
select * from employee where employee_type <> 'TEAM';
/


spool off;


exit;

