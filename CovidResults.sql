
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
order by 3,4

-- SELECT *
-- FROM PortfolioProject..CovidVaccinations
-- order by 3,4

-- Select Data that I'm going to be using

SELECT LOCATION, DATE, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
Order by 1,2 


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of someone RIP if they contract Covid in their Country by Percentage

SELECT LOCATION, DATE, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND continent is not null 
Order by 1,2 




-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 

SELECT LOCATION, DATE, total_cases, total_deaths, Population, (total_cases/population)*100 AS CasesPerPopulation
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
Order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population 

SELECT location, Population, MAX(total_cases) AS HighestInfectionPerCountry, MAX((total_cases/population))*100 
AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
GROUP BY  location, Population
Order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null 
GROUP BY  location, Population
Order by TotalDeathCount DESC

-- Showing Continents with Highest Death Count per population

 SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
 GROUP BY location 
 Order by TotalDeathCount DESC

-- OR 
-- Showing Continents with Highest Death Count per population (Original) 

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null 
GROUP BY continent  
Order by TotalDeathCount DESC

--Global Numbers

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths AS int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 
AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null 
GROUP BY date
Order by 1,2


-- Total Deaths over Total Cases Death Percentage 

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths AS int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 
AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null 
Order by 1,2


-- Look at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null 
ORDER BY 2, 3

-- Use CTE 

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null 
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac



-- TEMP TABLE 

Drop Table If Exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated 
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
-- WHERE dea.continent is not null 
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations 

DROP VIEW IF EXISTS PercentPopulationVaccinated
USE PortfolioProject
GO 
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.. CovidDeaths dea
JOIN PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null 
-- ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated