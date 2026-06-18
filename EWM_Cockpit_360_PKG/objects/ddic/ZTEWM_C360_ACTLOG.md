# ZTEWM_C360_ACTLOG

## Finalidade

Auditoria persistente das ações executadas via Fiori/handler.

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
| LOG_ID | ZDEWM_C360_E_DOC_ID | CHAR | 20 | X | X | ID único do log (GUID gerado) |
| ACTION_ID | ZDEWM_C360_E_ACTION_ID | CHAR | 30 | | X | ID da Ação Executada |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | | X | Tipo de Processo |
| DOC_ID | ZDEWM_C360_E_DOC_ID | CHAR | 20 | | | ID do Documento Alvo |
| ITEM_NO | NUMC | NUMC | 6 | | | Item do Documento Alvo |
| EXEC_USER | UNAME | CHAR | 12 | | X | Usuário que Executou a Ação |
| EXEC_TIMESTAMP | TIMESTAMP | DEC | 15 | | X | Timestamp da Execução (UTC) |
| RESULT | ZDEWM_C360_E_RESULT | CHAR | 10 | | X | Resultado: SUCCESS, ERROR, PARTIAL |
| MSG_TEXT | ZDEWM_C360_E_MSG_TEXT | CHAR | 255 | | | Mensagem Técnica/Funcional |
| MESSAGE_ID | SYMSGID | CHAR | 20 | | | Classe de Mensagem SAP |
| MESSAGE_NO | SYMSGNO | NUMC | 3 | | | Número da Mensagem SAP |
| IP_ADDRESS | CHAR | CHAR | 45 | | | IP do Cliente (rastreabilidade) |
| SESSION_ID | CHAR | CHAR | 32 | | | ID de Sessão Fiori |

## Chave primária

`MANDT + LGNUM + LOG_ID`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | LGNUM + EXEC_USER + EXEC_TIMESTAMP | Auditoria por usuário e período |
| Z02 | LGNUM + ACTION_ID + RESULT | Análise de ações por resultado |
| Z03 | DOC_ID + ACTION_ID | Rastreabilidade por documento |

## Dependências

- Data Elements: ZDEWM_C360_E_ACTION_ID, ZDEWM_C360_E_RESULT, ZDEWM_C360_E_MSG_TEXT
- CDS: ZI_EWM_C360_ACTLOG
- Classe: ZCL_EWM_C360_LOG, ZCL_EWM_C360_ACTION_DISPATCHER
- Tabela de ações: ZTEWM_C360_ACTION (ACTION_ID)

## Regras obrigatórias

- Registros não podem ser deletados por usuário operacional.
- Retenção mínima: 12 meses em tabela ativa, arquivamento após 90 dias para tabela histórica.
- LOG_ID gerado via CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC.

## Critérios de aceite

- Tabela ativa com todos os campos.
- Índices Z01, Z02, Z03 ativos.
- LOG_ID único por execução.
- Nenhum handler de ação executa sem gravar nesta tabela.
- Sequência de transporte: após ZTEWM_C360_ACTION.
