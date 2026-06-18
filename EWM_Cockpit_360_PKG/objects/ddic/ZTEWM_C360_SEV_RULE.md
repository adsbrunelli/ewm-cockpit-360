# ZTEWM_C360_SEV_RULE

## Finalidade

Matriz de severidade por processo, exceção, SLA, impacto e tolerância operacional.

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
| EXC_TYPE | ZDEWM_C360_E_EXC_TYPE | CHAR | 20 | X | X | Tipo de Exceção |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | X | X | Tipo de Processo |
| LGNUM | ZDEWM_C360_E_LGNUM | CHAR | 4 | X | X | Warehouse (ou '*' para todos) |
| SEVERITY | ZDEWM_C360_E_SEVERITY | CHAR | 10 | | X | Severidade resultante: LOW, MEDIUM, HIGH, CRITICAL |
| SLA_HOURS | ZDEWM_C360_E_SLA_H | INT4 | 4 | | X | SLA em horas para esta combinação |
| ESCALATION_H | ZDEWM_C360_E_SLA_H | INT4 | 4 | | | Horas para escalonamento automático |
| ESCALATION_TO | ZDEWM_C360_E_OWNER | CHAR | 12 | | | Usuário/role para escalonamento |
| ACTIVE_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Regra ativa |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + EXC_TYPE + PROCESS_TYPE + LGNUM`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | PROCESS_TYPE + SEVERITY + ACTIVE_FLAG | Busca por severidade no engine |

## Lógica de resolução

O Severity Engine busca a regra na ordem: LGNUM específico → LGNUM = '*'. A regra mais específica tem precedência.

## Dependências

- Data Elements: ZDEWM_C360_E_EXC_TYPE, ZDEWM_C360_E_SEVERITY, ZDEWM_C360_E_SLA_H
- Classes: ZCL_EWM_C360_EXCEPTION_ENGINE
- Manutenção: SM30 para administradores do cockpit

## Critérios de aceite

- Tabela ativa com manutenção SM30.
- Lógica de fallback LGNUM='*' testada e validada.
- SEVERITY e SLA_HOURS obrigatórios para toda regra ativa.
- Sequência de transporte: customizing separado.
