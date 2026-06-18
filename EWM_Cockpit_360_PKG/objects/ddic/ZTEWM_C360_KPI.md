# ZTEWM_C360_KPI

## Finalidade

Valores calculados dos KPIs do cockpit por warehouse, processo, período e granularidade.

## Camada

DDIC

## Status

Planejado

## Status

Especificado

## Campos

| Campo | Data Element | Tipo | Compr. | K | Obrig. | Descrição |
|---|---|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | X | X | Mandante |
| LGNUM | ZDEWM_C360_E_LGNUM | CHAR | 4 | X | X | Número do Warehouse |
| KPI_ID | ZDEWM_C360_E_KPI_ID | CHAR | 20 | X | X | ID do KPI (FK para KPI_DEF) |
| PERIOD_DATE | DATS | DATS | 8 | X | X | Data do Período |
| GRANULARITY | ZDEWM_C360_E_GRANUL | CHAR | 10 | X | X | Granularidade: HOURLY, DAILY, WEEKLY |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | X | X | Tipo de Processo |
| ACTUAL_VALUE | ZDEWM_C360_E_VALUE | DEC | 15,3 | | X | Valor Realizado |
| TARGET_VALUE | ZDEWM_C360_E_VALUE | DEC | 15,3 | | | Meta do KPI |
| TOLERANCE_PCT | ZDEWM_C360_E_VALUE | DEC | 5,2 | | | Tolerância em % |
| STATUS_CODE | ZDEWM_C360_E_STATUS | CHAR | 4 | | X | Status: OK, WARNING, CRITICAL |
| CALC_TIMESTAMP | TIMESTAMP | DEC | 15 | | X | Timestamp do Cálculo (UTC) |
| CALC_BY | UNAME | CHAR | 12 | | | Calculado por (job/usuário) |
| SNAP_REF | ZDEWM_C360_E_DOC_ID | CHAR | 20 | | | Referência ao Snapshot de Origem |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |

## Chave primária

`MANDT + LGNUM + KPI_ID + PERIOD_DATE + GRANULARITY + PROCESS_TYPE`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | LGNUM + PERIOD_DATE + STATUS_CODE | Dashboard KPI por data e status |
| Z02 | LGNUM + KPI_ID + GRANULARITY | Séries históricas por KPI |

## Dependências

- Tabela mestre: ZTEWM_C360_KPI_DEF (KPI_ID)
- Data Elements: ZDEWM_C360_E_KPI_ID, ZDEWM_C360_E_VALUE, ZDEWM_C360_E_GRANUL
- CDS: ZI_EWM_C360_KPI, ZC_EWM_C360_KPI, ZC_EWM_C360_ANA_KPI
- Classe: ZCL_EWM_C360_KPI_ENGINE

## Critérios de aceite

- Tabela ativa com chave composta sem duplicidade.
- STATUS_CODE calculado automaticamente pelo engine com base em TOLERANCE_PCT.
- Índices Z01 e Z02 ativos.
- Registros históricos mantidos (sem delete por período).
- Sequência de transporte: após ZTEWM_C360_KPI_DEF.
