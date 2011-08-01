spool logs\areas_create.log

drop sequence Areas_IDArea_SEQ;
CREATE SEQUENCE  Areas_IDArea_SEQ  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

drop table areas;
CREATE TABLE Areas (
  IDArea NUMBER(11,0) NOT NULL,
  Areas VARCHAR2(255)
);

ALTER TABLE Areas
ADD CONSTRAINT PK_Areas PRIMARY KEY
(
  IDArea
)
ENABLE;

spool off;


exit;


 