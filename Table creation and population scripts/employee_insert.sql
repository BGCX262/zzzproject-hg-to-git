spool logs\employee_insert.log

delete from employee;
--insert senkams

insert into employee values (1,null,'SKAM','Мельниченко',null);
insert into employee values (2,null,'SKAM','Смирнова',null);
insert into employee values (3,null,'SKAM','Серебряков',null);
insert into employee values (4,null,'SKAM','Шилиманов',null);
insert into employee values (27,null,'SKAM','Салдадзе',null);

--insert kams
insert into employee values (employee_id_seq.nextval,2,'KAM','Власенко',null);
insert into employee values (employee_id_seq.nextval,2,'KAM','Москва вакансия',null);
insert into employee values (employee_id_seq.nextval,3,'KAM','Жаркова',null);
insert into employee values (employee_id_seq.nextval,4,'KAM','Захарченко',null);
insert into employee values (employee_id_seq.nextval,3,'KAM','Юг вакансия',null);
insert into employee values (employee_id_seq.nextval,1,'KAM','Набиев',null);
insert into employee values (employee_id_seq.nextval,4,'KAM','Катаев',null);
insert into employee values (employee_id_seq.nextval,3,'KAM','Волга вакансия',null);
insert into employee values (employee_id_seq.nextval,4,'KAM','Урал вакансия',null);
insert into employee values (employee_id_seq.nextval,27,'KAM','Салдадзе (fired)',null);
insert into employee values (employee_id_seq.nextval,3,'KAM','Серебряков',null);
insert into employee values (employee_id_seq.nextval,2,'KAM','Смирнова',null);
insert into employee values (employee_id_seq.nextval,1,'KAM','Мельниченко',null);
insert into employee values (employee_id_seq.nextval,4,'KAM','Шилиманов',null);
insert into employee values (employee_id_seq.nextval,27,'KAM','Решетова',null);
insert into employee values (employee_id_seq.nextval,2,'KAM','Прядко',null);

--insert senreps
insert into employee values (17,null,'SREP', 'Ночевкина', null);
insert into employee values (18,null,'SREP', 'Лисюкова', null);

--insert reps

insert into employee values (employee_id_seq.nextval,null,'REP','Мочалова','1');
insert into employee values (employee_id_seq.nextval,17,'REP','Атаян','2');
insert into employee values (employee_id_seq.nextval,17,'REP','Борисова (fired)','2');
insert into employee values (employee_id_seq.nextval,18,'REP','Бородич','1');
insert into employee values (employee_id_seq.nextval,18,'REP','Узденова','1:2');
insert into employee values (employee_id_seq.nextval,18,'REP','Москва вакансия','1');
insert into employee values (employee_id_seq.nextval,null,'REP','Чапайкин (Горшкова)','1:2');
insert into employee values (employee_id_seq.nextval,18,'REP','Ничунаева','1');
insert into employee values (employee_id_seq.nextval,17,'REP','Сорокина','2');
insert into employee values (employee_id_seq.nextval,17,'REP','Столбовская','2');
insert into employee values (employee_id_seq.nextval,17,'REP','Халилова (Фахрутдинова)','2');
insert into employee values (employee_id_seq.nextval,17,'REP','Хамов','2');
insert into employee values (employee_id_seq.nextval,17,'REP','Хоменко','2');
insert into employee values (employee_id_seq.nextval,18,'REP','Часовских','1');
insert into employee values (employee_id_seq.nextval,18,'REP','Щербак','2');
insert into employee values (employee_id_seq.nextval,18,'REP','Стрикалова','1:2');

commit;

spool off

exit;
