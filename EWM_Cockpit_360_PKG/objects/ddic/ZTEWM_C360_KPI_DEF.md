# ZTEWM_C360_KPI_DEF

## Finalidade

Definição mestre dos KPIs.

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
| KPI_ID | ZDEWM_C360_E_KPI_ID | CHAR | 20 | X | X | ID único do KPI |
| KPI_NAME | CHAR | CHAR | 60 | | X | Nome do KPI |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | | X | Processo ao qual pertence |
| FORMULA | ZDEWM_C360_E_FORMULA | CHAR | 255 | | X | Fórmula de cálculo (textual) |
| DATA_SOURCE | CHAR | CHAR | 60 | | X | Origem dos dados (tabela/CDS/função) |
| GRANULARITY | ZDEWM_C360_E_GRANUL | CHAR | 10 | | X | Granularidade: HOURLY, DAILY, WEEKLY |
| TOLERANCE_PCT | ZDEWM_C360_E_VALUE | DEC | 5,2 | | X | Tolerância em % para status WARNING |
| CRITICAL_PCT | ZDEWM_C360_E_VALUE | DEC | 5,2 | | X | Tolerância em % para status CRITICAL |
| OWNER | ZDEWM_C360_E_OWNER | CHAR | 12 | | X | Responsável pelo KPI |
| UNIT | CHAR | CHAR | 10 | | | Unidade do Valor (%, un, min, etc.) |
| ACTIVE_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | KPI Ativo |
| CALC_CLASS | CHAR | CHAR | 30 | | X | Classe ABAP responsável pelo cálculo |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + KPI_ID`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | PROCESS_TYPE + ACTIVE_FLAG | Leitura de KPIs ativos por processo |

## Dependências

- Data Elements: ZDEWM_C360_E_KPI_ID, ZDEWM_C360_E_FORMULA, ZDEWM_C360_E_GRANUL
- Tabela de valores: ZTEWM_C360_KPI (FK por KPI_ID)
- Classes: ZCL_EWM_C360_KPI_ENGINE
- Manutenção: SM30 ou Fiori maintenance app para administradores

## Critérios de aceite

- Tabela ativa com manutenção SM30.
- FORMULA, DATA_SOURCE e CALC_CLASS obrigatórios para KPI ativo.
- KPI_ID referenciado em ZTEWM_C360_KPI sem orphan records.
- Sequência de transporte: antes de ZTEWM_C360_KPI.
