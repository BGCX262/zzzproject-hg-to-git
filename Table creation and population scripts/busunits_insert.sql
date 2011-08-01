spool logs\busunits_insert.log

delete from busunits;
Insert into BusUnits (IDBusUnit,BusUnit) values (1,'Nephro');
Insert into BusUnits (IDBusUnit,BusUnit) values (2,'Onco');

commit;

spool off;


exit;
