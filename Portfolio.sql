SELECT *
FROM PortfolioProject..CovidDeaths
WHERE location is NOT NULL
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that is going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows percentage of passing away from COVID by country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Covid_Population
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Highest_Infection, MAX((total_cases/population))*100 AS Infected_Population
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by Infected_Population desc

-- Show countires with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
order by TotalDeaths desc

-- Breaking down by Continent

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
order by TotalDeaths desc

-- Showing Continent with highest death count per population
SELECT location, MAX(cast(total_deaths as int)/population)*100 AS TotalDeathsPerPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
order by TotalDeathsPerPopulation desc

-- Global Numbers
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, (SUM(cast(new_deaths as int)))/(SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
order by 1,2

-- Global Numbers
SELECT  SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, (SUM(cast(new_deaths as int)))/(SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
order by 1,2

-- Look at total population vs Vaccination by date
SELECT 
CovidDeaths.continent, 
CovidDeaths.location, 
CovidDeaths.date, 
CovidDeaths.population, 
CovidVaccinations.new_vaccinations, 
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER (PARTITION BY CovidDeaths.location ORDER by CovidDeaths.location, CovidDeaths.date) AS Rolling_People_Vaccianted, 

FROM PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
	where CovidDeaths.continent is NOT NULL
	order by 2,3

	-- USE CTE
	WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_People_Vaccianted)
	as
	(
	SELECT 
CovidDeaths.continent, 
CovidDeaths.location, 
CovidDeaths.date, 
CovidDeaths.population, 
CovidVaccinations.new_vaccinations, 
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER (PARTITION BY CovidDeaths.location ORDER by CovidDeaths.location, CovidDeaths.date) AS Rolling_People_Vaccianted 
FROM PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
	where CovidDeaths.continent is NOT NULL
	)
	SELECT *, (Rolling_People_Vaccianted/Population) * 100
	FROM PopvsVac

	--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255), 
location NVARCHAR(255), 
date DATETIME, 
population INT, 
new_vaccinations INT, 
Rolling_People_Vaccianted INT
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
CovidDeaths.continent, 
CovidDeaths.location, 
CovidDeaths.date, 
CovidDeaths.population, 
CovidVaccinations.new_vaccinations, 
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER (PARTITION BY CovidDeaths.location ORDER by CovidDeaths.location, CovidDeaths.date) AS Rolling_People_Vaccianted 
FROM PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
	where CovidDeaths.continent is NOT NULL
	
SELECT *, (Rolling_People_Vaccianted/Population) * 100
	FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
CovidDeaths.continent, 
CovidDeaths.location, 
CovidDeaths.date, 
CovidDeaths.population, 
CovidVaccinations.new_vaccinations, 
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) OVER (PARTITION BY CovidDeaths.location ORDER by CovidDeaths.location, CovidDeaths.date) AS Rolling_People_Vaccianted 
FROM PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
	where CovidDeaths.continent is NOT NULL

SELECT * 
FROM PercentPopulationVaccinated