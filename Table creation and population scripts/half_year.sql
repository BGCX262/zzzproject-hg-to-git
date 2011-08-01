DROP SEQUENCE Half_Year_IDHY_SEQ;
CREATE SEQUENCE  Half_Year_IDHY_SEQ  
  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;
  
DROP TABLE Half_Year CASCADE CONSTRAINTS;
CREATE TABLE Half_Year (
  IDHY NUMBER(11,0) NOT NULL,
  HY VARCHAR2(255),
  IDY NUMBER(11,0)
);

COMMENT ON TABLE Half_Year IS 'ORIGINAL NAME:Half-Year'
;

ALTER TABLE Half_Year
ADD CONSTRAINT PK_Half_Year PRIMARY KEY
(
  IDHY
)
ENABLE;

exit;
