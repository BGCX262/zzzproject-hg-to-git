spool logs\prodgrs_insert.log

delete from  ProdGrs;

Insert into ProdGrs (IDProdGr,ProdGr,IDBusUnit) values (1,'AN',1.0);
Insert into ProdGrs (IDProdGr,ProdGr,IDBusUnit) values (2,'AO',2.0);
Insert into ProdGrs (IDProdGr,ProdGr,IDBusUnit) values (3,'Mi',1.0);
Insert into ProdGrs (IDProdGr,ProdGr,IDBusUnit) values (4,'Npl',2.0);
Insert into ProdGrs (IDProdGr,ProdGr,IDBusUnit) values (5,'Vbx',2.0);

commit;

spool off

exit;

