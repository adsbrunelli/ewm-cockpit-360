# ZTEWM_C360_DEP

## Finalidade

Controle de dependências entre objetos técnicos.

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
| OBJ_NAME | ZDEWM_C360_E_OBJ_NAME | CHAR | 30 | X | X | Nome do Objeto Dependente |
| OBJ_TYPE | ZDEWM_C360_E_OBJ_TYPE | CHAR | 10 | X | X | Tipo do Objeto (DDIC, CDS, CLASS, SRV, FIORI, ROLE) |
| DEPENDS_ON | ZDEWM_C360_E_OBJ_NAME | CHAR | 30 | X | X | Depende deste Objeto |
| DEP_TYPE | ZDEWM_C360_E_OBJ_TYPE | CHAR | 10 | | X | Tipo do Objeto do Qual Depende |
| DEP_REASON | CHAR | CHAR | 80 | | X | Motivo da Dependência |
| SEQUENCE_NO | ZDEWM_C360_E_COUNTER | INT4 | 4 | | X | Número de sequência de transporte |
| IS_HARD_DEP | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Dependência obrigatória (X) ou recomendada |
| VALIDATED_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Dependência validada antes do transporte |
| VALIDATED_BY | UNAME | CHAR | 12 | | | Validado por |
| VALIDATED_AT | TIMESTAMP | DEC | 15 | | | Validado em (UTC) |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |

## Chave primária

`MANDT + OBJ_NAME + OBJ_TYPE + DEPENDS_ON + DEP_TYPE`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | SEQUENCE_NO + IS_HARD_DEP | Ordenação de transporte |
| Z02 | VALIDATED_FLAG + IS_HARD_DEP | Controle de dependências pendentes |

## Dependências

- Classes: ZCL_EWM_C360_DEPENDENCY_CHECK (valida esta tabela antes do transporte)
- Alimentação: manual por arquiteto + automática via script de análise

## Critérios de aceite

- Tabela ativa.
- ZCL_EWM_C360_DEPENDENCY_CHECK valida VALIDATED_FLAG = 'X' em toda dependência IS_HARD_DEP antes de autorizar transporte.
- Sequência de transporte: antes dos transportes de outros objetos.
