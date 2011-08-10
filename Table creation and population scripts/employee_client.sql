spool logs\employee_client_create.log

drop sequence employee_client_id_seq;
CREATE SEQUENCE  employee_client_id_seq  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

drop table employee_client;
create table employee_client
(
  employee_client_id number,
  idhy number,
  employee_id number,
  client_id number,
  link_type varchar2(1024) default 'EXPL',
  plan_pct number default 1
);

alter table employee_client
add constraint pk_employee_client primary key
(
  employee_client_id
) enable;

alter table employee_client
add constraint fk_employee_link foreign key (employee_id) references employee(employee_id) on delete cascade;

alter table employee_client
add constraint fk_client_link foreign key (client_id) references clients(idclient) on delete cascade;


spool off;


exit;

