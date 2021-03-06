--Muhammad Sajid Siddique

--SQL Covid-19 Data Exploration 
-- Skills Utilized:
	--windows functions
	--Aggregate functions
	--joins
	--Modifying data types
	--Temp Table
	--CTE's
	--creating views


--viewing initial data 
select * 
from Portfolio_project..covid_death
Where continent is not null
order by 3,4

select * 
from Portfolio_project..covid_vaccines
Where continent is not null
order by 3,4

--Extracting data that we will be used for further querying 

Select Location, Date, total_cases, new_cases, total_deaths, population
from Portfolio_project..covid_death
Where continent is not null
order by 1,2

-- observing total cases vs total deaths in any country
-- Shows likelihood of dying for contracted covid victims over time 
-- can modify line like parameter to country of choice
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Mortality Percentage'
from Portfolio_project..covid_death
where location like '%states%' and continent is not null
order by 1,2

-- Looking at Total cases for country population
--percentage of population affected with covid in the US
Select Location, Date, population, total_cases, (total_cases/population)*100 as 'PercentPopulationInfected'
from Portfolio_project..covid_death
where location like '%states%'
order by 1,2

-- identifying which countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as 'PercentPopulationInfected'
from Portfolio_project..covid_death
group by location, population
order by PercentPopulationInfected desc


--shows countries with highest death count for its population
Select Location, population, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio_project..covid_death
where continent is not null
group by location, population
order by TotalDeathCount desc


-- COVID numbers by continent
--Shows continents with the highest death count per population
Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio_project..covid_death
where continent is not null
group by continent
order by TotalDeathCount desc


-- Understanding global numbers of total cases vs deaths over time
Select date, SUM(new_cases) as 'total_cases', SUM(cast(new_deaths as int)) as 'total deaths' , SUM(cast(new_deaths as int))/Sum(new_cases)*100 as 'Worldwide DeathPercentage'
from Portfolio_project..covid_death
where continent is not null
Group by date
order by 1,2


--observing covid-19 global numbers
--worldwide death percentage
Select SUM(new_cases) as 'total_cases', SUM(cast(new_deaths as int)) as 'total deaths', 
SUM(cast(new_deaths as int))/Sum(new_cases)*100 as 'Worldwide DeathPercentage'
from Portfolio_project..covid_death
where continent is not null
order by 1,2


-- Observing total populations worldwide vs vaccination
-- Query shows percentage of population recieved the vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpopvaccinations  
from Portfolio_project..covid_death dea
join Portfolio_project..covid_vaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE (common table expression) to perform calculation on partition 
with popvsVac(continent,location, date, population, new_vaccinations, rollingvaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingvaccinations  
from Portfolio_project..covid_death dea
join Portfolio_project..covid_vaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

)

 
 -- Using Temp Table to perform calculation on partition by in previous query
 
 DROP table if exists #percentPopulationvaccinated
 Create Table #percentPopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingvaccinations numeric
 )
 Insert into #percentPopulationvaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingvaccinations  
from Portfolio_project..covid_death dea
join Portfolio_project..covid_vaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (rollingvaccinations/population)*100 as 'PercentageVaccinated'
from #percentPopulationvaccinated


--Creating view to store data for tableau visulization 

create View percentPopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingvaccinations  
from Portfolio_project..covid_death dea
join Portfolio_project..covid_vaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from percentPopulationvaccinated
