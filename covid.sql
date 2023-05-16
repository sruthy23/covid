/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM covid..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM covid..covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4;



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid..covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;


-- Total Cases vs Total Deaths : Shows likelihood of dying if you contract covid in your country


SELECT Location, date, total_cases,total_deaths, (total_deaths*1.0/total_cases)*100 AS DeathPercentage
FROM covid..covid_deaths
-- WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases vs Population : Shows what percentage of population is infected with Covid


SELECT Location, date, population, total_cases, (total_cases*1.0/population)*100 AS PercentPopulationInfected
FROM covid..covid_deaths
-- WHERE location ='India'
ORDER BY 1,2;


-- Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases*1.0/population))*100 AS PercentPopulationInfected
FROM covid..covid_deaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;


-- Total death count per country


SELECT Location, MAX(Total_deaths) AS TotalDeathCount
FROM covid..covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- BREAKING THINGS DOWN BY CONTINENT


-- Total death count per contintent by end of 2021 


SELECT continent, SUM(total_deaths) AS TotalDeathCount
FROM covid..covid_deaths
WHERE continent IS NOT NULL AND date = '2021-12-31'
GROUP BY continent
ORDER BY TotalDeathCount DESC;



-- GLOBAL NUMBERS


SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)*1.0/SUM(New_Cases)*100 AS DeathPercentage
FROM covid..covid_deaths
WHERE continent IS NOT NULL
--Group By date
ORDER BY 1,2;


-- Total Population vs Vaccinations : Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid..covid_deaths dea
JOIN covid..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS 
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
	FROM covid..covid_deaths dea
	JOIN covid..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid..covid_deaths dea
JOIN covid..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated





-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated AS


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid..covid_deaths dea
JOIN covid..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
