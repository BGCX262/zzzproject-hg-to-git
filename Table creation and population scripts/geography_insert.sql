spool logs\geography_insert.log

delete from geography;
--insert areas

insert into geography values (1,null,'AREA','Волга');
insert into geography values (2,null,'AREA','СЗ');
insert into geography values (3,null,'AREA','Урал + Сибирь + ДВ');
insert into geography values (4,null,'AREA','Москва + ЦФО');
insert into geography values (5,null,'AREA','Юг');

--insert subareas
insert into geography values (geography_id_seq.nextval,1,'SUBAREA',	'Приволжский');
insert into geography values (geography_id_seq.nextval,1,'SUBAREA',	'Южный');
insert into geography values (geography_id_seq.nextval,2,'SUBAREA',	'Северо-Западный');
insert into geography values (geography_id_seq.nextval,3,'SUBAREA',	'Уральский');
insert into geography values (geography_id_seq.nextval,3,'SUBAREA',	'Сибирский');
insert into geography values (geography_id_seq.nextval,3,'SUBAREA',	'Дальневосточный');
insert into geography values (geography_id_seq.nextval,3,'SUBAREA',	'Приволжский');
insert into geography values (geography_id_seq.nextval,4,'SUBAREA',	'Центральный');
insert into geography values (geography_id_seq.nextval,5,'SUBAREA',	'Южный');
insert into geography values (geography_id_seq.nextval,5,'SUBAREA',	'Северо-Кавказский');

--insert regions
--fix the bug(duplicate) with chechenskaya resp
delete from regs where idreg = 80;

begin
for i in (
select 'insert into geography values (geography_id_seq.nextval,' || (select geography_id from geography where geography_name = subarea and geography_parent = idarea) || ',''REGION'',' ||''''|| reg ||''')' as str 
from regs) loop

execute immediate i.str;

end loop;
commit;
end;
/


--insert cities
begin
for i in (
select 'insert into geography values (geography_id_seq.nextval,' || (select geography_id from geography where geography_name = reg) || ',''CITY'',' ||''''|| cap ||''')' as str
from regs) loop

execute immediate i.str;

end loop;
commit;
end;
/



commit;

spool off

exit;
