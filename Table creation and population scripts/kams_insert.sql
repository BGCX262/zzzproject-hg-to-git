spool logs\kams_insert.log

delete from kams;

Insert into KAMs (IDKAM,KAM,IDSenKAM) values (1,'Власенко',2.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (2,'Москва вакансия',2.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (3,'Жаркова',3.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (4,'Захарченко',4.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (5,'Юг вакансия',3.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (6,'Набиев',1.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (7,'Катаев',4.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (8,'Волга вакансия',3.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (9,'Урал вакансия',4.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (10,'Салдадзе (fired)',27.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (11,'Серебряков',3.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (12,'Смирнова',2.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (13,'Мельниченко',1.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (15,'Шилиманов',4.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (17,'Решетова',27.0);
Insert into KAMs (IDKAM,KAM,IDSenKAM) values (18,'Прядко',2.0);

commit;

spool off

exit;

