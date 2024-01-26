/*

Queries used for Tableau Project

*/

-- 1. 

SELECT SUM(New_Cases) AS Total_Cases, SUM(CAST(New_Deaths AS)INT) AS Total_Deaths, SUM(CAST(New_Deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL
--GROUP BY Date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

--SELECT SUM(New_Cases) AS Total_Cases, SUM(CAST(New_Deaths AS INT)) AS Total_Deaths, SUM(CAST(New_Deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE Location LIKE '%states%'
--WHERE Location = 'World'
----GROUP BY Date
--ORDER BY 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT Location, SUM(cast(New_Deaths AS INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NULL 
AND Location NOT IN ('World', 'European Union', 'International')
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- 3.

Select Location, Population, MAX(Total_Cases) AS HighestInfectionCount,  MAX((Total_Cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- 4.

SELECT Location, Population, Date, MAX(Total_Cases) AS HighestInfectionCount,  MAX((Total_Cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, Population, Date
ORDER BY PercentPopulationInfected DESC

-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out

-- 1.

SELECT dea.Continent, dea.Location, dea.Date, dea.Population
, MAX(vac.Total_Vaccinations) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	AND dea.Date = vac.Date
WHERE dea.Continent IS NOT NULL 
GROUP BY dea.Continent, dea.Location, dea.Date, dea.Population
ORDER BY 1,2,3

-- 2.
SELECT SUM(New_Cases) AS Total_Cases, SUM(CAST(New_Deaths AS INT)) AS Total_Deaths, SUM(CAST(New_Deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL 
--GROUP BY Date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT Location, SUM(CAST(New_Deaths AS INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NULL
AND Location NOT IN ('World', 'European Union', 'International')
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- 5.

--SELECT Location, Date, Total_Cases, Total_Deaths, (Total_Deaths/Total_Cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE Location LIKE '%states%'
--WHERE Continent IS NOT NULL 
--ORDER BY 1,2

-- took the above query and added population
SELECT Location, Date, Population, Total_Cases, Total_Deaths
From PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent IS NOT NULL 
ORDER BY 1,2

-- 6. 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
, SUM(CONVERT(int,vac.New_Vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.Location = vac.Location
	and dea.Date = vac.Date
WHERE dea.Continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac

-- 7. 

SELECT Location, Population, Date, MAX(Total_Cases) AS HighestInfectionCount,  MAX((Total_Cases/Population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, Population, Date
ORDER BY PercentPopulationInfected DESC




