spool logs\products_new_insert.log

delete from Products_new;

insert into products_new
select 
productsn_idprod_seq.nextval,
prod,
idprodgr,
null as comments
from (
select distinct prod, idprodgr from products
);

commit;

spool off

exit;
