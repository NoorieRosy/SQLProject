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


