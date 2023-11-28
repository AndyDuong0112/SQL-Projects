/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Data that we are going to use from CovidDeaths table and Vaccinations table: 
continent, location, date, total_cases, new_cases, total_deaths, population, new_vaccinations
*/

-- Compare Total Case with Total Death ( World)
SELECT location, date, population, total_cases, total_deaths,
       (total_deaths/total_cases)*100 AS [DeathPercentage]
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY location, date;

-- In Vietnam
SELECT location, date, population, total_cases, new_cases, total_deaths,
       (total_deaths/total_cases)*100 AS [DeathPercentage]
FROM [dbo].[CovidDeaths]
WHERE location like 'Vietnam'
ORDER BY location, date;

---------------------------------------------------------
-- Total Case vs Total Population (World)
SELECT location, date, population, total_cases,
       (total_cases/population)*100 AS [InfectionRateInThePopulation]
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY location, date;

-- In Vietnam
SELECT location, date, population, total_cases,
       (total_cases/population)*100 AS [InfectionRateInThePopulation]
FROM [dbo].[CovidDeaths]
WHERE location like 'Vietnam'
ORDER BY location, date;

---------------------------------------------------------
-- Looking for countries with Highest Infection Rate compared to Population
SELECT location,date, population, MAX(total_cases) AS [HighestInfectionCount],
       MAX(total_cases/population) AS [HighestInfectionRatePerPopulation]
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location,date, population
ORDER BY location, date;

-- Where location start with 'United'
SELECT location, date, population, MAX(total_cases) AS [HighestInfectionCount],
       MAX(total_cases/population) AS [HighestInfectionRatePerPopulation]
FROM [dbo].[CovidDeaths]
WHERE location like 'United%'
GROUP BY location, date, population
ORDER BY location, date;

---------------------------------------------------------
-- Showing countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS [TotalDeathCount]
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  MAX(CAST(total_deaths AS int)) DESC;

-- Showing continents with the highest death count per population ( GROUP BY Continent )
SELECT continent, MAX(CAST(total_deaths AS int)) AS [TotalDeathCount]
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  MAX(CAST(total_deaths AS int)) DESC;

---------------------------------------------------------
-- GLOBAL NUMBERS ( TotalCase, TotalDeath, TotalDeath vs TotalCase - GROUP BY DATE)
SELECT date, SUM(new_cases) AS [TotalCase], 
       SUM(CAST(new_deaths AS int)) AS [TotalDeath],
	   (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS [DeathPercentage]
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date ASC;


---------------------------------------------------------
-- Looking at Population and TotalVaccinations
SELECT v.continent, v.location, v.date, d.population, v.new_vaccinations,
       SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY v.location ORDER BY v.location, v.date ) AS [TotalVaccinations]
FROM [dbo].[CovidVaccinations] AS v
INNER JOIN [dbo].[CovidDeaths] AS d
ON v.location = d.location AND v.date = d.date
WHERE v.continent IS NOT NULL
ORDER BY v.location, v.date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Use CTE 
WITH CTE_table (continent, location, date, population, new_vaccinations, TotalVaccinations)
AS (
SELECT v.continent, v.location, v.date, d.population, v.new_vaccinations,
       SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY v.location ORDER BY v.location, v.date) 
FROM [dbo].[CovidVaccinations] AS v
INNER JOIN [dbo].[CovidDeaths] AS d
ON v.location = d.location AND v.date = d.date
WHERE v.continent IS NOT NULL
)

SELECT *, (TotalVaccinations/population)*100 AS [PercentPopulationVaccinated] 
FROM CTE_table
ORDER BY continent, location, date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine 
-- USE TEMP TABLE 
DROP TABLE IF EXISTS #Temp_table 
CREATE TABLE #Temp_table(
contient nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations nvarchar(255),
TotalVaccinations int)

INSERT INTO #Temp_table (contient, location, date, population, new_vaccinations, TotalVaccinations)
SELECT v.continent, v.location, v.date, d.population, v.new_vaccinations,
       SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY v.location ORDER BY v.location, v.date) 
FROM [dbo].[CovidVaccinations] AS v
INNER JOIN [dbo].[CovidDeaths] AS d
ON v.location = d.location AND v.date = d.date
WHERE v.continent IS NOT NULL

SELECT *, (TotalVaccinations/population)*100 AS [PercentPopulationVaccinated] 
FROM #Temp_table
ORDER BY contient, location, date

--  Creating View to store data for later visualizations ( TotalPopulationVaccinated)
CREATE VIEW TotalPopulationVaccinated AS 
SELECT v.continent, v.location, v.date, d.population, v.new_vaccinations,
       SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY v.location ORDER BY v.location, v.date ) AS [TotalVaccinations]
FROM [dbo].[CovidVaccinations] AS v
INNER JOIN [dbo].[CovidDeaths] AS d
ON v.location = d.location AND v.date = d.date
WHERE v.continent IS NOT NULL

