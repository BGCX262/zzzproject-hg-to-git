spool logs\years_create.log

delete from Years;

Insert into Years (IDY,Y) values (1,2007);
Insert into Years (IDY,Y) values (2,2008);
Insert into Years (IDY,Y) values (3,2009);
Insert into Years (IDY,Y) values (4,2010);
Insert into Years (IDY,Y) values (5,2011);

commit;
spool off
exit;

