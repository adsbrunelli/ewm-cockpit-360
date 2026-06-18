# Data Elements e Domínios: EWM Cockpit 360º

## Domínios compartilhados

| Domínio | Tipo ABAP | Compr. | Descrição |
|---|---|---|---|
| ZDEWM_C360_LGNUM | CHAR | 4 | Número do warehouse |
| ZDEWM_C360_DOC_ID | CHAR | 20 | Identificador único de documento |
| ZDEWM_C360_GUID | RAW | 16 | GUID interno (UUID) |
| ZDEWM_C360_PROCESS | CHAR | 20 | Tipo de processo (INBOUND, OUTBOUND, HU, WT) |
| ZDEWM_C360_SEVERITY | CHAR | 10 | Severidade: LOW, MEDIUM, HIGH, CRITICAL |
| ZDEWM_C360_STATUS | CHAR | 4 | Status genérico de registro |
| ZDEWM_C360_FLAG | CHAR | 1 | Flag booleano (X = ativo / ' ' = inativo) |
| ZDEWM_C360_KPI_ID | CHAR | 20 | Identificador do KPI |
| ZDEWM_C360_ACTION_ID | CHAR | 30 | Identificador de ação Fiori |
| ZDEWM_C360_RULE_ID | CHAR | 20 | Identificador de regra parametrizada |
| ZDEWM_C360_EXC_TYPE | CHAR | 20 | Tipo de exceção |
| ZDEWM_C360_VALUE | DEC | 15,3 | Valor decimal genérico para KPI/tolerância |
| ZDEWM_C360_FORMULA | CHAR | 255 | Fórmula textual de cálculo |
| ZDEWM_C360_OWNER | CHAR | 12 | Responsável/owner (user ID SAP) |
| ZDEWM_C360_SLA_H | INT4 | 4 | SLA em horas |
| ZDEWM_C360_COUNTER | INT4 | 4 | Contador genérico |
| ZDEWM_C360_OBJECT_NAME | CHAR | 30 | Nome de objeto SAP (tabela, classe, serviço) |
| ZDEWM_C360_OBJECT_TYPE | CHAR | 10 | Tipo de objeto (DDIC, CDS, CLASS, SRV, FIORI, ROLE) |
| ZDEWM_C360_GRANULARITY | CHAR | 10 | Granularidade: HOURLY, DAILY, WEEKLY |
| ZDEWM_C360_MSG_TEXT | CHAR | 255 | Texto de mensagem técnica ou funcional |
| ZDEWM_C360_RESULT | CHAR | 10 | Resultado de execução: SUCCESS, ERROR, PARTIAL |

## Data Elements compartilhados

| Data Element | Domínio | Descrição no campo |
|---|---|---|
| ZDEWM_C360_E_LGNUM | ZDEWM_C360_LGNUM | Número do Warehouse |
| ZDEWM_C360_E_DOC_ID | ZDEWM_C360_DOC_ID | ID do Documento |
| ZDEWM_C360_E_GUID | ZDEWM_C360_GUID | GUID Interno |
| ZDEWM_C360_E_PROCESS | ZDEWM_C360_PROCESS | Tipo de Processo |
| ZDEWM_C360_E_SEVERITY | ZDEWM_C360_SEVERITY | Severidade |
| ZDEWM_C360_E_STATUS | ZDEWM_C360_STATUS | Status |
| ZDEWM_C360_E_FLAG | ZDEWM_C360_FLAG | Flag Ativo |
| ZDEWM_C360_E_KPI_ID | ZDEWM_C360_KPI_ID | ID do KPI |
| ZDEWM_C360_E_ACTION_ID | ZDEWM_C360_ACTION_ID | ID da Ação |
| ZDEWM_C360_E_RULE_ID | ZDEWM_C360_RULE_ID | ID da Regra |
| ZDEWM_C360_E_EXC_TYPE | ZDEWM_C360_EXC_TYPE | Tipo de Exceção |
| ZDEWM_C360_E_VALUE | ZDEWM_C360_VALUE | Valor Decimal |
| ZDEWM_C360_E_FORMULA | ZDEWM_C360_FORMULA | Fórmula de Cálculo |
| ZDEWM_C360_E_OWNER | ZDEWM_C360_OWNER | Owner/Responsável |
| ZDEWM_C360_E_SLA_H | ZDEWM_C360_SLA_H | SLA em Horas |
| ZDEWM_C360_E_COUNTER | ZDEWM_C360_COUNTER | Contador |
| ZDEWM_C360_E_OBJ_NAME | ZDEWM_C360_OBJECT_NAME | Nome do Objeto |
| ZDEWM_C360_E_OBJ_TYPE | ZDEWM_C360_OBJECT_TYPE | Tipo do Objeto |
| ZDEWM_C360_E_GRANUL | ZDEWM_C360_GRANULARITY | Granularidade |
| ZDEWM_C360_E_MSG_TEXT | ZDEWM_C360_MSG_TEXT | Texto de Mensagem |
| ZDEWM_C360_E_RESULT | ZDEWM_C360_RESULT | Resultado da Execução |

## Campos de auditoria padrão (reutilizados)

Estes campos usam data elements SAP standard:

| Campo | Data Element SAP | Descrição |
|---|---|---|
| CREATED_BY | UNAME | Criado por |
| CREATED_AT | TIMESTAMP | Criado em (UTC) |
| CHANGED_BY | UNAME | Alterado por |
| CHANGED_AT | TIMESTAMP | Alterado em (UTC) |

## Sequência de transporte

1. Domínios (ZDEWM_C360_*)
2. Data Elements (ZDEWM_C360_E_*)
3. Tabelas (ZTEWM_C360_*)
