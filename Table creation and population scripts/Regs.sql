spool logs\regs_create.log


DROP SEQUENCE Regs_IDReg_SEQ;
CREATE SEQUENCE  Regs_IDReg_SEQ  
  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  

DROP TABLE Regs CASCADE CONSTRAINTS;

CREATE TABLE Regs (
  IDReg NUMBER(11,0) NOT NULL,
  Reg VARCHAR2(255),
  Cap VARCHAR2(255),
  SubArea VARCHAR2(255),
  IDArea FLOAT DEFAULT 0
);

ALTER TABLE Regs
ADD CONSTRAINT PK_Regs PRIMARY KEY
(
  IDReg
)
ENABLE
;

CREATE INDEX RegsIDArea ON Regs
(
  IDArea
) 
;

spool off

exit;

