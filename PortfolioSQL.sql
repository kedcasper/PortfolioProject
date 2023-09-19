--This is COVID Vaccinations Table
SELECT TOP(10) *
FROM [dbo].[CovidVaccinations]

--This is COVID Deaths Table
SELECT TOP(10) *
FROM [dbo].[Covid_Deaths]

--Select Data we are going to be using
SELECT 
    location, 
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM [dbo].[Covid_Deaths]
ORDER BY 1,2 --This orders by location, then date (first abd second column)

--Looking at Total Cases vs Total Deaths (how many cases per death)
-- Shows likelihood of dying if you had COVID in your country
SELECT 
    location, 
    date,
    total_cases,
    total_deaths,
    (1.00 * total_deaths / total_cases) * 100 AS DeathPercentage
FROM [dbo].[Covid_Deaths]
WHERE location LIKE '%states%' -- double quotes are column names, single quotes for values
ORDER BY 1,2

--Looking at Total Cases vs Population (compares pop. with total cases)
--Shows what percent of population got COVID
SELECT 
    location, 
    date,
    total_cases,
    population,
    (1.00 * total_cases / population) * 100 AS PopulationCOVID
FROM [dbo].[Covid_Deaths]
WHERE location = 'United States'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
--What countries have highest infection Rate (total cases)
SELECT 
    location, 
    MAX(total_cases) AS HighestInfectionCount,
    population,
    MAX((1.00 * total_cases / population)) * 100 AS PercentPopulationInfected
FROM [dbo].[Covid_Deaths]
--WHERE location = 'United States' --commenting this out in the meantime!
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC --puts highest total cases first

--Showing Countries with Highest Death Count per Population
--How many poeple died 
SELECT 
    location, 
    MAX(cast(total_deaths AS int)) AS TotalDeathCount --this CAST feature changes data type in SQL query!!!(didnt need to be good to know!)
FROM [dbo].[Covid_Deaths]
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY TotalDeathCount DESC
--We see with the above query that sometimes Location is the continent and Continent is Null
--Query below filters out this NULL to give only Countries!
SELECT 
    location, 
    MAX(total_deaths) AS TotalDeathCount
FROM [dbo].[Covid_Deaths]
--WHERE location = 'United States'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing Continents and with Highest Death Count
SELECT 
    continent, 
    MAX(total_deaths) AS TotalDeathCount
FROM [dbo].[Covid_Deaths]
--WHERE location = 'United States'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
--Sum of New Cases by Date
SELECT  
    date,
    SUM(new_cases)
FROM [dbo].[Covid_Deaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total cases, total deaths and Ratio by date (each day)
SELECT  
    date,
    SUM(new_cases) AS Total_NewCases,
    SUM(new_deaths) AS Total_NewDeaths,
    (1.00 * SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathtoCasePercent
FROM [dbo].[Covid_Deaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total cases and total deaths with Ratio 
SELECT  
    SUM(new_cases) AS Total_NewCases,
    SUM(new_deaths) AS Total_NewDeaths,
    (1.00 * SUM(new_deaths) / SUM(new_cases)) * 100 AS DeathtoCasePercent
FROM [dbo].[Covid_Deaths]
WHERE continent IS NOT NULL
ORDER BY 1,2


--Joining the tables on location and date
SELECT *
FROM [dbo].[Covid_Deaths] AS dea
JOIN [dbo].[CovidVaccinations] AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date


--Looking at Total Population vs Total Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location,
    dea.date) AS RollingPeopleVaccinated,
    --(RollingPeopleVaccinated / population) * 100 (cant just call new column name)
--partition by aka break up by "location", this summed all new vacs in that location
--adding ORDER BY location and date, DATE seperates it out and gives rolling count
FROM [dbo].[Covid_Deaths] AS dea
JOIN [dbo].[CovidVaccinations] AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated --this works now when WHERE is commented out
CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    date DATETIME,
    population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location,
        dea.date) AS RollingPeopleVaccinated
        --(RollingPeopleVaccinated / population) * 100 (cant just call new column name, USE CTE)
FROM [dbo].[Covid_Deaths] AS dea
JOIN [dbo].[CovidVaccinations] AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL, when this is commented out we get an error

SELECT *, (1.00 * RollingPeopleVaccinated/Population) * 100 AS PercentVac
FROM #PercentPopulationVaccinated


-- USE CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location,
        dea.date) AS RollingPeopleVaccinated
        --(RollingPeopleVaccinated / population) * 100 (cant just call new column name, USE CTE)
    FROM [dbo].[Covid_Deaths] AS dea
    JOIN [dbo].[CovidVaccinations] AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (1.00 * RollingPeopleVaccinated/Population) * 100 AS PercentVac
FROM PopVsVac

--Create a View to store data for later visualations
CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location,
        dea.date) AS RollingPeopleVaccinated
        --(RollingPeopleVaccinated / population) * 100 (cant just call new column name, USE CTE)
FROM [dbo].[Covid_Deaths] AS dea
JOIN [dbo].[CovidVaccinations] AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--Command completes successfully and table under Views folder

SELECT * 
FROM PercentPopVaccinated