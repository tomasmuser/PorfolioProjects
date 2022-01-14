USE Portfolio_Project_Covid

SELECT *
FROM Portfolio_Project_Covid..covid_deaths
ORDER BY location, date

-- Data that we are going to be starting with

SELECT 
	continent,
	location,
	date,
	population,
	total_cases,
	new_cases,
	total_deaths,
	new_deaths
FROM Portfolio_Project_Covid..covid_deaths
ORDER BY location, date

-- Countries with Highest Infection Rate compared to Population

SELECT 
	location,
	population,
	SUM(new_cases) AS highest_infection_count,
	ROUND((SUM(new_cases)/population)*100, 2, 1) AS percent_population_infected
FROM Portfolio_Project_Covid..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- Countries with Highest Death Rate compared to Population

SELECT 
	location,
	population,
	MAX(total_deaths) AS highest_death_count,
	ROUND((MAX(total_deaths)/population)*100, 2, 1) AS percent_population_death
FROM Portfolio_Project_Covid..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_population_death DESC

-- Countries with Highest Death Rate compared to Infections

SELECT 
	location,
	population,
	MAX(total_cases) AS total_cases,
	MAX(total_deaths) AS highest_death_count,
	ROUND((MAX(total_deaths)/MAX(total_cases))*100, 2, 1) AS percent_infected_death
FROM Portfolio_Project_Covid..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_infected_death DESC

-- Accumulative by Continent

SELECT 
	location,
	MAX(population) AS population,
	MAX(total_cases) AS total_cases,
	ROUND((MAX(total_cases)/MAX(population))*100 ,2 ,1) AS percent_population_infected,
	MAX(total_deaths) AS total_deaths,
	ROUND((MAX(total_deaths)/MAX(population))*100 ,2 ,1) AS percent_population_death
FROM Portfolio_Project_Covid..covid_deaths
WHERE 
	continent is NULL AND 
	location != 'International' AND 
	location != 'Lower middle income' AND
	location != 'Upper middle income' AND
	location != 'High income' AND
	location != 'Low income' AND
	location != 'European Union' AND
	location != 'World'
GROUP BY location
ORDER BY total_deaths DESC

-- Pencentage of popuation fully vaccinated by country

SELECT 
	cdea.location,
	cdea.population,
	ROUND((MAX(cvac.people_fully_vaccinated)/MAX(cdea.population))*100, 2, 1) AS percent_population_fully_vaccinated
FROM Portfolio_Project_Covid..covid_deaths cdea
JOIN Portfolio_Project_Covid..covid_vaccinations cvac
	ON cdea.location = cvac.location AND cdea.date = cvac.date
WHERE cdea.continent IS NOT NULL
GROUP BY cdea.location, cdea.population
ORDER BY percent_population_fully_vaccinated DESC

-- Population not fully vaccinated by country

SELECT 
	cdea.location,
	cdea.population,
	MAX(cdea.population) - MAX(cvac.people_fully_vaccinated) AS population_not_fully_vaccinated
FROM Portfolio_Project_Covid..covid_deaths cdea
JOIN Portfolio_Project_Covid..covid_vaccinations cvac
	ON cdea.location = cvac.location AND cdea.date = cvac.date
WHERE cdea.continent IS NOT NULL
GROUP BY cdea.location, cdea.population
ORDER BY population_not_fully_vaccinated DESC

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
	cdea.location,
	cdea.population,
	ROUND((MAX(cvac.people_vaccinated)/MAX(cdea.population))*100, 2, 1) AS percent_population_vaccinated
FROM Portfolio_Project_Covid..covid_deaths cdea
JOIN Portfolio_Project_Covid..covid_vaccinations cvac
	ON cdea.location = cvac.location AND cdea.date = cvac.date
WHERE cdea.continent IS NOT NULL
GROUP BY cdea.location, cdea.population
ORDER BY percent_population_vaccinated DESC

-- Shows Population that has not recieved any Covid Vaccine

SELECT 
	cdea.location,
	cdea.population,
	MAX(cdea.population) - MAX(cvac.people_vaccinated) AS percent_population_vaccinated
FROM Portfolio_Project_Covid..covid_deaths cdea
JOIN Portfolio_Project_Covid..covid_vaccinations cvac
	ON cdea.location = cvac.location AND cdea.date = cvac.date
WHERE cdea.continent IS NOT NULL
GROUP BY cdea.location, cdea.population
ORDER BY percent_population_vaccinated DESC

-- Creating view for location Argentina

GO
CREATE OR ALTER VIEW vw_argentina AS
	SELECT
		cdea.location,
		cdea.population,
		CAST(cdea.date AS date) AS date,
		cdea.total_cases,
		cdea.total_deaths,
		cdea.icu_patients,
		cvac.total_tests,
		cvac.total_vaccinations,
		people_vaccinated,
		people_fully_vaccinated,
		total_boosters
	FROM Portfolio_Project_Covid..covid_deaths cdea
	JOIN Portfolio_Project_Covid..covid_vaccinations cvac
		ON cdea.location = cvac.location AND cdea.date = cvac.date
	WHERE cdea.location = 'argentina'
GO