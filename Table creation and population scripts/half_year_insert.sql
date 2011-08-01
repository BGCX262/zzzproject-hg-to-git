spool logs\half_year_insert.log

delete from half_year;
Insert into half_year (IDHY,HY,IDY) values (1,'I-2008',2);
Insert into half_year (IDHY,HY,IDY) values (2,'II-2008',2);
Insert into half_year (IDHY,HY,IDY) values (3,'I-2009',3);
Insert into half_year (IDHY,HY,IDY) values (4,'II-2009',3);
Insert into half_year (IDHY,HY,IDY) values (5,'I-2010',4);
Insert into half_year (IDHY,HY,IDY) values (6,'II-2010',4);
Insert into half_year (IDHY,HY,IDY) values (7,'I-2011',5);
Insert into half_year (IDHY,HY,IDY) values (8,'II-2011',5);
Insert into half_year (IDHY,HY,IDY) values (18,'II-2007',1);

commit;

spool off

exit;

