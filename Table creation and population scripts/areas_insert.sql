spool logs\areas_insert.log

delete from areas;

Insert into Areas (IDArea,Areas) values (1,'Волга');
Insert into Areas (IDArea,Areas) values (2,'СЗ');
Insert into Areas (IDArea,Areas) values (3,'Урал + Сибирь + ДВ');
Insert into Areas (IDArea,Areas) values (4,'Москва + ЦФО');
Insert into Areas (IDArea,Areas) values (5,'Юг');

commit;

spool off;

exit;
