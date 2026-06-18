# EWM Cockpit 360º — Catálogo de Domínios e Valores

## Finalidade

Fonte única de verdade para valores válidos de cada domínio customizado.
Todo código ABAP, CDS, script de teste e configuração Fiori deve referenciar
esta lista. Não use valores fora deste catálogo sem atualizar este arquivo.

---

## ZDEWM_C360_STATUS — Status de documento operacional (HDR/ITEM)

Usado em: `ZTEWM_C360_HDR.STATUS_CODE`, `ZTEWM_C360_ITEM.STATUS_CODE`

| Valor | Descrição | Criticality Fiori |
|---|---|---|
| `OPEN` | Documento aberto, aguardando processamento | 2 (laranja) |
| `IN_PROGRESS` | Em processamento ativo | 1 (amarelo) |
| `BLOCKED` | Bloqueado por exceção ou dependência | 3 (vermelho) |
| `COMPLETED` | Processamento concluído com sucesso | 0 (verde) |
| `CANCELLED` | Cancelado manualmente | 0 (cinza — neutro) |
| `FAILED` | Falha definitiva após MAX_RETRY esgotado | 3 (vermelho) |

> Scripts de teste devem usar apenas estes valores. **Não usar**: DONE, PROC, DONE, OK, NOK.

---

## ZDEWM_C360_EXC_STATUS — Status de exceção operacional

Usado em: `ZTEWM_C360_EXC.STATUS_CODE`

| Valor | Descrição | Criticality Fiori |
|---|---|---|
| `OPEN` | Exceção aberta, aguardando tratamento | 3 (vermelho) |
| `IN_PROCESS` | Em tratamento (atribuída a responsável) | 2 (laranja) |
| `RESOLVED` | Resolvida com sucesso | 0 (verde) |
| `CANCELLED` | Cancelada (falso positivo, etc.) | 0 (neutro) |

---

## ZDEWM_C360_KPI_STATUS — Status de avaliação de KPI

Usado em: `ZTEWM_C360_KPI.STATUS_CODE`

| Valor | Descrição | StatusCriticality CDS | Cor Fiori |
|---|---|---|---|
| `OK` | Dentro da tolerância | 0 | Verde |
| `WARNING` | No limite da tolerância | 2 | Amarelo |
| `CRITICAL` | Fora da tolerância | 3 | Vermelho |

> **Padrão ADR-010**: criticality 0=Verde, 2=Amarelo, 3=Vermelho. **Não usar**: GREEN, YELLOW, RED.

---

## ZDEWM_C360_SNAP_STATUS — Status de execução de snapshot

Usado em: `ZTEWM_C360_SNAP_CTL.STATUS_CODE`

| Valor | Descrição |
|---|---|
| `RUNNING` | Snapshot em execução (com LOCK_FLAG='X') |
| `SUCCESS` | Concluído com sucesso |
| `ERROR` | Falha na execução |
| `LOCKED` | Tentativa bloqueada por execução concorrente |

---

## ZDEWM_C360_SEVERITY — Severidade de exceção

Usado em: `ZTEWM_C360_EXC.SEVERITY`, `ZTEWM_C360_SEV_RULE.SEVERITY`

| Valor | Descrição | SeverityCriticality CDS | SLA padrão |
|---|---|---|---|
| `CRITICAL` | Impacto operacional imediato | 3 | 2-4 horas |
| `HIGH` | Impacto alto, resolve hoje | 2 | 4-8 horas |
| `MEDIUM` | Impacto médio, resolve na semana | 1 | 24-48 horas |
| `LOW` | Impacto baixo, informativo | 0 | 72+ horas |

---

## ZDEWM_C360_PROCESS — Tipo de processo EWM

Usado em: `ZTEWM_C360_HDR.PROCESS_TYPE`, campo PROCESS de `Z_EWM_C360A`

| Valor | Descrição | App Fiori |
|---|---|---|
| `INBOUND` | Recebimento de mercadorias | ZC_EWM_C360_INBOUND |
| `OUTBOUND` | Expedição de mercadorias | ZC_EWM_C360_OUTBOUND |
| `HU` | Gestão de Handling Units | ZC_EWM_C360_HU |
| `WT` | Warehouse Tasks | ZC_EWM_C360_WT |
| `EXCEPTION` | Exceções operacionais | ZC_EWM_C360_EXCEPTION |
| `KPI` | Indicadores de desempenho | ZC_EWM_C360_KPI |
| `OVERVIEW` | Visão geral (Overview Page) | ZC_EWM_C360_OVERVIEW |
| `*` | Todos os processos (admin/audit) | — |

---

## ZDEWM_C360_SNAP_TYPE — Tipo de snapshot

Usado em: `ZTEWM_C360_SNAP_CTL.SNAP_TYPE`

| Valor | Descrição |
|---|---|
| `DELTA` | Incrementa desde último snapshot bem-sucedido |
| `FULL` | Releitura completa das tabelas EWM (ignora DELTA_FROM_TS) |

---

## ZDEWM_C360_REPROC_TYPE — Tipo de reprocessamento

Usado em: `ZTEWM_C360_ACTION.REPROC_TYPE`, campo `REPROC_T` de `Z_EWM_C360R`

| Valor | Descrição |
|---|---|
| `AUTO` | Disparado automaticamente por job/regra |
| `MANUAL` | Disparado por usuário via Fiori |
| `BULK` | Reprocessamento em lote de múltiplas exceções |

---

## Criticality Mapping — Padrão ADR-010

| Valor CDS | Significado | Cor Fiori |
|---|---|---|
| `0` | OK / neutro | Verde |
| `1` | Atenção / informativo | Amarelo claro |
| `2` | Aviso / warning | Laranja |
| `3` | Crítico / erro | Vermelho |

> Este padrão se aplica a todos os campos `*Criticality` em todas as CDS views do projeto.
> Mapeamentos incorretos (como CRITICAL→1 e OK→3, que eram bug CDS-04) violam este padrão.
