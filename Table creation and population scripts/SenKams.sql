DROP SEQUENCE SenKAMs_IDSenKAM_SEQ;
CREATE SEQUENCE  SenKAMs_IDSenKAM_SEQ  
  MINVALUE 30 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE SenKAMs CASCADE CONSTRAINTS;

CREATE TABLE SenKAMs (
  IDSenKAM NUMBER(11,0) NOT NULL,
  SenKAM VARCHAR2(255),
  IDArea NUMBER(11,0)
);

ALTER TABLE SenKAMs
ADD CONSTRAINT PK_SenKAMs PRIMARY KEY
(
  IDSenKAM
)
ENABLE
;

CREATE INDEX SenKAMsSenKAM ON SenKAMs
(
  SenKAM
) 
;

exit;