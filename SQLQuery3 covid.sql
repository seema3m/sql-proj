select * 
from CovidDeaths  
order by 3,4

--select * 
--from covidvaccinations 
--order by 3,4  

--Selecting Data that i will use 

select location,date, total_cases,new_cases,total_deaths,population
from seema.dbo.CovidDeaths
order by 1,2


--Total Cases vs Total Deaths
-- shows Covid is closely linked to the death
select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
from seema.dbo.CovidDeaths
order by 1,2

--Total Cases vs Population
--percentage of populations effected with Covid
select location,date, population,total_cases,  (total_cases/population)*100 AS PopulationPercentage
from seema.dbo.CovidDeaths
order by 1,2

--Location that has highest covid rate vs population
select location, population,MAX(total_cases) AS Highcovidcount,  MAX(total_cases/population)*100 AS highcovidPercentage
from seema.dbo.CovidDeaths
GROUP by Location,population
order by highcovidPercentage desc

--Highest death rate in locations
select Location, MAX(CASt(total_deaths as INT)) as Totaldeathcount
from seema.dbo.CovidDeaths
Where continent is not null --removind null
GROUP by Location
order by Totaldeathcount desc

--continent is null
select Location, MAX(CASt(total_deaths as INT)) as Totaldeathcount
from seema.dbo.CovidDeaths
Where continent is  null --removind null
GROUP by Location
order by Totaldeathcount desc

--  check by continent
select continent, MAX(CASt(total_deaths as INT)) as Totaldeathcount
from seema.dbo.CovidDeaths
Where continent is not null --removind null
GROUP by continent
order by Totaldeathcount desc

--continent with highest death count
select continent, MAX(CASt(total_deaths as INT)) as Totaldeathcount
from seema.dbo.CovidDeaths
Where continent is not null --removind null
GROUP by continent
order by Totaldeathcount desc

--date wise cases, deaths and percentage
select date, SUM(new_cases) AS total_cases,SUM(CAST (new_deaths AS int)) AS total_deaths, SUM(CAST( new_deaths AS int ))/SUM(new_cases)*100 AS DeathPercentage
from seema.dbo.CovidDeaths
where continent is not null
Group by date
order by 1,2 

-- Total cases across the world
select SUM(new_cases) AS total_cases,SUM(CAST (new_deaths AS int)) AS total_deaths, SUM(CAST( new_deaths AS int ))/SUM(new_cases)*100 AS DeathPercentage
from seema.dbo.CovidDeaths
where continent is not null
--Group by date
order by 1,2 

--check Vaccincation table
select * 
from covidvaccinations

--Join coviddeath and covidvaccination table
select * 
from CovidDeaths AS d
join CovidVaccinations AS v
ON d.location = v.location
and d.date = v.date

--Total population vs vaccination
select d.continent,d.location,d.date,d.population,v.new_vaccinations
from CovidDeaths AS d
join CovidVaccinations AS v
ON d.location = v.location
and d.date = v.date
where d.continent is not null
Order by 2,3

--Population vs vaccination with rolling total
select d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CAST(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location,d.Date) as totalrollingvaccinated
from CovidDeaths AS d
join CovidVaccinations AS v
ON d.location = v.location
and d.date = v.date
where d.continent is not null
Order by 2,3


--CTE
with PopvsVac(continent,location,date,population,new_vaccinations,totalrollingvaccinated)
AS
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CAST(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location,d.Date) as totalrollingvaccinated
from CovidDeaths AS d
join CovidVaccinations AS v
ON d.location = v.location
and d.date = v.date
where d.continent is not null
--Order by 2,3
)
select *,(totalrollingvaccinated/population)*100 AS vacincatedpercentage
from PopvsVac

--create temp table

Drop table if exists #vaccinatedpercent -- dropping table
Create table  #vaccinatedpercent
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
totalrollingvaccinated numeric
)

Insert into #vaccinatedpercent
select d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CAST(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location,d.Date) as totalrollingvaccinated
from CovidDeaths AS d
join CovidVaccinations AS v
ON d.location = v.location
and d.date = v.date
--where d.continent is not null
--Order by 2,3

select *,(totalrollingvaccinated/population)*100 AS vacincatedpercentage
from #vaccinatedpercent

  ---creating view for visualisation

  create view vaccinatedpercent as
  select d.continent,d.location,d.date,d.population,v.new_vaccinations, SUM(CAST(v.new_vaccinations as int)) OVER (Partition by d.location Order by d.location,d.Date) as totalrollingvaccinated
from CovidDeaths AS d
join CovidVaccinations AS v
ON d.location = v.location
and d.date = v.date
where d.continent is not null
--Order by 2,3

check view:
Select *
from vaccinatedpercent
