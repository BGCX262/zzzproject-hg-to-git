spool logs\pricelist_create.log

drop sequence Pricelist_ID_SEQ;
CREATE SEQUENCE  Pricelist_ID_SEQ  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

drop table pricelist;
CREATE TABLE pricelist (
  idpricelist NUMBER(11,0) NOT NULL,
  idproduct number,
  iddistributor number,
  real_date_type varchar2(100),
  real_date	date,
  cip_rur	number,
  cip_usd number,
  net_rur number,
  net_usd number
);

ALTER TABLE pricelist
ADD CONSTRAINT PK_Pricelist PRIMARY KEY
(
  idpricelist
)
ENABLE;

spool off;


exit;


 