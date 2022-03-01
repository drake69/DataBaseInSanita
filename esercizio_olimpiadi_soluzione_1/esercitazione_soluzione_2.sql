#tutto miniscolo con separazione da underscore
# Value

# mysql -u lcorsaro -p -h localhost #local_infile=1

drop database lcorsaro;

create database lcorsaro collate utf8_general_ci;

use lcorsaro;

drop table if exists import_data_set;

create table import_data_set
(
	ID varchar(255),
	Name varchar(255),
	Sex varchar(255),
	Age varchar(255),
	Height varchar(255),
	Weight varchar(255),
	Team varchar(255),
	NOC varchar(255),
	Games varchar(255),
	Year varchar(255),
	Season varchar(255),
	City varchar(255),
	Sport varchar(255),
	Event varchar(255),
	Medal varchar(255)
);

desc import_data_set;

TRUNCATE import_data_set;

# file -ib /home/lcorsaro/Desktop/athlete_events.csv
# charset us-ascii
# show character set;

# \nr oppure \n
# \t 

LOAD DATA LOCAL INFILE '/home/lcorsaro/Desktop/athlete_events.csv'
INTO TABLE import_data_set 
CHARACTER SET ascii
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r'
IGNORE 1 ROWS;

select count(*) from import_data_set;

select max(length(City)) from import_data_set;

#select City from import_data_set where length(City) =22 group by City;

drop table if exists city;

create table city (
 id int not null auto_increment,
 value varchar(30) not null,
 primary key(id)
);

desc city;

create table unit_of_measure (
     id int not null auto_increment,
     value varchar(30) not null,
     primary key(id)
);

drop table if exists country;

create table country (
 id int not null auto_increment,
 value varchar(30)  not null,
 primary key(id)
);


drop table if exists season;

create table season (
 id int not null auto_increment,
 value varchar(30)  not null,
 primary key(id)
);

select max(length(Sport)) from import_data_set;

drop table if exists sport;

create table sport (
 id int not null auto_increment,
 value varchar(30)  not null,
 primary key(id)
);


drop table if exists medal;

create table medal (
 id int not null auto_increment,
 value varchar(30)  not null,
 primary key(id)
);

drop table if exists sex;

create table sex (
 id int not null auto_increment,
 value varchar(30)  not null,
 primary key(id)
);

select max(length(Team)) from import_data_set;

drop table if exists team;

create table if not exists team (
 id int not null auto_increment,
 id_country int  not null,
 value varchar(60)  not null,
 primary key (id),
 foreign key (id_country)
 references country(id)
);


drop table if exists athlete;

create table if not exists athlete (
 id int not null auto_increment,
 id_sex int  not null,
 value varchar(255)  not null,
 year_of_birth SMALLINT  not null,
 primary key (id),
 foreign key (id_sex)
 references sex(id)
);

drop table if exists game;

create table if not exists game (
 id int not null auto_increment,
 id_city int  not null,
 id_season int  not null,
 year SMALLINT  not null,
 primary key (id),
 foreign key (id_city)
 references city(id),
 foreign key (id_season)
 references season(id)
);

select max(length(Event)) from import_data_set;

drop table if exists specialty;

create table if not exists specialty (
 id int not null auto_increment,
 id_sport int  not null,
 value varchar(30)  not null,
 primary key (id),
 foreign key (id_sport)
 references sport(id)
);


drop table if exists partecipation;

create table if not exists partecipation (
 id int not null auto_increment,
 id_athlete int  not null,
 id_team int  not null,
 id_game int  not null,
 id_specialty int  not null,
 id_medal int,
 height smallint,
 id_unit_of_measure_height int,
 weight smallint,
 id_unit_of_measure_weight int, 
 primary key (id),
 foreign key (id_athlete)
 references athlete(id),
 foreign key (id_team)
 references team(id),
 foreign key (id_game)
 references game(id), 
 foreign key (id_specialty)
 references specialty(id), 
 foreign key (id_medal)
 references medal(id),
 foreign key (id_unit_of_measure_height)
 references unit_of_measure(id), 
 foreign key (id_unit_of_measure_weight)
 references unit_of_measure(id) 
);

# create table athlete_measure(
# id int not null auto_increment,
# height smallint,
# id_unit_of_measure_height int,
# weight smallint,
# id_unit_of_measure_weight int
#)


# bonifica
update import_data_set set Age=NULL where Age='NA';
update import_data_set set Height=NULL where Height='NA';
update import_data_set set Weight=NULL where Weight='NA';
update import_data_set set Year=NULL where Year='NA';
update import_data_set set Medal=NULL where Medal='NA';

#popoliamo le tabelle
insert into city (value) (select City from import_data_set where City is not null and City<>'NA'  group by City  );
insert into country (value) (select NOC from import_data_set where NOC is not null and NOC<>'NA'  group by NOC  );
insert into season (value) (select Season from import_data_set where Season is not null and Season<>'NA'  group by Season  );
insert into sport (value) (select Sport from import_data_set where Sport is not null and Sport<>'NA'  group by Sport);
insert into medal (value) (select Medal from import_data_set where Medal is not null and Medal<>'NA'  group by Medal);
insert into sex (value) (select Sex from import_data_set where Sex is not null and Sex<>'NA'  group by Sex);

# anno di nascita
alter table import_data_set add column year_of_birth smallint;
update import_data_set set year_of_birth=Year - Age where Year is not null and Age is not null;

alter table athlete change column year_of_birth year_of_birth smallint null;


insert into athlete (id_sex, value, year_of_birth) (select max(s.id) , ids.Name, ceiling(avg(ids.year_of_birth)) from import_data_set  ids left join sex  s on   ids.Sex = s.value where ids.Name is not null group by ids.Name);
   
#select max(s.id) , ids.Name, ceiling(avg(ids.year_of_birth)) from import_data_set  ids left join sex  s on 
#  ids.Sex = s.value where ids.Name is not null group by ids.Name; - > 138528 # 134732

# select Name from import_data_set group by Name; ---- > 134732

delete from import_data_set where Sex is null and Name is null and Games is null;

#select Name, count(Sex) from import_data_set group by Name,Sex having count(Sex)> 1;

# city
# season 

insert into game (id_city,id_season,year) 
(
select city.id, season.id, import_data_set.Year
 from import_data_set 
 left join city on import_data_set.City=city.value 
 left join season  on import_data_set.Season=season.value 
group by city.id, season.id, import_data_set.Year);


#team
insert into team (id_country, value) (select c.id, ids.Team from import_data_set ids left join country c on
ids.NOC=c.value group by c.id, ids.Team);


#specialty
insert into specialty (id_sport, value) (select s.id, ids.Event from import_data_set ids left join sport s
on ids.Sport=s.value group by s.id, ids.Event);

insert into partecipation (id_athlete, id_team, id_game, id_specialty, id_medal, height, id_unit_of_measure_height, 
 weight, id_unit_of_measure_weight) 
 (select distinct a.id, t.id, g.id, s.id, m.id, ids.Height, 1, ids.Weight, 2 
 from import_data_set ids
 left join athlete a 
 	on ids.Name= a.value
 left join country cc
 	on ids.NOC = cc.value
 left join city c2
 	on ids.City = c2.value
 left join team t
 	on ids.Team =t.value and cc.id=t.id_country
 left join season se
 	on ids.Season = se.value
 left join game g
 	on ids.Year= g.year and g.id_season=se.id and g.id_city= c2.id
 left join specialty s
 	on ids.Event = s.value
 left join medal m
 	on ids.Medal = m.value
 );
 
 
 select a.value as Name, s.value as Sex, m.value as Medal, g.year as Year  from partecipation  p 
 left join athlete a 
 	on a.id=p.id_athlete
 left join sex s
 	on s.id= a.id_sex
 left join medal m
 	on m.id = p.id_medal
 left join game g
 	on g.id = p.id_game;
 		

 alter table medal add index idx_medal (value);
 
 alter table import_data_set add column id_athlete int not null;
 
 update import_data_set aei set id_athlete=(
 select a.id from athlete a where a.value=aei.Name
 );
 
 alter table athlete add index idx_athlete (value);

alter table game add index idx_city_season (id_city,id_season);

 
 
 
 
 
 

select a.value as Name, s.value as Sex, a.year_of_birth as YearOfBirth, t.value as Team, 
	(se.value + ' ' + g.Year ) as Game, p.height as Height, p.weight as Weight, m.value as Medal , sp.value as Specialty, c.value as City,
	se.value as Season, g.year as Year
  from partecipation p 
  	left join athlete a on p.id_athlete=a.id
  	left join sex s on a.id_sex=s.id
  	left join team t on p.id_team=t.id
  	left join game g on p.id_game=g.id
  	left join season se on g.id_season=se.id 
  	left join city c on g.id_city=c.id 
  	left join medal m on p.id_medal=m.id
  	left join specialty sp on p.id_specialty=sp.id;
  	
  	
  	
  	
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  


