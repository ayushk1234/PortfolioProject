SELECT * 
from PortfolioProject..death
order by 3,4

SElECT * 
FROM PortfolioProject..vaccine
order by 3,4

SELECT *
FROM PortfolioProject..death

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..death
order by 1,2

--looking at  Total Cases vs Total Deaths
--shows likelihood of dying 
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percent
FROM PortfolioProject..death
WHERE location like '%states%'
order by 1,2

--looking at total cases vs population
SELECT location,date,total_cases,population,(total_cases/population)*100 as Cases_Percent
FROM PortfolioProject..death
WHERE location like '%states%'
order by 1,2


--looking at countries with highest infection rates
SELECT location,population,MAX(total_cases) as total_cases,MAX((total_cases/population))*100 as PER_POP_infected
FROM PortfolioProject..death
GROUP BY  location,population
order by PER_POP_infected Desc


--looking at total deaths by location
SELECT location,population,MAX(CAST(total_deaths as int) ) as total_deaths_count 
FROM PortfolioProject..death
WHERE continent is not NULL
GROUP BY  location,population
order by total_deaths_count Desc


--looking at total deaths by continent
--SELECT location,MAX(CAST(total_deaths as int) ) as total_deaths_count 
--FROM PortfolioProject..death
--WHERE continent is NULL
--GROUP BY  location
--order by total_deaths_count Desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..death
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--looking at continents with highest death rates
SELECT continent,MAX(CAST(total_deaths as int)) as total_deaths_count,MAX((CAST(total_deaths as int)/population)*100) as PER_death_continent
FROM PortfolioProject..death
WHERE continent is not NULL
GROUP BY  continent
order by PER_death_continent Desc

--GLOBAL
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..death
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT death.location,death.population,death.date,vaccine.new_vaccinations,SUM(CAST(vaccine.new_vaccinations as int) ) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..vaccine
JOIN PortfolioProject.. death
ON vaccine.location = death.location
and death.date = vaccine.date
WHERE death.continent is not NULL
--GROUP BY  death.location,death.population
order by 2,3


--use CTE

with  PopvsVac (continent,location,population,date,newvaccination,RollingPeopleVaccinated)
as
(
SELECT death.continent,death.location,death.population,death.date,vaccine.new_vaccinations,SUM(CAST(vaccine.new_vaccinations as int) ) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..vaccine
JOIN PortfolioProject.. death
ON vaccine.location = death.location
and death.date = vaccine.date
WHERE death.continent is not NULL
--GROUP BY  death.location,death.population
)
SELECT *,(RollingPeopleVaccinated/population)*100 as PER_vaccinated
FROM PopvsVac



--TempTable
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location  nvarchar(255),
Population numeric,
Date date,
New_vaccination numeric,
RollingPeopleVacccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent,death.location,death.population,death.date,vaccine.new_vaccinations
,SUM(CAST(vaccine.new_vaccinations as int) ) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..vaccine
JOIN PortfolioProject.. death
ON vaccine.location = death.location
and death.date = vaccine.date
--WHERE death.continent is not NULL

SELECT *,(RollingPeopleVacccinated/Population)*100
FROM #PercentPopulationVaccinated

-- create view for visualisation
CREATE VIEW PercentPopulationVaccinated as
SELECT death.continent,death.location,death.population,death.date,vaccine.new_vaccinations
,SUM(CAST(vaccine.new_vaccinations as int) ) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..vaccine
JOIN PortfolioProject.. death
ON vaccine.location = death.location
and death.date = vaccine.date
WHERE death.continent is not NULL
--order by 2,3







