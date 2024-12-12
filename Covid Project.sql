SELECT *
FROM CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select data that we're going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

-- Total Cases VS Total Deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_Cases) * 100 AS 'Death Percentage'
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_Cases) * 100 AS 'Death Percentage'
FROM CovidDeaths
WHERE location LIKE '%India%' AND continent IS NOT NULL
ORDER BY 1, 2

-- Total Case vs Population
-- Show what percentage of population got COVID
SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS 'Death Percentage'
FROM CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1, 2

SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS 'Percent Population Infected'
FROM CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Counties with highest infection rate compared to population
SELECT Location, MAX(total_cases) AS 'Highest Infection Count', population, MAX((total_cases/population)) * 100 AS 'Percent Population Infected'
FROM CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY population, location
ORDER BY 'Percent Population Infected' DESC

-- Showing countries with Highest Death Count per Population
-- CAST - converting the nvarchar data type into integer
SELECT Location, MAX(CAST(total_deaths AS INT)) AS 'Total Death Count'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 'Total Death Count' DESC

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing the continent with the highest Death Count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS 'Total Death Count'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 'Total Death Count' DESC

SELECT location, MAX(CAST(total_deaths AS INT)) AS 'Total Death Count'
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 'Total Death Count' DESC


SELECT continent, MAX(CAST(total_deaths AS INT)) AS 'Total Death Count'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 'Total Death Count' DESC

-- Global Numbers
SELECT date, SUM(new_cases) AS 'Total Cases', SUM(CAST(new_deaths AS INT)) AS 'Total Deaths', SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS 'Death Percentage'
FROM CovidDeaths
--WHERE location LIKE '%India%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(new_cases) AS 'Total Cases', SUM(CAST(new_deaths AS INT)) AS 'Total Deaths', SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS 'Death Percentage'
FROM CovidDeaths
--WHERE location LIKE '%India%' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccination
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations
FROM CovidDeaths AS Deaths
JOIN CovidVaccinations AS Vac
ON Deaths.location = vac.location AND Deaths.date = vac.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 1, 2, 3
--WHERE deaths.continent = 'North America' AND Vac.continent = 'North America'


SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY deaths.location, deaths.date) AS 'Rolling People Vaccinated'
FROM CovidDeaths AS Deaths
JOIN CovidVaccinations AS Vac
ON Deaths.location = vac.location AND Deaths.date = vac.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 1, 2, 3

--USE CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Deaths
JOIN CovidVaccinations AS Vac
ON Deaths.location = vac.location AND Deaths.date = vac.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 1, 2, 3
)
SELECT *
FROM popvsvac

WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Deaths
JOIN CovidVaccinations AS Vac
ON Deaths.location = vac.location AND Deaths.date = vac.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 1, 2, 3
)
SELECT *, ( RollingPeopleVaccinated / population) * 100
FROM popvsvac


-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Deaths
JOIN CovidVaccinations AS Vac
ON Deaths.location = vac.location AND Deaths.date = vac.date
--WHERE Deaths.continent IS NOT NULL
--ORDER BY 1, 2, 3

SELECT *, ( RollingPeopleVaccinated / population) * 100
FROM #PercentPopulationVaccinated

-- Creating Views to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS Deaths
JOIN CovidVaccinations AS Vac
ON Deaths.location = vac.location AND Deaths.date = vac.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 1, 2, 3

SELECT *
FROM PercentPopulationVaccinated