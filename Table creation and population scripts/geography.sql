spool logs\geography_create.log

drop sequence geography_id_seq;
CREATE SEQUENCE  geography_id_seq  MINVALUE 100 MAXVALUE 999999999999999999999999 INCREMENT BY 1  NOCYCLE ;

drop table geography;
create table geography
(
  geography_id number,
  geography_parent number,
  geography_type varchar2(100),
  geography_name varchar2(1024)--,
 -- geography_capital varchar2(1024)
);

alter table geography
add constraint pk_geography primary key
(
  geography_id
) enable;

alter table geography
add constraint fk_geography foreign key (geography_parent) references geography(geography_id) on delete cascade;

spool off;


exit;

