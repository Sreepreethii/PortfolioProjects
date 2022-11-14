use portfolio_1;

select * from covid_deaths
order by 3,4;

select * from covid_vaccinations
order by 3,4;

select Location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where continent is NOT NULL
order by 1,2;

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%gha%' and continent is NOT NULL
order by 1,2;

-- Looking at total cases vs population
-- what percentage of population got covid

select Location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from covid_deaths
where continent is NOT NULL
-- where location like '%gha%'
order by 1,2;

-- Looking at countries with Highest Infection Rate compared to population

select Location, population, MAX(total_cases) as Highest_Infection_Rate, max((total_cases/population)*100) as CasePercentage
from covid_deaths
-- where location like '%gha%'
where continent is NOT NULL
Group by Location, Population
order by CasePercentage DESC;

-- Showing countries with Highest Death count per population

ALTER TABLE covid_deaths
CHANGE COLUMN total_deaths total_deaths int;

select Location, MAX(total_deaths) as Total_Death_Count
from covid_deaths
where continent is NOT NULL
Group by Location
order by Total_Death_Count DESC;

-- LETS BREAK DOWN THING BY CONTINENT

-- Showing the continents with highest death counts

select continent, MAX(total_deaths) as Total_Death_Count
from covid_deaths
where continent is NOT NULL
Group by continent
order by Total_Death_Count DESC;

-- GLOBAL NUMBERS

ALTER TABLE covid_deaths
CHANGE COLUMN new_vaccinations new_vaccinations INT;

select date, SUM(new_cases) as total_cases, SUM(New_deaths) as total_deaths, SUM(New_deaths)/SUM(New_cases)*100 as Death_Percentage
from covid_deaths
-- where location like '%gha%' 
where continent is NOT NULL
GROUP BY date
order by 1,2;

-- Total Death Percentage across the world

select SUM(new_cases) as total_cases, SUM(New_deaths) as total_deaths, SUM(New_deaths)/SUM(New_cases)*100 as Death_Percentage
from covid_deaths
-- where location like '%gha%' 
where continent is NOT NULL
order by 1,2;

-- Looking at Total population vs Vaccination

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION by cd.location Order by cd.location, cd.date) as Rolling_People_Vaccinated,
(Rolling_People_Vaccinated/cd.population)*100
from covid_deaths cd 
join covid_vaccinations cv on 
cd.location = cv.location and cd.date = cv.date
where cd.continent is NOT NULL
order by 2,3;

-- Use Common table expression

With PopvsVac(Continent, location, date, population, new_vaccination, Rolling_People_Vaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION by cd.location Order by cd.location, cd.date) as Rolling_People_Vaccinated
from covid_deaths cd 
join covid_vaccinations cv on 
cd.location = cv.location and cd.date = cv.date
where cd.continent is NOT NULL
order by 2,3
)
select *, (Rolling_People_Vaccinated/population)*100 from PopvsVac;

-- TEMP TABLE

CREATE TABLE IF NOT EXISTS PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population INT,
New_vaccination INT,
Rolling_People_Vaccinated INT
);

Insert into PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION by cd.location Order by cd.location, cd.date) as Rolling_People_Vaccinated
from covid_deaths cd 
join covid_vaccinations cv on 
cd.location = cv.location and cd.date = cv.date
-- where cd.continent is NOT NULL
order by 2,3; 

-- Creating View to store data for later

CREATE VIEW V_PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION by cd.location Order by cd.location, cd.date) as Rolling_People_Vaccinated
from covid_deaths cd 
join covid_vaccinations cv on 
cd.location = cv.location and cd.date = cv.date
where cd.continent is NOT NULL
-- order by 2,3; 