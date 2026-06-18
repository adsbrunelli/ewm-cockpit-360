# App: ZEWM_C360_KPI — Dashboard de KPIs

## Identificação

| Atributo | Valor |
|----------|-------|
| App ID | ZEWM_C360_KPI |
| Padrão Fiori | List Report + Object Page |
| Semantic Object | ZEWM_C360_KPI |
| CDS de consumo | ZC_EWM_C360_KPI |
| Role mínima | Z_EWM_C360_EXEC |

---

## List Report

### Barra de filtros

| Campo | Label | Tipo | Default |
|-------|-------|------|---------|
| Lgnum | Warehouse | Value Help | Warehouse do usuário |
| KpiId | KPI | Input | — |
| ProcessType | Processo | Value Help | — |
| Granularity | Granularidade | Dropdown (HOUR, DAY, WEEK, MONTH) | DAY |
| PeriodDate | Período | DateRange | Hoje - 30 dias |
| StatusCode | Status | Dropdown | RED, YELLOW |

### Colunas da tabela

| Posição | Campo | Label | Criticality | Largura |
|---------|-------|-------|-------------|---------|
| 1 | KpiName | KPI | — | 20rem |
| 2 | ProcessType | Processo | — | 10rem |
| 3 | ActualValue | Valor Real | StatusCriticality | 10rem |
| 4 | TargetValue | Meta | — | 10rem |
| 5 | DeviationPct | Desvio % | StatusCriticality | 10rem |
| 6 | StatusCode | Status | StatusCriticality | 8rem |
| 7 | PeriodDate | Período | — | 10rem |
| 8 | Granularity | Granular. | — | 8rem |
| 9 | CalcTimestamp | Atualizado em | — | 14rem |
| 10 | Owner | Owner | — | 12rem |

### Toolbar

| Ação | Tipo | Condição | Role |
|------|------|----------|------|
| Exportar para Excel | Standard Fiori | Sempre | Qualquer |
| Recalcular KPI | Custom Button | 1 linha selecionada | Z_EWM_C360_SUPPORT |

---

## Object Page — KPI

### Header

| Elemento | Campo |
|----------|-------|
| Título | KpiName |
| Subtítulo | ProcessType |
| DataPoint 1 | ActualValue (criticality = StatusCriticality) |
| DataPoint 2 | DeviationPct (criticality = StatusCriticality) |
| DataPoint 3 | StatusCode |

### Facets

#### Facet 1 — Definição do KPI

| Campo | Label |
|-------|-------|
| KpiId | ID Técnico |
| KpiName | Nome |
| ProcessType | Processo |
| Formula | Fórmula de Cálculo |
| DataSource | Fonte de Dados |
| CalcClass | Classe de Cálculo |
| Unit | Unidade |
| TolerancePct | Tolerância (%) |
| Owner | Owner |

#### Facet 2 — Resultado Atual

| Campo | Label |
|-------|-------|
| ActualValue | Valor Real |
| TargetValue | Meta |
| DeviationPct | Desvio % |
| StatusCode | Status |
| CalcTimestamp | Calculado em |
| PeriodDate | Período |
| Granularity | Granularidade |

#### Facet 3 — Histórico (série temporal)

```
Tipo    : Micro Chart (Line)
Fonte   : ZC_EWM_C360_KPI (mesmo KpiId, últimas N entradas por PeriodDate)
Eixo X  : PeriodDate
Eixo Y  : ActualValue
Linha de referência: TargetValue (linha pontilhada)
Criticality: StatusCriticality por ponto
N       : 30 (configurável em ZTEWM_C360_CUST, chave KPI_HISTORY_POINTS)
```

#### Facet 4 — Log de Recálculos (ZC_EWM_C360_ACTLOG filtrado por KpiId)

| Coluna | Label |
|--------|-------|
| ActionType | Ação |
| ActionResult | Resultado |
| ActionBy | Executado por |
| ActionAt | Data/Hora |

### Ações do Object Page

| Ação | Label | Condição | Role |
|------|-------|----------|------|
| Recalcular | Recalcular KPI | StatusCode = 'RED' OR 'YELLOW' | Z_EWM_C360_SUPPORT |

---

## Critérios de aceite

- [ ] Filtro default StatusCode pré-seleciona RED e YELLOW (KPIs fora do limite)
- [ ] Granularidade padrão = DAY; trocar para HOUR recarrega lista com dados horários
- [ ] DeviationPct negativo (abaixo da meta) exibe criticality = 1 (vermelho)
- [ ] Facet Histórico renderiza micro chart com pelo menos 2 pontos de dados
- [ ] Linha de referência (meta) visível no micro chart como linha pontilhada
- [ ] Botão Recalcular aciona `ZCL_EWM_C360_KPI_ENGINE->CALCULATE` via action OData
- [ ] Após recalcular, DataPoints e micro chart atualizam sem refresh manual
