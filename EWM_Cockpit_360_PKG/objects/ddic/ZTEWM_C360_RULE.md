# ZTEWM_C360_RULE

## Finalidade

Parametrização de regras do cockpit sem hardcode.

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
| RULE_ID | ZDEWM_C360_E_RULE_ID | CHAR | 20 | X | X | ID da Regra |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | X | X | Processo ao qual se aplica |
| RULE_TYPE | CHAR | CHAR | 20 | X | X | Tipo de Regra (EXCEPTION, KPI, ROUTING, THRESHOLD) |
| LGNUM | ZDEWM_C360_E_LGNUM | CHAR | 4 | | | Warehouse (vazio = aplica a todos) |
| DESCRIPTION | CHAR | CHAR | 80 | | X | Descrição da Regra |
| PARAM_KEY | CHAR | CHAR | 30 | | X | Chave do Parâmetro |
| PARAM_VALUE | CHAR | CHAR | 100 | | X | Valor do Parâmetro |
| ACTIVE_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Regra Ativa (X = ativa) |
| VALID_FROM | DATS | DATS | 8 | | | Válida a partir de |
| VALID_TO | DATS | DATS | 8 | | | Válida até |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + RULE_ID + PROCESS_TYPE + RULE_TYPE`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | PROCESS_TYPE + RULE_TYPE + ACTIVE_FLAG | Leitura de regras ativas por processo |
| Z02 | LGNUM + RULE_TYPE + ACTIVE_FLAG | Regras específicas por warehouse |

## Dependências

- Data Elements: ZDEWM_C360_E_RULE_ID, ZDEWM_C360_E_PROCESS, ZDEWM_C360_E_FLAG
- Classes: ZCL_EWM_C360_EXCEPTION_ENGINE, ZCL_EWM_C360_KPI_ENGINE
- Manutenção: SM30 view para ZTEWM_C360_RULE (administrador)

## Critérios de aceite

- Tabela ativa com todos os campos.
- SM30 ou Fiori maintenance configurado para administradores.
- ACTIVE_FLAG e VALID_FROM/TO validados nas engines.
- Nenhuma regra hardcoded nas classes — toda parametrização lida desta tabela.
- Sequência de transporte: customizing separado de workbench.
