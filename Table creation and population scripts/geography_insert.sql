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
insert into geography values (geography_id_seq.nextval,2,'SUBAREA',	'Северо-западный');
insert into geography values (geography_id_seq.nextval,3,'SUBAREA',	'Уральский');
insert into geography values (geography_id_seq.nextval,3,'SUBAREA',	'Сибирский');
insert into geography values (geography_id_seq.nextval,3,'SUBAREA',	'Дальневосточный');
insert into geography values (geography_id_seq.nextval,3,'SUBAREA',	'Приволжский');

--insert regions



commit;

spool off

exit;
