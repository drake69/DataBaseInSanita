library(RMySQL)

#definisco la mia connessione
mydb =dbConnect(MySQL(), user='gpetazzoni', password='Sql2022Corso',dbname='lcorsaro_1',host='localhost');

rs <- dbSendQuery(mydb,"select * from Athlete where YearOfBirth < 1900;")
#estraggo 10 record
data_set <- fetch(rs, n=10)
View(data_set)
dbClearResult(rs)

rs <- dbGetQuery(mydb, "show tables;")
View(rs)

query <- "  SELECT 
        `ath`.`Name` AS `AthleteName`,
        `ast`.`Height` AS `Height`,
        `ast`.`Weight` AS `Weight`,
        `ast`.`Gender` AS `Gender`,
        (`gam`.`Year` - `ath`.`YearOfBirth`) AS `Age`,
        `med`.`Name` AS `Medal`,
        `evt`.`Name` AS `EventName`,
        `spt`.`Name` AS `Sport`,
        `gam`.`Year` AS `Year`,
        `sea`.`Name` AS `Season`,
        `cit`.`Name` AS `City`,
        `tea`.`Name` AS `Team`,
        `cnt`.`Name` AS `Country`
    FROM
        ((((((((((`Attendance` `att`
        LEFT JOIN `AthleteStatus` `ast` ON ((`att`.`IdAthleteStatus` = `ast`.`IdAthleteStatus`)))
        LEFT JOIN `Athlete` `ath` ON ((`ast`.`IdAthlete` = `ath`.`IdAthlete`)))
        LEFT JOIN `Event` `evt` ON ((`att`.`IdEvent` = `evt`.`IdEvent`)))
        LEFT JOIN `Sport` `spt` ON ((`evt`.`IdSport` = `spt`.`IdSport`)))
        LEFT JOIN `Game` `gam` ON ((`att`.`IdGame` = `gam`.`IdGame`)))
        LEFT JOIN `Season` `sea` ON ((`gam`.`IdSeason` = `sea`.`IdSeason`)))
        LEFT JOIN `City` `cit` ON ((`gam`.`IdCity` = `cit`.`IdCity`)))
        LEFT JOIN `Team` `tea` ON ((`att`.`IdTeam` = `tea`.`IdTeam`)))
        LEFT JOIN `Country` `cnt` ON ((`tea`.`IdCountry` = `cnt`.`IdCountry`)))
        LEFT JOIN `Medal` `med` ON ((`att`.`IdMedal` = `med`.`IdMedal`)))"

#imposto il recordset
rs = dbSendQuery(mydb,query)
#estraggo 10 record
data_set <- fetch(rs, n=100)
View(data_set)
dbClearResult(rs)



mydb =dbConnect(MySQL(), user='gpetazzoni', password='Sql2022Corso',dbname='lcorsaro_1',host='localhost');

field_set <- dbListFields(mydb,"aei")

rs <- dbSendQuery(mydb, "Select * from aei;")
data_set <- fetch(rs,1)
dbClearResult(rs)
View(field_set)
View(data_set)
for(f in field_set)
{
   if(is.numeric(data_set[1,f] ))
      next
   q <- paste0("update aei set ", f, " =NULL where ",f,"='NA';")
   print(q)
   dbSendQuery(mydb,q)
}

# query per calcolare la median
# SELECT AVG(dd.height) as median_val
# FROM (
#   SELECT d.height, @rownum:=@rownum+1 as `row_number`, @total_rows:=@rownum
#   FROM AthletePartecipation d, (SELECT @rownum:=0) r
#   WHERE d.height is NOT NULL
#   ORDER BY d.height
# ) as dd
# WHERE dd.row_number IN ( FLOOR((@total_rows+1)/2), FLOOR((@total_rows+2)/2) );

# calcoliamo la mediana per imputare altezza e peso
rs <- dbSendQuery(mydb,"select Height, Weight from AthleteStatus
                  where Height is not null and Weight is not null")
data_set <- fetch(rs, n=-1)
head(data_set)

heigth_median <- median(data_set$height)
weigth_median <- median(data_set$weight)

q <- paste0("update AthleteStatus set Height=", heigth_mean, " where Height is null;")
dbSendQuery(mydb, q)

q <- paste0("update AthleteStatus set Weight=", weigth_mean, " where Weight is null; ")
dbSendQuery(mydb, q)

dbWriteTable()

country <- dbGetQuery(mydb,"Select IdCountry as Country from Country; ")
gender <- c("F","M")
for (g in gender)
{
  for (c in country)
  {
    query <- paste0("select ast.Height as Height, ast.Weight as Weight from Attendance as att
                  inner join AthleteStatus as ast
                  on att.IdAthleteStatus=ast.IdAthleteStatus
                  inner join Team as tea
                  on tea.IdTeam = att.IdTeam
                  inner join Country as cou
                  on cou.IdCountry = tea.IdCountry
                  group by cou.IdCountry, ast.Gender,  ast.Height , ast.IdAthleteStatus, ast.Weight 
                  having (ast.Height is not null or ast.Weight is not null) and cou.IdCountry=",
                  c, " and ast.Gender='", g ,"'", sep="" )
    print(q)
    data_set <- dbGetQuery(mydb,query)
    heigth_median <- median(data_set$Height, na.rm = T)
    weigth_median <- median(data_set$Weight, na.rm = T)
    
    q <- paste0(" update AthleteStatus set Height=", heigth_median, " where Gender ='", g ,"' 
      and Height is null and IdAthleteStatus in (  
      select att.IdAthleteStatus from Attendance as att
      inner join Team as tea
      on tea.IdTeam = att.IdTeam
      inner join Country as cou
      on cou.IdCountry = tea.IdCountry
      where cou.IdCountry='", c ,"')", sep="")
    
    print(q)
    dbSendQuery(mydb, q)
    
    q <- paste0(" update AthleteStatus set Weight=", weigth_median, " where Gender ='", g ,"' 
      and Height is null and IdAthleteStatus in (  
      select att.IdAthleteStatus from Attendance as att
      inner join Team as tea
      on tea.IdTeam = att.IdTeam
      inner join Country as cou
      on cou.IdCountry = tea.IdCountry
      where cou.IdCountry='", c ,"')", sep="")
    
    print(q)
    dbSendQuery(mydb, q)
    

    query <- paste0("select ast.Height as Height, ast.Weight as Weight from Attendance as att
                  inner join AthleteStatus as ast
                  on att.IdAthleteStatus=ast.IdAthleteStatus
                  inner join Team as tea
                  on tea.IdTeam = att.IdTeam
                  inner join Country as cou
                  on cou.IdCountry = tea.IdCountry
                  group by cou.IdCountry, ast.Gender,  ast.Height , ast.IdAthleteStatus, ast.Weight 
                  having (ast.Height is not null or ast.Weight is not null) and cou.IdCountry=",
                    c, " and ast.Gender is null ", sep="" )
    print(q)
    data_set <- dbGetQuery(mydb,query)
    heigth_median <- median(data_set$Height, na.rm = T)
    weigth_median <- median(data_set$Weight, na.rm = T)
    
    q <- paste0(" update AthleteStatus set Height=", heigth_median, " where Height is null 
    and IdAthleteStatus in (  
      select att.IdAthleteStatus from Attendance as att
      inner join Team as tea
      on tea.IdTeam = att.IdTeam
      inner join Country as cou
      on cou.IdCountry = tea.IdCountry
      where cou.IdCountry='", c ,"')", sep="")
    
    print(q)
    dbSendQuery(mydb, q)
    

    
    
  }
}

print(dbGetQuery(mydb,"select count(*) from AthleteStatus where Height is null")==0)

print(dbGetQuery(mydb,"select count(*) from AthleteStatus where Weight is null")==0)

