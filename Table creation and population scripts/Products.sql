spool logs\products_create.log


DROP SEQUENCE Products_IDProd_SEQ;
CREATE SEQUENCE  Products_IDProd_SEQ  
  MINVALUE 60000000 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE Products CASCADE CONSTRAINTS;

CREATE TABLE Products (
  IDProd NUMBER(11,0) NOT NULL,
  Prod VARCHAR2(255 CHAR),
  IDProdGr FLOAT DEFAULT 0,
  PriceCIP NUMBER(15,4) DEFAULT 0,
  PriceNet NUMBER(15,4) DEFAULT 0,
  StartDate DATE,
  EndDate DATE,
  Remarks VARCHAR2(255 CHAR)
);

ALTER TABLE Products
ADD CONSTRAINT PK_Products PRIMARY KEY
(
  IDProd
)
ENABLE
;

CREATE INDEX ProductsIDProdGr ON Products
(
  IDProdGr
) 
;

spool off


exit;
