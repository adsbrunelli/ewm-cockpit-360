# ZTEWM_C360_EXC

## Finalidade

Registro de exceções operacionais e técnicas classificadas pelo Exception/Severity Engine.

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
| EXC_ID | ZDEWM_C360_E_DOC_ID | CHAR | 20 | X | X | ID da Exceção (GUID gerado) |
| DOC_ID | ZDEWM_C360_E_DOC_ID | CHAR | 20 | | | ID do Documento Origem |
| ITEM_NO | NUMC | NUMC | 6 | | | Número do Item Origem |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | | X | Tipo de Processo |
| EXC_TYPE | ZDEWM_C360_E_EXC_TYPE | CHAR | 20 | | X | Tipo da Exceção |
| SEVERITY | ZDEWM_C360_E_SEVERITY | CHAR | 10 | | X | Severidade: LOW, MEDIUM, HIGH, CRITICAL |
| STATUS_CODE | ZDEWM_C360_E_STATUS | CHAR | 4 | | X | Status: OPEN, IN_PROCESS, RESOLVED, CANCELLED |
| ROOT_CAUSE | ZDEWM_C360_E_MSG_TEXT | CHAR | 255 | | | Causa Raiz |
| MESSAGE_ID | SYMSGID | CHAR | 20 | | | Classe de Mensagem SAP |
| MESSAGE_NO | SYMSGNO | NUMC | 3 | | | Número da Mensagem |
| SLA_DUE_AT | TIMESTAMP | DEC | 15 | | | Vencimento do SLA (UTC) |
| SLA_HOURS | ZDEWM_C360_E_SLA_H | INT4 | 4 | | | SLA em Horas |
| OWNER | ZDEWM_C360_E_OWNER | CHAR | 12 | | | Responsável pela Resolução |
| RESOLVED_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Exceção Resolvida (X = sim) |
| RESOLVED_AT | TIMESTAMP | DEC | 15 | | | Resolvida em (UTC) |
| RESOLVED_BY | UNAME | CHAR | 12 | | | Resolvida por |
| REPROC_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Elegível para Reprocessamento |
| RETRY_COUNT | ZDEWM_C360_E_COUNTER | INT4 | 4 | | | Tentativas de Reprocessamento |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + LGNUM + EXC_ID`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | LGNUM + SEVERITY + STATUS_CODE | Filtro principal do painel de exceções |
| Z02 | LGNUM + PROCESS_TYPE + STATUS_CODE | Filtro por processo e status |
| Z03 | LGNUM + SLA_DUE_AT + RESOLVED_FLAG | Alertas de SLA vencendo |
| Z04 | DOC_ID + ITEM_NO | Rastreabilidade ao documento origem |

## Dependências

- Data Elements: ZDEWM_C360_E_LGNUM, ZDEWM_C360_E_EXC_TYPE, ZDEWM_C360_E_SEVERITY
- CDS: ZI_EWM_C360_EXC, ZC_EWM_C360_EXCEPTION
- Classes: ZCL_EWM_C360_EXCEPTION_ENGINE, ZCL_EWM_C360_REPROCESSOR
- Tabela relacionada: ZTEWM_C360_SEV_RULE (para cálculo de severidade)

## Critérios de aceite

- Tabela ativa com todos os campos.
- Índices Z01, Z02 e Z03 ativos.
- EXC_TYPE e SEVERITY validados contra domínios.
- SLA_DUE_AT calculado automaticamente pelo engine com base em SLA_HOURS.
- Histórico mantido: RESOLVED_FLAG = X não exclui o registro.
- Sequência de transporte: após ZTEWM_C360_SEV_RULE.
