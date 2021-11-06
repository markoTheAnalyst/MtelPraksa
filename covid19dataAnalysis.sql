--Pregled podataka

SELECT
    *
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY
    3,
    4;

SELECT
    *
FROM
    covid_vacinations
ORDER BY
    3,
    4;

-- odabir podataka koje cemo koristiti

SELECT
    location,
    dan,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY
    1,
    2;

-- ukupni slucajevi vs ukupne smrti po zemlji
-- pokazuje vjerovatnocu smrti u slucaju zaraze kovidom
SELECT
    location,
    dan,
    total_cases,
    total_deaths,
    ( total_deaths / total_cases ) * 100 AS death_percentage
FROM
    covid_deaths
WHERE
    location LIKE '%Peru%'
    AND continent IS NOT NULL
ORDER BY
    1,
    2;

-- ukupni slucajevi vs populacija
-- pokazuje ukupni procenat populacije koji je dobio korronu
SELECT
    location,
    dan,
    population,
    total_cases,
    ( total_cases / population ) * 100 AS percent_population_infected
FROM
    covid_deaths
--where location like '%Peru%'
ORDER BY
    1,
    2;

-- trazimo zemlje sa najvecim brojem zarazenim po glavi stanovnika

SELECT
    location,
    population,
    MAX(total_cases)                    AS maksimum,
    MAX(total_cases / population) * 100 AS percent_population_infected
FROM
    covid_deaths
--where location like '%Peru%'
GROUP BY
    location,
    population
ORDER BY
    4 DESC;

-- trazimo zemlje sa najvecom smrtnoscu po glavi stanovnika

SELECT
    location,
    MAX(total_deaths) AS total_death_count
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
    AND total_deaths IS NOT NULL
GROUP BY
    location
ORDER BY
    2 DESC;
    
    
-- PO KONTINENTU

-- prikaz kontinenata sa najvecom smrtnoscu po glavi stanovnika

SELECT
    continent,
    MAX(total_deaths) AS total_death_count
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY
    continent
ORDER BY
    2 DESC;
    
-- globalni brojevi

SELECT
    SUM(new_cases)                         AS total_cases,
    SUM(new_deaths)                        AS total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS deathpercentage
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY
    1,
    2;
    
-- ukupna populacija vs vakcinacije
-- procenat populacije koji je primio barem jednu covid vakcinu

SELECT
    dea.continent,
    dea.location,
    dea.dan,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations)
    OVER(PARTITION BY dea.location
         ORDER BY
             dea.location, dea.dan
    ) AS rollingpeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
FROM
         covid_deaths dea
    JOIN covid_vacinations vac ON dea.location = vac.location
                                   AND dea.dan = vac.dan
WHERE
    dea.continent IS NOT NULL
ORDER BY
    2,
    3;
    
    
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, dan, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.dan) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_deaths dea
Join covid_vacinations vac
	On dea.location = vac.location
	and dea.dan = vac.dan
where dea.continent is not null 
--order by 2,3
)
Select  Continent, Location, dan, Population, New_Vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

--DROP Table if exists Percent_Population_Vaccinated
Create Table Percent_Population_Vaccinated
(
Continent varchar2(50),
Location varchar2(100),
dan date,
Population number(38),
New_vaccinations number(38),
Rolling_People_Vaccinated number(38)
);
select * from Percent_Population_Vaccinated;


Insert into Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.dan) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From covid_deaths dea
Join covid_vacinations vac
	On dea.location = vac.location
	and dea.dan = vac.dan
--where dea.continent is not null 
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From Percent_Population_Vaccinated;




-- kreiranje pogleda(virtuelne tabele)

Create View Percent_Population_Vaccinated_V as
Select dea.continent, dea.location, dea.dan, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.dan) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covid_deaths dea
Join covid_vacinations vac
	On dea.location = vac.location
	and dea.dan = vac.dan
where dea.continent is not null ;

select * from Percent_Population_Vaccinated_V;