USE  PortfolioProject;

-- Selecting the data we need 

SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM
	PortfolioProject.coviddeaths
ORDER BY 1,2;

-- Ordering by 1,2 (location & date) 

-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying from covid in your country

SELECT 
	location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 AS DeathPercntage
FROM
	PortfolioProject.coviddeaths
WHERE 
	location LIKE '%states'
ORDER BY 1,2;


-- looking at Total cases vs Population 
-- Shows what percentage of population has got Covid-19

SELECT 
	location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM
	PortfolioProject.coviddeaths
WHERE 
	location LIKE '%states'
ORDER BY 1,2;

-- Looking at countries with the Highest Infection Rates Compared to Population 

SELECT 
	location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM
	PortfolioProject.coviddeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population
ORDER BY
	PercentPopulationInfected
DESC;


-- Showing Countries with the Highest Death Count Per Population 
-- Converting Datatype for TotalDeaths 

SELECT 
	location, MAX(cast(total_deaths as UNSIGNED INTEGER )) AS TotalDeathCount
FROM
	PortfolioProject.coviddeaths
WHERE 
	continent != '' 
GROUP BY
	location
ORDER BY
	TotalDeathCount
DESC;


-- Breaking Things Down by Continets 
-- Where continent is not empty ( NOT Null didnt work) Had to use != '' 

 -- Showing the continents with the Highest Death Count Per Popul

SELECT 
	continent, MAX(cast(total_deaths as UNSIGNED INTEGER )) AS TotalDeathCount
FROM
	PortfolioProject.coviddeaths
WHERE 
	continent != '' 
GROUP BY
	continent
ORDER BY
	TotalDeathCount
DESC;



-- GLOBAL NUMBERS 

SELECT
	date, SUM(new_cases) as Total_cases,  SUM(CAST(new_deaths as UNSIGNED INTEGER)) as Total_deaths, SUM(CAST(new_deaths as UNSIGNED INTEGER)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
	PortfolioProject.coviddeaths
WHERE 
	continent != ''
GROUP BY
	date
ORDER BY
	1,2;
    
    
    
    -- Reviewing the other covidvaccination Table
    -- Joining both tables on a unique field (location & date)
    
    SELECT * FROM PortfolioProject.covidvaccinations;
    
SELECT 
	*
FROM
	 PortfolioProject.coviddeaths AS dea
JOIN 
	PortfolioProject.covidvaccinations AS vac
	ON
		dea.location = vac.location
	AND dea.date  = vac.date;
    
    
    
-- Looking at the Total Population  Vs Vaccinations

SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM
	 PortfolioProject.coviddeaths AS dea
JOIN 
	PortfolioProject.covidvaccinations AS vac
	ON
		dea.location = vac.location
	AND dea.date  = vac.date
WHERE 
	dea.continent != '' 
ORDER BY
	2,3;
	
    
-- looking at the rooling count of the new vaccinations per day


SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as UNSIGNED INTEGER)) OVER  (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated   
FROM
	 PortfolioProject.coviddeaths AS dea
JOIN 
	PortfolioProject.covidvaccinations AS vac
	ON
		dea.location = vac.location
	AND dea.date  = vac.date
WHERE 
	dea.continent != '' 
ORDER BY
	2,3;
	
    
-- Using TEMP Tables 

DROP TABLE IF EXISTS PercentPopulationVaccinated; 

CREATE TABLE PercentPopulationVaccinatined
(
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population NUMERIC,
New_vacinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

SHOW TABLES;


INSERT INTO PercentPopulationVaccinated (
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as UNSIGNED INTEGER)) OVER  (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM
	 PortfolioProject.coviddeaths AS dea
JOIN 
	PortfolioProject.covidvaccinations AS vac
	ON
		dea.location = vac.location
	AND dea.date  = vac.date
WHERE 
	dea.continent != ''

 SELECT *,
 	(RollingPeopleVaccinated/population)* 100 
FROM
	PercentPopulationVaccinated)
    ;
    
-- creating Views to Store Later for our Data Visualization 

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as UNSIGNED INTEGER)) OVER  (PARTITION BY dea.location  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated   
FROM
	 PortfolioProject.coviddeaths AS dea
JOIN 
	PortfolioProject.covidvaccinations AS vac
	ON
		dea.location = vac.location
	AND dea.date  = vac.date
WHERE 
	dea.continent != '' 
ORDER BY
	2,3;
    

