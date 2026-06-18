# ZTEWM_C360_ACTION

## Finalidade

Ações, semantic object/action, handlers, métodos e autorização.

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
| ACTION_ID | ZDEWM_C360_E_ACTION_ID | CHAR | 30 | X | X | ID único da Ação |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | | X | Processo ao qual a ação pertence |
| ACTION_NAME | CHAR | CHAR | 60 | | X | Nome funcional da Ação |
| HANDLER_CLASS | CHAR | CHAR | 30 | | X | Classe ABAP Handler (ZCL_EWM_C360_ACTION_*) |
| HANDLER_METHOD | CHAR | CHAR | 30 | | X | Método do Handler |
| AUTH_OBJECT | CHAR | CHAR | 10 | | X | Objeto de Autorização SAP para esta ação |
| AUTH_FIELD | CHAR | CHAR | 10 | | | Campo de autorização relevante |
| AUTH_VALUE | CHAR | CHAR | 10 | | | Valor de autorização exigido |
| IS_CRITICAL | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Ação Crítica (exige log obrigatório) |
| IS_BULK | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Permite execução em massa |
| CONFIRM_REQUIRED | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Exige confirmação do usuário na UI |
| ACTIVE_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Ação Ativa |
| SEMANTIC_OBJ | CHAR | CHAR | 30 | | | Semantic Object Fiori |
| FIORI_ACTION | CHAR | CHAR | 20 | | | Action Fiori correspondente |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + ACTION_ID`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | PROCESS_TYPE + ACTIVE_FLAG | Leitura de ações ativas por processo |
| Z02 | HANDLER_CLASS + ACTIVE_FLAG | Validação de handlers registrados |

## Dependências

- Data Elements: ZDEWM_C360_E_ACTION_ID, ZDEWM_C360_E_PROCESS, ZDEWM_C360_E_FLAG
- Tabela de log: ZTEWM_C360_ACTLOG (ACTION_ID)
- Classes: ZCL_EWM_C360_ACTION_DISPATCHER
- Manutenção: SM30 para administradores

## Critérios de aceite

- Tabela ativa com manutenção SM30.
- Toda ação com IS_CRITICAL = 'X' grava obrigatoriamente em ZTEWM_C360_ACTLOG.
- HANDLER_CLASS e HANDLER_METHOD existem e são invocáveis.
- AUTH_OBJECT referenciado deve ser criado antes via SE11.
- Sequência de transporte: antes de roles PFCG.
