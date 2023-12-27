

select * 
from Porfoli_project.dbo.covid_death
order by 3,4

select * 
from Porfoli_project.[dbo].[covid-vaccination]
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population_density
from Porfoli_project.dbo.covid_death
order by 1,2


-- select data that we are going to be using.

select location, date, total_cases, new_cases, total_deaths, population_density
from Porfoli_project.dbo.covid_death
order by 1,2


-- looking at total cases vs total deaths.

alter table Porfoli_project.dbo.covid_death
alter column new_cases float;

alter table Porfoli_project.dbo.covid_death
alter column new_deaths float;


SELECt location, date, total_deaths, total_cases, total_deaths / NULLIF(total_cases, 0)*100 AS death_percentage
FROM Porfoli_project.dbo.covid_death
order by 1,2


alter table Porfoli_project.dbo.covid_death
alter column total_cases float;


alter table Porfoli_project.dbo.covid_death
alter column total_deaths float;


-- looking at the total cases vs population 

select location, date, total_cases, population_density, (population_density/nullif (total_cases,0))*100 as cases_percentage
from  Porfoli_project.dbo.covid_death
order by 1,2

alter table Porfoli_project.dbo.covid_death
alter column population_density float;


-- looking at countries with highest infection rate compares to population

select location, population_density, max(total_cases) as highestcases,  max((population_density/nullif (total_cases,0)))*100 as highestinfectedcases
from  Porfoli_project.dbo.covid_death
group by  location, population_density
order by highestinfectedcases desc


-- showing countries with highest death count per population 
select location, max(total_deaths) as highestdeathcount
from  Porfoli_project.dbo.covid_death
where continent is null
group by  location
order by highestdeathcount desc

-- lets break things down by continent

select continent, max(cast(total_deaths as int)) as highestdeathcount
from  Porfoli_project.dbo.covid_death
group by  continent
order by highestdeathcount desc




-- showing continets with the highest death count per population

select continent, max(try_cast(total_deaths as int)) as highestdeathcount
from  Porfoli_project.dbo.covid_death
where continent is not null
group by  continent
order by highestdeathcount desc


select date, sum(total_cases) as total_cases
from Porfoli_project.dbo.covid_death
group by date, total_cases
order by 1

-- global numbers

select date, sum(new_cases)  total_cases, sum(new_deaths) total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as deathpercentage
from Porfoli_project.dbo.covid_death
group by date
order by 1

select sum(new_cases)  total_cases, sum(new_deaths) total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as deathpercentage
from Porfoli_project.dbo.covid_death
order by 1


-- looking at total population vs vaccination

select * 
from Porfoli_project.dbo.covid_death dea
join [Porfoli_project].dbo.[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
from Porfoli_project.dbo.covid_death dea
join [Porfoli_project].dbo.[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where vac.new_vaccinations is not null 
order by 2,3


alter table [Porfoli_project].dbo.[covid-vaccination]
alter column new_vaccinations float

--use cte

with popvsvac (continent, location,date, population_density, new_vaccination, totalvaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date, dea.location) as totalvaccinations
from Porfoli_project.dbo.covid_death dea
join [Porfoli_project].dbo.[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
--order by 2,3
)
select *, (totalvaccination/nullif(population_density,0))*100
from popvsvac


	-- Your CTE definition
WITH popvsvac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population_density,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS totalvaccinations
    FROM
        Porfoli_project.dbo.covid_death dea
    JOIN
        [Porfoli_project].dbo.[covid-vaccination] vac
    ON
        dea.location = vac.location
        AND dea.date = vac.date
)

-- Using the CTE in a SELECT statement
SELECT
    continent,
    location,
    date,
    population_density,
    new_vaccinations,
    totalvaccinations,
	(totalvaccinations/nullif(population_density,0))*100 as 
FROM
    popvsvac;



-- temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar (255),
date varchar(255),
population_density numeric,
new_vaccination numeric,
totalvaccination numeric)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date, dea.location) as totalvaccinations
from Porfoli_project.dbo.covid_death dea
join [Porfoli_project].dbo.[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
--order by 2,3
select *, (totalvaccination/nullif(population_density,0))*100 as
from #percentpopulationvaccinated


-- creating view to store data for the later vizualtion 

create view percentpopulationvaccinated  as 
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date, dea.location) as totalvaccinations
from Porfoli_project.dbo.covid_death dea
join [Porfoli_project].dbo.[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date

select * 
from percentpopulationvaccinated




