# mysql -u lcorsaro -p -h localhost --local_infile=1
 
# per evitare ERROR 2068 (HY000): LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.

# creo database
create database spesa_sanitaria collate utf8_general_ci;

use spesa_sanitaria;

create table import_spese(
 Anno varchar(255), 
 CodRegCommit varchar(255),
 RegioneCommit varchar(255),
 CodASL varchar(255),
 AziendaSanitaria varchar(255),
 CodiceCND varchar(255),
 CodTipoDM varchar(255),
 NumRep varchar(255),
 CostoAcq varchar(255)
 );
 
# file -ib /home/lcorsaro/Desktop/ESERCIZIO/spesa_sanitaria_2018.csv
# us-ascii

 
LOAD DATA LOCAL INFILE '/home/lcorsaro/Desktop/ESERCIZIO/spesa_sanitaria_2018.csv'
INTO TABLE import_spese
CHARACTER SET ascii
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS;

create table import_posti_letto(
 Anno varchar(255),
 Codice_Regione varchar(255),
 Descrizione_Regione varchar(255),
 Codice_Azienda varchar(255),
 Tipo_Azienda varchar(255),
 Codice_struttura varchar(255),
 Denominazione_struttura varchar(255),
 Indirizzo varchar(255),
 Codice_Comune varchar(255),
 Comune varchar(255),
 Sigla_provincia varchar(255),
 Codice_tipo_struttura varchar(255),
 Descrizione_tipo_struttura varchar(255),
 Tipo_di_Disciplina varchar(255),
 Posti_letto_degenza_ordinaria varchar(255),
 Posti_letto_degenza_a_pagamento varchar(255),
 Posti_letto_Day_Hospital varchar(255),
 Posti_letto_Day_Surgery varchar(255),
 Totale_posti_letto varchar(255)
 );


# file -ib /home/lcorsaro/Desktop/ESERCIZIO/posti_letto_ospedali.csv
# 8859-1
# mysql> show character set;
# 8859-2 -> (latin2)

LOAD DATA LOCAL INFILE '/home/lcorsaro/Desktop/ESERCIZIO/posti_letto_ospedali.csv'
INTO TABLE import_posti_letto
CHARACTER SET latin2
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS;

create table import_asl
(
 ANNO varchar(255),
 CODICE_REGIONE varchar(255), 
 DENOMINAZIONE_REGIONE varchar(255), 
 CODICE_AZIENDA varchar(255),
 DENOMINAZIONE_AZIENDA varchar(255),
 CODICE_COMUNE varchar(255),
 COMUNE varchar(255),
 MASCHI varchar(255),
 FEMMINE varchar(255),
 TOTALE  varchar(255)
);


# file -ib ...
# iso-8859-1	

LOAD DATA LOCAL INFILE '/home/lcorsaro/Desktop/ESERCIZIO/asl_comuni_popolazione.csv'
INTO TABLE import_asl
CHARACTER SET latin2
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS;

update import_spese set CodRegCommit=trim(CodRegCommit);

#sfrutto il ciclo for di R per ciclare e ripulire i campi

[1] "update import_spese set Anno = trim(Anno);"
[1] "update import_spese set CodRegCommit = trim(CodRegCommit);"
[1] "update import_spese set RegioneCommit = trim(RegioneCommit);"
[1] "update import_spese set CodASL = trim(CodASL);"
[1] "update import_spese set AziendaSanitaria = trim(AziendaSanitaria);"
[1] "update import_spese set CodiceCND = trim(CodiceCND);"
[1] "update import_spese set CodTipoDM = trim(CodTipoDM);"
[1] "update import_spese set NumRep = trim(NumRep);"
[1] "update import_spese set CostoAcq = trim(CostoAcq);"
> field_set <- dbListFields(mydb,"import_asl")
> for(f in field_set)
+ {   
+   q <- paste0("update import_asl set ", f, " = trim(",f,");")
+   print(q)
+   dbSendQuery(mydb,q)
+ }
[1] "update import_asl set ANNO = trim(ANNO);"
[1] "update import_asl set CODICE_REGIONE = trim(CODICE_REGIONE);"
[1] "update import_asl set DENOMINAZIONE_REGIONE = trim(DENOMINAZIONE_REGIONE);"
[1] "update import_asl set CODICE_AZIENDA = trim(CODICE_AZIENDA);"
[1] "update import_asl set DENOMINAZIONE_AZIENDA = trim(DENOMINAZIONE_AZIENDA);"
[1] "update import_asl set CODICE_COMUNE = trim(CODICE_COMUNE);"
[1] "update import_asl set COMUNE = trim(COMUNE);"
[1] "update import_asl set MASCHI = trim(MASCHI);"
[1] "update import_asl set FEMMINE = trim(FEMMINE);"
[1] "update import_asl set TOTALE = trim(TOTALE);"
> field_set <- dbListFields(mydb,"import_posti_letto")
> for(f in field_set)
+ {   
+   q <- paste0("update import_posti_letto set ", f, " = trim(",f,");")
+   print(q)
+   dbSendQuery(mydb,q)
+ }
[1] "update import_posti_letto set Anno = trim(Anno);"
[1] "update import_posti_letto set Codice_Regione = trim(Codice_Regione);"
[1] "update import_posti_letto set Descrizione_Regione = trim(Descrizione_Regione);"
[1] "update import_posti_letto set Codice_Azienda = trim(Codice_Azienda);"
[1] "update import_posti_letto set Tipo_Azienda = trim(Tipo_Azienda);"
[1] "update import_posti_letto set Codice_struttura = trim(Codice_struttura);"
[1] "update import_posti_letto set Denominazione_struttura = trim(Denominazione_struttura);"
[1] "update import_posti_letto set Indirizzo = trim(Indirizzo);"
[1] "update import_posti_letto set Codice_Comune = trim(Codice_Comune);"
[1] "update import_posti_letto set Comune = trim(Comune);"
[1] "update import_posti_letto set Sigla_provincia = trim(Sigla_provincia);"
[1] "update import_posti_letto set Codice_tipo_struttura = trim(Codice_tipo_struttura);"
[1] "update import_posti_letto set Descrizione_tipo_struttura = trim(Descrizione_tipo_struttura);"
[1] "update import_posti_letto set Tipo_di_Disciplina = trim(Tipo_di_Disciplina);"
[1] "update import_posti_letto set Posti_letto_degenza_ordinaria = trim(Posti_letto_degenza_ordinaria);"
[1] "update import_posti_letto set Posti_letto_degenza_a_pagamento = trim(Posti_letto_degenza_a_pagamento);"
[1] "update import_posti_letto set Posti_letto_Day_Hospital = trim(Posti_letto_Day_Hospital);"
[1] "update import_posti_letto set Posti_letto_Day_Surgery = trim(Posti_letto_Day_Surgery);"
[1] "update import_posti_letto set Totale_posti_letto = trim(Totale_posti_letto);"


# cast conversione di tipo

select convert(CostoAcq, FLOAT) from import_spese limit 1;
select convert(CostoAcq, decimal(5,2)) from import_spese limit 1;
select convert(CostoAcq, decimal(5,2)), NumRep from import_spese where NumRep='501460' limit 10;

update import_spese set CostoAcq=replace(CostoAcq,'.','');
update import_spese set CostoAcq=replace(CostoAcq,',','.');

update import_spese set CostoAcq=replace(replace(CostoAcq,'.','' ),',','.');

select convert(CostoAcq, decimal(10,2)), NumRep from import_spese where NumRep='501460' limit 10;

update import_spese set CostoAcq=convert(CostoAcq, decimal(10,2)); 

#non converto i posti letto perchè sono numeri interi

#1
create table if not exists provincia (
	id int not null auto_increment,
	value varchar(30),
	primary key (id)
);

insert into provincia (value) (select upper(trim(Sigla_provincia)) from import_posti_letto where Sigla_provincia is not null
	and Sigla_provincia<>'' group by Sigla_provincia);

#2
create table if not exists regione (
	id int not null auto_increment,
	value varchar(30),
	primary key (id)
);

#
insert into regione (value) (select upper(trim(Descrizione_Regione)) from import_posti_letto where Descrizione_Regione is not null
	and Descrizione_Regione<>'' group by Descrizione_Regione);



create table if not exists comune (
	id int not null auto_increment,
	value varchar(30),
	id_provincia int not null,
	id_regione int not null,
	primary key (id),
	foreign key (id_provincia)
	references provincia(id),
	foreign key (id_regione)
	references regione(id)
);

insert into comune (value, id_provincia, id_regione)
	(select ipl.Comune, p.id, r.id 
		from import_posti_letto ipl 
			left join provincia p on upper(trim(ipl.Sigla_provincia))=p.value
			left join regione r on upper(trim(Descrizione_Regione))=r.value 
			where ipl.Comune is not null group by ipl.Comune, p.id, r.id);
		

insert into provincia (value) (select upper(trim(Sigla_provincia)) from import_posti_letto where Sigla_provincia is not null
	and Sigla_provincia<>'' group by Sigla_provincia);

#3
create table if not exists tipo_struttura (
	id int not null auto_increment,
	value varchar(30),
	primary key (id)
);


#farmacie
insert into tipo_struttura (value) values ('FARMACIA');
# avrà ID 1
#asl/ats
insert into tipo_struttura (value) values ('ATS');
# avrà ID 2
alter table tipo_struttura value value varchar(100) not null;

#ospedali
insert into tipo_struttura (value) (select upper(trim(Descrizione_tipo_struttura)) from  import_posti_letto where Descrizione_tipo_struttura is not null and Descrizione_tipo_struttura<>'' group by Descrizione_tipo_struttura);

#4
create table if not exists tipo_codice_struttura (
	id int not null auto_increment,
	value varchar(30),
	primary key (id)
);

insert into tipo_codice_struttura (value) values ('ospedaliero assegnato ats');


#5
create table if not exists tipo_posto_letto (
	id int not null auto_increment,
	value varchar(30),
	primary key (id)
);














