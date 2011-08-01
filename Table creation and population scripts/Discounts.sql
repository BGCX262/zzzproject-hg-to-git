spool logs\discount_create.log


DROP SEQUENCE Discounts_Код_SEQ;
CREATE SEQUENCE  Discounts_Код_SEQ  
  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

DROP TABLE Discounts CASCADE CONSTRAINTS;

CREATE TABLE Discounts (
  CODE NUMBER(11,0) NOT NULL,
  IDWS NUMBER(11,0),
  IDProdGr NUMBER(11,0),
  Disc FLOAT,
  IDMonth CLOB
);

ALTER TABLE Discounts
ADD CONSTRAINT PK_Discounts PRIMARY KEY
(
  Code
)
ENABLE
;

spool off

exit;

