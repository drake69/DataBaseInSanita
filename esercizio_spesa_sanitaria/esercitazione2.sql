########################################################################
## posizioniamoci all interno della cartella che contiene il file da importare

########################################################################
## COLLEGAMENTO AL DATA BASE SERVER

mysql -u root -p -h [HOST_ADDRESS]

########################################################################
## CREAZIONE DATA BASE

create database corsodb collate utf8_general_ci; 

########################################################################
## ACCESSO AL DATABASE

use corsodb;

########################################################################
## creazione tabella per importazione temporanea

create table athletes ( ID varchar(255) ,Name varchar(255),Sex varchar(255),Age varchar(255),Height varchar(255),Weight varchar(255),Team varchar(255),NOC varchar(255),Games varchar(255),Year varchar(255),Season varchar(255),City varchar(255),Sport varchar(255),Event varchar(255),Medal varchar(255));

########################################################################
## Vediamo la tabella se è stata creata

show tables;

########################################################################
## vediamo lo schema della tabella

describe athletes;

########################################################################
## IMPORTAZIONE

LOAD DATA LOCAL INFILE './athlete_events.csv' INTO TABLE athletes FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r' IGNORE 1 ROWS;

########################################################################
## cambiamo nome alla tabella

alter table athletes rename AthleteEventsImport;

########################################################################
## creiamo le tabelle di anagrafica

create table City ( Id int not null auto_increment, Value varchar(255), primary key (Id));

create table Team ( Id int not null auto_increment, Value varchar(255), primary key (Id));

frcreate table Season ( Id int not null auto_increment, Value varchar(255), primary key (Id));

create table Sport ( Id int not null auto_increment, Value varchar(255), primary key (Id));

create table Event ( Id int not null auto_increment, Value varchar(255), IdSport int,  primary key (Id));

create table Medal  ( Id int not null auto_increment, Value varchar(255),  primary key (Id));

create table Nationality  ( Id int not null auto_increment, Value varchar(255),  primary key (Id));

create table Athlete ( Id int not null auto_increment, Name varchar(255), Sex varchar(1), YearOfBirth int , primary key (Id));

########################################################################
## puliamo la tabella dai valori anomali

update AthleteEventsImport set Age= null where Age='NA';

update AthleteEventsImport set Medal= null where Medal='NA';

update AthleteEventsImport set Weight= null where Weight='NA';

update AthleteEventsImport set Height= null where Height='NA';

########################################################################
## popoliamo le tabelle con i dati anagrafici

insert into City (Value) ( select distinct City from AthleteEventsImport where City is not null);

insert into Team (Value) ( select distinct Team from AthleteEventsImport where Team is not null);

insert into Season (Value) ( select distinct Season from AthleteEventsImport where Season is not null);

insert into Sport (Value) ( select distinct Sport from AthleteEventsImport where Sport is not null);

insert into Medal (Value) ( select distinct Medal from AthleteEventsImport where Medal is not null);

insert into Nationality (Value) ( select distinct NOC from AthleteEventsImport where NOC is not null);

insert into Event (Value, IdSport) (select distinct aei.Event, s.Id from AthleteEventsImport aei inner join Sport s on aei.Sport=s.value);

########################################################################
## calcoliamo l anno di nascita mentre importiamo

insert into Athlete (Name, Sex, YearOfBirth) (select Name, Sex, Year - Age  from AthleteEventsImport  where Name is not null group by Name);

create table AthletePartecipation ( IdAthlete int , Height int, Weight int, IdTeam int, IdNationality int, Year int, IdSeason int, IdCity int, IdEvent int, IdMedal int);

########################################################################
## creiamo le colonne di appoggio

alter table AthleteEventsImport add column IdAthlete int, add column IdTeam int, add column IdSeason int, add column IdCity int, add column IdEvent int, add column IdMedal int, add column  IdNationality int;

########################################################################
## creo un vincolo di unicità per la colonna valore nelle tabelle di anagrafica, così eventuali accodamenti futuri non creano duplicati e velocizzare accesso dati

ALTER TABLE Athlete  ADD UNIQUE INDEX AthleteNameSex (Name,Sex);

ALTER TABLE Nationality  ADD UNIQUE INDEX NationalityName (Value);

ALTER TABLE City  ADD UNIQUE INDEX CityName (Value);

ALTER TABLE Sport  ADD UNIQUE INDEX SportName (Value);

ALTER TABLE Team  ADD UNIQUE INDEX TeamName (Value);

ALTER TABLE Event  ADD UNIQUE INDEX EventName (Value);

########################################################################
## popoliamo le colonne degli identificativi con i valori appropriati

update AthleteEventsImport aei set IdMedal=(select m.Id from Medal m where m.Value=aei.Medal );

update AthleteEventsImport aei set IdEvent=(select m.Id from Event m where m.Value=aei.Event );

update AthleteEventsImport aei set IdNationality=(select m.Id from Nationality m where m.Value=aei.NOC);

update AthleteEventsImport aei set IdCity=(select m.Id from City m where m.Value=aei.City);

update AthleteEventsImport aei set IdSeason=(select m.Id from Season m where m.Value=aei.Season);

update AthleteEventsImport aei set IdTeam=(select m.Id from Team m where m.Value=aei.Team);

update AthleteEventsImport aei set IdAthlete=(select a.Id from Athlete a where a.Name=aei.Name and a.Sex=aei.Sex);

## crediamo le associazioni tra tabelle/ integrità referenziale

ALTER TABLE AthletePartecipation ADD CONSTRAINT IdAthlete FOREIGN KEY (IdAthlete) REFERENCES Athlete (Id);

ALTER TABLE AthletePartecipation ADD CONSTRAINT IdMedal FOREIGN KEY (IdMedal) REFERENCES Medal (Id);

ALTER TABLE AthletePartecipation ADD CONSTRAINT IdSeason FOREIGN KEY (IdSeason) REFERENCES Season (Id);

ALTER TABLE AthletePartecipation ADD CONSTRAINT IdTeam FOREIGN KEY (IdTeam) REFERENCES Team (Id);

ALTER TABLE AthletePartecipation ADD CONSTRAINT IdCity FOREIGN KEY (IdCity) REFERENCES City (Id);

ALTER TABLE AthletePartecipation ADD CONSTRAINT IdNationality FOREIGN KEY (IdNationality) REFERENCES Nationality (Id);

ALTER TABLE AthletePartecipation ADD CONSTRAINT IdEvent FOREIGN KEY (IdEvent) REFERENCES Event (Id);

########################################################################
## Popoliamo l'intera tabella AthletePartecipation

insert into AthletePartecipation ( IdAthlete, Height, Weight, IdTeam, IdNationality, Year, IdSeason, IdCity,IdEvent, IdMedal) 
select  IdAthlete, Height, Weight, IdTeam, IdNationality, Year, IdSeason, IdCity,IdEvent, IdMedal  from AthleteEventsImport;

########################################################################
## eliminiamo le colonne di appoggio per poter riciclare in futuro la tabella di import

alter table AthleteEventsImport drop column IdAthlete , drop column IdTeam , drop column IdSeason , drop column IdCity , drop column IdEvent , drop column IdMedal ;

########################################################################
## verifico che numericamente i record ci sono tutti

select count(*) from AthletePartecipation;

select count(*) from AthleteEventsImport;

########################################################################
##genero tabella iniziale con query

select a.Name, a.Sex, (ap.Year-a.YearOfBirth) as Age, ap.Height, ap.Weight, t.Value as Team, n.Value as NOC, concat(ap.Year," ", s.Value) as Games, ap.Year, s.Value as Season, c.Value as City, sp.Value as Sport,     e.Value as Event, m.value as Medal 
from corsodb.AthletePartecipation ap 
 inner join corsodb.Athlete a on a.Id=ap.IdAthlete 
 inner join corsodb.Team t on t.Id=ap.IdTeam 
 inner join corsodb.Nationality n on n.Id=ap.IdNationality 
 inner join corsodb.Season s on ap.IdSeason=s.Id 
 inner join corsodb.City c on c.Id=ap.IdCity 
 inner JOIN corsodb.Event e on ap.IdEvent=e.Id 
 inner join corsodb.Sport sp on sp.Id=e.IdSport 
 left join corsodb.Medal m on m.Id=ap.IdMedal;


########################################################################
## Per eseguire tutti i comandi da creazione a normalizzazione, comandi presenti nel file di testo commands.sql

mysql -u root -p -h [HOST_ADDRESS] < commands.sql

########################################################################
## per fare il backup del database

mysqldump -d corsodb -h [HOST_ADDRESS] -p -u root > corsodb.sql

########################################################################
## per ricreare il database

mysql -u root -p -h [HOST_ADDRESS]

drop database corsodb;

mysql -u root -p -h [HOST_ADDRESS] < 





