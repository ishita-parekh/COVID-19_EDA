/*
Covid 19 Data Exploration

Skills Used: Aggregate Functions, Joins, Windows Functions, CTEs, Create Views, Convert Data Types

*/

-- Select all data from CovidDeaths Table

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Select data from CovidDeaths table that is going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY location, date


-- Total Cases vs Population
-- Shows what percentage of population got infected with Covid

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS percentpopulationaffected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
ORDER BY location,date


-- Countries with highest infection rate per popluation and percentage of population affected

SELECT location, population, MAX(total_cases) AS highestcasesrecorded, ROUND((MAX(total_cases)/population)*100,2) AS percentpopulationaffected
FROM PortfolioProject..CovidDeaths
--WHERE location IN ('India','United States', 'China')
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY percentpopulationaffected DESC


-- Countries with highest deaths per population

SELECT location, MAX(CAST(total_deaths as int)) AS highestdeathsrecorded
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highestdeathsrecorded DESC


--Breaking things down by Continent

-- Looking at continents with highest deaths per population

SELECT continent, MAX(CAST(total_deaths as int)) AS highestdeathsrecorded
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highestdeathsrecorded DESC


-- Global numbers

SELECT SUM(new_cases) AS totalnewcases, SUM(CAST(new_deaths AS int)) AS totalnewdeaths, ROUND((SUM(CAST(new_deaths AS int))/SUM(new_cases))*100,2) AS deathpercent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1 
 

--Looking in CovidVaccinations Table

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


 -- Total Population vs New Vaccinations
 -- Order By 2,3 - Ordering by 2nd and 3rd column from the select list

  SELECT dea.continent, dea.location, dea.date, dea.population, vaccine.new_vaccinations
 , SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalvaccination
 FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vaccine
     ON dea.location = vaccine.location 
	 AND dea.date = vaccine.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


 -- Using CTE to perform Calculation on Partition By on previous query
 -- Shows percentage of population that received vaccinations

 WITH vacvspop (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 AS
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vaccine.new_vaccinations
 , SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
 FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vaccine
     ON dea.location = vaccine.location 
	 AND dea.date = vaccine.date
WHERE dea.continent IS NOT NULL
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS percentvaccinations
FROM vacvspop


-- Creating View To store data for later Visualizations

-- Creating view for Highest Deaths recorded query

CREATE VIEW HighestDeathsRecorded AS
SELECT continent, MAX(CAST(total_deaths as int)) AS highestdeathsrecorded
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY highestdeathsrecorded DESC

SELECT *
FROM HighestDeathsRecorded


-- Creating view for Total Population vs Vaccination query

CREATE VIEW PeopleVaccinated AS
  SELECT dea.continent, dea.location, dea.date, dea.population, vaccine.new_vaccinations
 , SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vaccine
     ON dea.location = vaccine.location 
	 AND dea.date = vaccine.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *
FROM PeopleVaccinated