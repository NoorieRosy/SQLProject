Use portfolioproject;

Select * from coviddeaths
order by 3,4;

Select * from covidvacci
order by 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- Looking at totals cases vs total deaths
-- shows likelihood of dying if contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from coviddeaths
order by 1,2;

-- Looking at total cases vs population
-- shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from coviddeaths
order by 1,2;

-- Looking at the countries with highest with highest infection rate compared to population

Select location, population, max(total_cases) as highest_infected, max((total_cases/population))*100 as Percent_population_Infected
from coviddeaths
group by location, population
order by Percent_population_Infected desc;

-- Showing countries with highest death count per population

Select location, max(total_deaths) as total_death_count
from coviddeaths
where continent is not null
group by location
order by total_death_count desc;

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- (RollingPeopleVaccinated/population)*100

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVacci vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVacci vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;










