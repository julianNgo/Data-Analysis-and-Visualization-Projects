/* 
* This is a one of Project Portfolios for Data Analysis carreer
* Source reference: youtube chanel "Alex The Analyst"
* Project: Covid19 Pandemic Data Analysis - 2021
* By: Julian Ngo
*/

-- Get overall data that we have
SELECT *
FROM CovidDeaths
WHERE continent is not null
order by 3,4

SELECT *
FROM CovidVaccinations
WHERE continent is not null
order by 3,4


-- Show some colums of Covid Death table	
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2



-- Looking at total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases*100,2) as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
WHERE location like '%States%'
ORDER BY 1,2



-- Looking at total caces vs Population
-- Show what percentage of population got Covid
SELECT location, date, total_cases,population, ROUND(total_cases/population*100,2) as PercentagePopulationInfected
FROM CovidDeaths
WHERE continent is not null
WHERE location like '%States%'
ORDER BY 1,2



-- Looking at countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND(total_cases/population*100,2)) as PercentagePopulationInfected
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location,Population
ORDER BY PercentagePopulationInfected DESC



--Show Countries with Highest Deaths count per population
SELECT Location, Population, MAX(cast(total_deaths as int)) AS HighestDeathsCount, MAX(ROUND(total_deaths/population*100,2)) as DeathsPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location,Population
ORDER BY HighestDeathsCount 

SELECT *
FROM PortfolioProject..CovidDeaths


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Looking at Total Population vs Vaccinations

WITH PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location =  vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location =  vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM #PercentagePopulationVaccinated




--Creating view to store data 
Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location =  vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentagePopulationVaccinated

