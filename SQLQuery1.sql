SELECT * From
	PortfolioProject..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY
	3,4

--select *
--from PtfolioProject..CovidVaccinations
--order by 3,4

SELECT
	Location, date, total_cases, new_cases, total_deaths, population
From
	PortfolioProject..CovidDeaths
ORDER BY
	1,2

SELECT
	Location, date, total_cases, total_deaths, (CAST (total_deaths AS INT) / CAST (total_cases AS INT)) * 100 as DeathPercentage
From
	PortfolioProject..CovidDeaths
Where
	Location like '%states%'
AND 
	continent IS NOT NULL
ORDER BY 1,2

SELECT Location, date, total_cases, population, (CAST (total_cases AS INT) / CAST (population AS INT)) * 100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
ORDER BY 1,2

SELECT
	Location,
	population,
	MAX (total_cases) as HighestInfectionCount,
	Max (CAST(total_cases AS BIGINT) / CAST(population AS BIGINT)) * 100 AS PercentagePopulationInfected 
From 
	PortfolioProject..CovidDeaths
GROUP BY
	Location,
	population
ORDER BY
	PercentagePopulationInfected desc
	
SELECT
	continent, MAX(CAST(Total_deaths AS INT)) as TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT 
	continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	TotalDeathCount desc


SELECT 
    date, 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS INT)) AS total_deaths, 
    CASE 
        WHEN SUM(New_Cases) = 0 THEN 0
        ELSE SUM(CAST(new_deaths AS INT)) / SUM(New_Cases) * 100
    END AS DeathPercentage
FROM
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    1,2

SELECT
	dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	On dea.Location = vac.Location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	2,3

With PopvsVac (continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
	Select dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.Location = vac.Location
		and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 