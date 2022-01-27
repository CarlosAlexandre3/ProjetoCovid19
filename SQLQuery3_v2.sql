Select *
From ProjetoSQL..CovidDeaths
order by 3,4

-- Select *
-- From ProjetoSQL..CovidVaccinations
-- order by 3,4

-- Selecionar os dados que vou usar

Select Location, date, total_cases, new_cases, total_deaths, population
From ProjetoSQL..CovidDeaths
order by 1,2

-- Case 1 - Analisando o total de casos versus o total de mortes

Select Location, 
	CONVERT(DATE,date,103) AS Datas
	,CONVERT(DECIMAL(15,3), total_cases) AS Casos
	,CONVERT(DECIMAL(15,3), total_deaths) AS Mortes
	,CONVERT(DECIMAL(15,3), (CONVERT(DECIMAL(15,3), total_deaths) /CONVERT(DECIMAL(15,3), total_cases))*100) AS PorcentagemMortes
	FROM ProjetoSQL..CovidDeaths
	Where population > 0 and continent is not null and location = 'Brazil'
	order by 1,2


-- Case 2 - Analisando o Total de Casos versus População
-- Mostra qual a porcentagem da população pegou Covid19

Select Location, 
	CONVERT(DATE,date,103) AS Datas
	,CONVERT(DECIMAL(15,3), population) AS Populacao
	,CONVERT(DECIMAL(15,3), total_cases) AS Casos
	,CONVERT(DECIMAL(15,3), (CONVERT(DECIMAL(15,3), total_cases) /CONVERT(DECIMAL(15,3), population))*100) AS PorcentagemMortos
	FROM ProjetoSQL..CovidDeaths
	Where population > 0 and continent is not null and location = 'Brazil'
	order by 1,2

-- Analisando por País com maior taxa de infecção em comparação com a população

Select Location,
	CONVERT(DATE,date,103) AS Datas
	,CONVERT(DECIMAL, population) AS Populacao
	,CONVERT(DECIMAL(15,3), MAX(total_cases)) AS ContagemdeInfeccao
	,CONVERT(DECIMAL(15,3), (CONVERT(DECIMAL(15,3), MAX(total_cases)) /CONVERT(DECIMAL(15,3), population))*100) AS PercentualPopulacaoInfectada
	FROM ProjetoSQL..CovidDeaths
	Where population > 0 and continent is not null and location = 'Brazil'
	Group by Location, Population, Date
	order by PercentualPopulacaoInfectada desc

-- Analisando Países com maior contagem de mortes por população

Select Location, 
	MAX(CAST(Total_deaths as int)) as TotalMortes
	FROM ProjetoSQL..CovidDeaths
	Where continent is not null 
	Group by Location
	order by TotalMortes desc

-- ANALISES POR CONTINENTES
-- Analisando continentes com a maior contagem de mortes por população


-- group by por Continente

Select Continent, 
	MAX(CAST(Total_deaths as int)) as TotalMortes
	FROM ProjetoSQL..CovidDeaths
	Where continent is not null 
	Group by continent
	order by TotalMortes desc

-- group by por País

Select Location, 
	MAX(CAST(Total_deaths as int)) as TotalMortes
	FROM ProjetoSQL..CovidDeaths
	Where continent is not null
	Group by location
	order by TotalMortes desc


Select Location, 
	CONVERT(DATE,date,103) AS Datas
	,CAST(population as int) AS Populacao
	,CONVERT(DECIMAL(15,3), MAX(total_deaths)) AS TotalMortes
	,CONVERT(DECIMAL(15,3), (CONVERT(DECIMAL(15,3), MAX(total_cases)) /CAST(population AS int))*100) AS PercentualPopulacaoInfectada
	FROM ProjetoSQL..CovidDeaths
	Where population > 0 and continent is not null and location = 'Brazil'
	Group by Location, Population, Date
	order by TotalMortes desc

-- Utilizando a função CAST e alterando o valor da classe para FLOAT para que o resultado seja diferente de zero

Select Location, 
	CONVERT(DATE,date,103) AS Datas
	,CAST(population as float) AS Populacao
	,MAX(CAST(total_deaths as float)) AS TotalMortes
	,MAX(CAST(total_cases as float))/CAST(population AS float)*100 AS PercentualPopulacaoInfectada
	FROM ProjetoSQL..CovidDeaths
	Where population > 0 and continent is not null and location = 'Brazil'
	Group by Location, Population, Date
	order by TotalMortes desc

-- ANALISES DOS NÚMEROS GLOBAIS

Select  
	--CONVERT(DATE,date,103) AS Datas
	SUM(CAST(new_cases as float)) AS Casos
	,SUM(CAST(new_deaths as float)) AS Mortos
	,SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as int))*100 AS PorcentagemMortos
	FROM ProjetoSQL..CovidDeaths
	Where new_cases > 0 and continent is not null --and location = 'Brazil'
	--Group by date
	order by 1,2


-- JUNTANDO AS BASES COVID DEATHS E CODIV VACCINATIONS
-- Analisando Total da População e Vacinados

Select *
	From ProjetoSQL..CovidDeaths dea
	JOIN ProjetoSQL..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjetoSQL..CovidDeaths dea
Join ProjetoSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE (Common Table Expression) Result Set Temporário

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjetoSQL..CovidDeaths dea
Join ProjetoSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *
From PopvsVac

-- TEMP TABLE (Tabela Temporária)

DROP Table If exists #PercentPopulationVaccinated
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
,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjetoSQL..CovidDeaths dea
Join ProjetoSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Criando View para armazenar dados para visualizações posteriores

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjetoSQL..CovidDeaths dea
Join ProjetoSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated