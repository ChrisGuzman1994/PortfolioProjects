
Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows percentage of death if contracted 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where Location like '%states%'
Order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population contracted Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject.dbo.CovidDeaths
--Where Location like '%states%'
Order by 1,2


-- Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From PortfolioProject.dbo.CovidDeaths
--Where Location like '%states%'
Group by location, population
Order by InfectionPercentage desc

-- Showing countries with hightest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Broken down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by date
Order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as

(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac

-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date) as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated