use corsodb;

select a.Name, a.Sex, (ap.Year-a.YearOfBirth) as Age, ap.Height, ap.Weight, t.Value as Team, n.Value as NOC, concat(ap.Year," ", s.Value) as Games, ap.Year, s.Value as Season, c.Value as City, sp.Value as Sport,     e.Value as Event, m.value as Medal from AthletePartecipation ap 
 inner join Athlete a on a.Id=ap.IdAthlete 
 inner join Team t on t.Id=ap.IdTeam 
 inner join Nationality n on n.Id=ap.IdNationality 
 inner join Season s on ap.IdSeason=s.Id 
 inner join City c on c.Id=ap.IdCity 
 inner JOIN Event e on ap.IdEvent=e.Id 
 inner join Sport sp on sp.Id=e.IdSport 
 left join Medal m on m.Id=ap.IdMedal;

