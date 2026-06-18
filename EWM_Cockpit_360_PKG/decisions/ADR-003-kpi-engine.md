# ADR-003: KPI Engine Parametrizado

## Status

**Aceito** — 2026-06-18 · Decisor: Arquiteto técnico do projeto

## Contexto

KPIs do cockpit precisam ser auditáveis, evolutivos e sem hardcode. Novos KPIs devem poder ser adicionados sem alteração de código ABAP. Cada KPI tem fórmula, origem, granularidade, tolerância e owner distintos.

## Decisão

**Catálogo de KPIs parametrizado em ZTEWM_C360_KPI_DEF:**
- Cada KPI tem ID, nome, fórmula textual, classe ABAP calculadora, granularidade e tolerâncias (WARNING e CRITICAL em %).
- Nenhuma fórmula hardcoded em ABAP — toda lógica de cálculo em classe específica referenciada por CALC_CLASS.

**Persistência de resultados em ZTEWM_C360_KPI:**
- Valores calculados com timestamp, status (OK/WARNING/CRITICAL) e referência ao snapshot de origem.
- Histórico mantido — sem delete por período, apenas arquivamento após 90 dias.

**Engine de cálculo: ZCL_EWM_C360_KPI_ENGINE**
- Lê catálogo de KPIs ativos por processo.
- Instancia a classe calculadora via CALC_CLASS.
- Persiste resultado com status calculado pela tolerância.
- Grava log de execução em SLG1.

## Alternativas consideradas

- KPIs hardcoded por processo ABAP: rejeitado por falta de governança e necessidade de transporte a cada novo KPI.
- KPIs calculados apenas em CDS analítica: rejeitado por não suportar histórico, tolerância parametrizada e rastreabilidade de cálculo.

## Consequências

- Fórmulas documentadas e auditáveis por SM30.
- Novo KPI = nova entrada em ZTEWM_C360_KPI_DEF + nova classe calculadora, sem alterar engine.
- Custo: cada KPI precisa de classe ABAP própria.

## Critérios de revisão

Revisar se o número de KPIs superar 50 (considerar framework de expressão parametrizada).
