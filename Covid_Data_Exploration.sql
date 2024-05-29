
-- SELECT Data That we are going to be using
-- Looking at the total_cases v total_deaths
-- Shows the likelihood of dying if you got covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid`
--WHERE location like '%United States%'
ORDER BY 1, 2;


-- Looking at total_cases v population
--Shows the percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS gotten_percentage
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid`
WHERE location like 'United States'
ORDER BY 1, 2;


-- -- Looking for Countries with Highest Infection per population 
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_of_pop_infected
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid`
--WHERE location like 'United States'
GROUP BY location, population
ORDER BY percent_of_pop_infected desc;


-- Showing the countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid`
WHERE continent IS NOT NULL
--AND location like 'United States'
GROUP BY location
ORDER BY total_death_count desc;

-- Break it down by continent 

SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid`
WHERE continent IS NULL
--AND location like 'United States'
GROUP BY location
ORDER BY total_death_count desc;


-- --Showing the Continents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count desc;


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage 
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid`
-- WHERE location LIKE 'United States'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

-- Looking at Total Population v Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac,

FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid` AS dea
JOIN `sql-project-portfolio-424814.covid_vaccinations.vac_from_covid` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;



-- USE CTE

WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (
      PARTITION BY dea.location 
      ORDER BY dea.date
    ) AS RollingPeopleVaccinated
  FROM 
    `sql-project-portfolio-424814.covid_deaths.died_from_covid` AS dea
  JOIN 
    `sql-project-portfolio-424814.covid_vaccinations.vac_from_covid` AS vac
  ON 
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE 
    dea.continent IS NOT NULL
)
SELECT 
  *, 
  (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM 
  PopvsVac;


--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVac

CREATE TABLE #PercentPopulationVac
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated
)

INSERT INTO #PercentPopulationVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid` AS dea
JOIN `sql-project-portfolio-424814.covid_vaccinations.vac_from_covid` AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVac


--CREATE VIEW For Later Storage

CREATE VIEW PercentPopulationVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM `sql-project-portfolio-424814.covid_deaths.died_from_covid` AS dea
JOIN `sql-project-portfolio-424814.covid_vaccinations.vac_from_covid` AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
