# ADR-002: CDS Online versus Tabela Snapshot

## Status

**Aceito** — 2026-06-18 · Decisor: Arquiteto técnico do projeto

## Contexto

Alguns dados EWM são voláteis e leves (detalhe de WT, status de documento). Outros são pesados ou precisam de histórico (KPIs agregados, aging, exceções resolvidas, diagnósticos). Consultar tudo online via CDS em tempo real comprometeria a performance do cockpit.

## Decisão

| Estratégia | Quando usar | Exemplos |
|---|---|---|
| CDS online | Dados voláteis, detalhe navegável, baixo volume | Status de documento, detalhe de WT |
| Snapshot (ZTEWM_C360_HDR/ITEM) | Dados operacionais com volume alto ou aging | Documentos abertos por warehouse |
| Snapshot KPI (ZTEWM_C360_KPI) | Agregações calculadas com fórmula | Taxa de produtividade, lead time |
| Histórico (ZTEWM_C360_EXC) | Dados que precisam de rastreabilidade pós-encerramento | Exceções resolvidas |

**Controle de delta:** ZTEWM_C360_SNAP_CTL registra DELTA_FROM_TS e DELTA_TO_TS. Jobs buscam apenas registros alterados desde o último snapshot bem-sucedido. Janela de retenção de snapshot: 90 dias ativo + arquivamento.

## Alternativas consideradas

- CDS online para tudo: rejeitado por risco de timeout em warehouses com alto volume.
- Snapshot full a cada execução: rejeitado por custo de I/O e sobrecarga de jobs.

## Consequências

- Redução significativa de carga em consultas pesadas do cockpit.
- Maior rastreabilidade histórica de KPIs e exceções.
- Necessidade de jobs de snapshot com controle de lock e delta (ZCL_EWM_C360_SNAPSHOT_RUNNER).
- Risco: dados de snapshot podem ter latência de até 1 ciclo de job (geralmente 15 min).

## Critérios de revisão

Revisar se latência de snapshot se tornar crítica para o negócio (considerar evento-driven via qRFC).
