# ADR-003: KPI Engine Parametrizado

## Status

Proposta

## Contexto

KPIs devem ser auditáveis e evolutivos.

## Decisão

Criar `ZTEWM_C360_KPI_DEF` para fórmula, origem, granularidade, owner e tolerância. Persistir resultados em `ZTEWM_C360_KPI`.

## Consequências

- Fórmulas documentadas.
- Tolerâncias auditáveis.
- Melhor governança.
