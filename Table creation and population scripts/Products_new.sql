spool logs\products_new_create.log


DROP SEQUENCE Productsn_IDProd_SEQ;
CREATE SEQUENCE  Productsn_IDProd_SEQ  
  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE Products_new CASCADE CONSTRAINTS;

CREATE TABLE Products_new (
  IDProd NUMBER NOT NULL,
  Prod VARCHAR2(255),
  IDProdGr NUMBER DEFAULT 0,
  Comments VARCHAR2(255)
);

ALTER TABLE Products_new
ADD CONSTRAINT PK_Products_new PRIMARY KEY
(
  IDProd
)
ENABLE
;

CREATE INDEX ProductsIDProdGrN ON Products_new
(
  IDProdGr
) 
;

spool off


exit;
