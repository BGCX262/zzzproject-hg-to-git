spool logs\wss_insert.log

delete from  WSs;
Insert into WSs (IDWS,WS) values (1,'ЗАО "Фирма Евросервис"');
Insert into WSs (IDWS,WS) values (2,'ЗАО "Империя-Фарма"');
Insert into WSs (IDWS,WS) values (3,'ЗАО "Р-Фарм"');
Insert into WSs (IDWS,WS) values (4,'ОАО "Фармимэкс"');

commit;
spool off

exit;
