SELECT * FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE continent is not null
order by 3,4

## select data that we are going to using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE continent is not null
order by 1,2

## Looking at Total Cases vs Total Deaths and show likelihood of dying if you contract covid in Indonesia

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE location like '%Indonesia%'
and continent is not null
order by 1,2

## Looking at Total Cases vs Population and shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE location like '%Indonesia%'
and continent is not null
order by 1,2

## Looking at country with highest infection rate compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE continent is not null
GROUP BY location, population
order by PercentagePopulationInfected DESC

## showing country with highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC

## Break Down by Continent table
## Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

## Global Numbers

SELECT date, SUM(new_cases)as Total_cases,SUM(new_deaths)as Total_deaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE continent is not null
GROUP BY date
order by 1,2

## or

SELECT SUM(new_cases)as Total_cases,SUM(new_deaths)as Total_deaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths` 
WHERE continent is not null
order by 1,2


## Looking at Total population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(dea.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `portfolioproject-397108.PortfolioProject.CovidDeaths`dea
JOIN `portfolioproject-397108.PortfolioProject.CovidVaccinations`vac
  on dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


## USE CTE

WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(Cast(dea.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM (
    SELECT * 
    FROM `portfolioproject-397108.PortfolioProject.CovidDeaths`
    WHERE continent IS NOT NULL
  ) dea
  JOIN (
    SELECT * 
    FROM `portfolioproject-397108.PortfolioProject.CovidVaccinations`
  ) vac
  ON dea.location = vac.location
  AND dea.date = vac.date
)
SELECT 
PopvsVac.*,
  (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM PopvsVac;

## TEMP TABLE

CREATE TABLE PortfolioProject.PercentPopulationVaccinated (
  continent STRING,
  location STRING,
  date DATE,
  population NUMERIC,
  New_vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);
INSERT INTO PortfolioProject.PercentPopulationVaccinated
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(dea.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
  `portfolioproject-397108.PortfolioProject.CovidDeaths` dea
JOIN
  `portfolioproject-397108.PortfolioProject.CovidVaccinations` vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  location, date;
SELECT
  *,
  (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM
  PortfolioProject.PercentPopulationVaccinated;


## Creating view to store data fot later vizualizations

Create view PortfolioProject.PercentPopulationVaccinated as
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(Cast(dea.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM (
    SELECT * 
    FROM `portfolioproject-397108.PortfolioProject.CovidDeaths`
    WHERE continent IS NOT NULL
  ) dea
  JOIN (
    SELECT * 
    FROM `portfolioproject-397108.PortfolioProject.CovidVaccinations`
  ) vac
  ON dea.location = vac.location
  AND dea.date = vac.date
  WHERE dea.continent is not null
