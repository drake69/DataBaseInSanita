library(RMySQL)
#definisco la mia connessione
mydb =dbConnect(MySQL(), user='lcorsaro', password='prova',dbname='lcorsaro',host='localhost');

#imposto il recordset
rs = dbSendQuery(mydb,"select a.value as Name, s.value as Sex, a.year_of_birth as YearOfBirth, t.value as Team, 
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
  	left join specialty sp on p.id_specialty=sp.id;")
  	

#estraggo 10 record  	
data_set <- fetch(rs, n=10)

dbClearResult(rs)

field_set <- dbListFields(mydb,"import_data_set")

for(f in field_set)
{   
   q <- paste0("update import_data_set set ", f, " =NULL where ",f,"='NA';")
   print(q)
   dbSendQuery(mydb,q)
}


# calcoliamo la media per imputare altezza e peso
rs <- dbSendQuery(mydb,"select height, weight from partecipation 
                  where height is not null and weight is not null")
data_set <- fetch(rs, n=-1)
head(data_set)

heigth_mean <- mean(data_set$height)
weigth_mean <- mean(data_set$weight)

q <- paste0("update partecipation set height=", heigth_mean, " where height is null;")
dbSendQuery(mydb, q)

q <- paste0("update partecipation set weight=", weigth_mean, " where weight is null; ")
dbSendQuery(mydb, q)

