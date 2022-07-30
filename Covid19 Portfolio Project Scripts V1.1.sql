SELECT *
FROM dbo.CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4

--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1, 2

--total cases vs total deaths--

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
FROM dbo.CovidDeaths
WHERE location like '%india%'
ORDER BY 1, 2

--total cases vs population--

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Covid_Infected
FROM dbo.CovidDeaths
WHERE location like '%india%'
ORDER BY 1, 2

--countries with highest covid rate as per pop--

SELECT location, population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM dbo.CovidDeaths
GROUP BY population, location
ORDER BY PercentPopulationInfected desc

--countries with highest death count per pop--

--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM dbo.CovidDeaths
--WHERE continent is not NULL
--GROUP BY location
--ORDER BY TotalDeathCount desc

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--continents with highest death counts--

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--global numbers--

SELECT date,SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths
, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Global_Death_Percentage
FROM dbo.CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths
, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Global_Death_Percentage
FROM PortfolioProject_DB..CovidDeaths
--WHERE location like '%india%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


-- total population vs vaccination--

--USE CTE---

WITH PopuVsVacc (Continent, Location, Date, Population, new_vaccinations, people_vac_rolling)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vac_rolling
	FROM PortfolioProject_DB..CovidDeaths AS dea
	JOIN PortfolioProject_DB..CovidVaccinations AS vac 
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null
	--ORder by 1,2,3
)
SELECT *, (people_vac_rolling/Population)*100 
FROM PopuVsVacc

--Temp table--
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	people_vac_rolling numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS people_vac_rolling
	FROM PortfolioProject_DB..CovidDeaths AS dea
	JOIN PortfolioProject_DB..CovidVaccinations AS vac 
		ON dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not null
	--ORder by 1,2,3

SELECT *, (people_vac_rolling/Population)*100 
FROM #PercentPopulationVaccinated


--creating view to store data for later viz--

Create view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS people_vac_rolling
	FROM PortfolioProject_DB..CovidDeaths AS dea
	JOIN PortfolioProject_DB..CovidVaccinations AS vac 
		ON dea.location = vac.location
		and dea.date = vac.date
	WHERE dea.continent is not null
	--ORder by 1,2,3

SELECT * FROM PercentPopulationVaccinated