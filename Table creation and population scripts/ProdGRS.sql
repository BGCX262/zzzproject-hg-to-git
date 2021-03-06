spool logs\prodgrs_create.log

DROP SEQUENCE ProdGrs_IDProdGr_SEQ;
CREATE SEQUENCE  ProdGrs_IDProdGr_SEQ  
  MINVALUE 10 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE ProdGrs CASCADE CONSTRAINTS;

CREATE TABLE ProdGrs (
  IDProdGr NUMBER(11,0) NOT NULL,
  ProdGr VARCHAR2(255 CHAR),
  IDBusUnit FLOAT DEFAULT 0
);

ALTER TABLE ProdGrs
ADD CONSTRAINT PK_ProdGrs PRIMARY KEY
(
  IDProdGr
)
ENABLE
;

CREATE INDEX ProdGrsIDBusUnit ON ProdGrs
(
  IDBusUnit
) 
;
spool off

exit;
