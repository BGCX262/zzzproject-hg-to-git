spool logs\employee_insert.log

delete from employee;
insert into employee values(1, null, 'KAM', 'Иванов', '1');
insert into employee values(2, null, 'KAM', 'Сидоров', '1');
insert into employee values(3, 1, 'REP', 'Петров', '1');

commit;

spool off

exit;
