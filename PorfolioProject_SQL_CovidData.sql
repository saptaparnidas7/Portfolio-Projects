SELECT * 
FROM 
PortfolioProject..CovidDeaths
where continent != 'Null'
ORDER BY 3,4 


--SELECT * 
--FROM 
--PortfolioProject..CovidVaccinations
-- 


-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths , population
From PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if someone contracts covid in this particular country

SELECT location, date, total_cases, total_deaths , (total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Canada' and total_deaths != 'NULL'
ORDER BY 1,2


-- Looking at Total Cases Vs Population
-- Shows likelihood of dying if someone contracts covid in this particular country

SELECT location, date, total_cases, Population, (total_cases/Population)* 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like 'India' 
ORDER BY 1,2


-- Looking at countries with highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/Population))* 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths 
where continent != 'Null'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Continents with the Highest Death Count per population 

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths 
where continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT location, date, total_cases, total_deaths , (total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent != 'NULL'
and total_deaths != 'NULL'
ORDER BY 1,2


-- Global Death percent 

Select 
--date, 
SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Look at total populations Vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
JOIN 
PortfolioProject..CovidVaccinations vac
ON 
dea.location = vac.location 
AND
dea.date = vac.date
where dea.continent is not null 
order by 2,3 



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
