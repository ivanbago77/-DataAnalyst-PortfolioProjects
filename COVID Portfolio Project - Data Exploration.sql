/*

Covid 19 Data Exploration

Skills used: JOINS, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


--We get rid of continent as a loacation with --WHERE continent is not null

SELECT * FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Selecting data that we are going to be using

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population  
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract in your country

SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%' AND Continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population infected with Covid 

SELECT Location, Date, Population, Total_Cases, (Total_Cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2

-- Lookaing at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(Total_Cases) AS HighestInfectionCount, MAX((Total_Cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%' 
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with Highest Death Count per Population

SELECT Continent, MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

--GLOBAL  NUMBERS

SELECT SUM(New_Cases) AS Total_Cases, SUM(CAST(New_Deaths AS INT)) AS Total_Deaths, SUM(CAST(New_Deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%' and 
WHERE Continent IS NOT NULL
--GROUP BY Date
ORDER BY 1, 2

--Total Population vs Vaccinations

SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
SUM(CONVERT(INT,vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

With PopvsVac (Continent, Loacation, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
SUM(CONVERT(INT,vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.Date = vac.Date
WHERE dea.Continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC,
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
SUM(CONVERT(INT,vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.Date = vac.Date
--WHERE dea.Continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
SUM(CONVERT(INT, vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.Date = vac.Date
WHERE dea.Continent IS NOT NULL
