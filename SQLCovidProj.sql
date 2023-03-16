Use portfolioproject;

SELECT 
    *
FROM
    coviddeaths
ORDER BY 3 , 4;

SELECT 
    *
FROM
    covidvacci
ORDER BY 3 , 4;

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
ORDER BY 1 , 2;

-- Looking at totals cases vs total deaths
-- shows likelihood of dying if contract covid in your country

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathsPercentage
FROM
    coviddeaths
ORDER BY 1 , 2;

-- Looking at total cases vs population
-- shows what percentage of population got covid

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS CovidPercentage
FROM
    coviddeaths
ORDER BY 1 , 2;

-- Looking at the countries with highest with highest infection rate compared to population

SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infected,
    MAX((total_cases / population)) * 100 AS Percent_population_Infected
FROM
    coviddeaths
GROUP BY location , population
ORDER BY Percent_population_Infected DESC;

-- Showing countries with highest death count per population

SELECT 
    location, MAX(total_deaths) AS total_death_count
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- Global numbers

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(New_Cases) * 100 AS DeathPercentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

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










