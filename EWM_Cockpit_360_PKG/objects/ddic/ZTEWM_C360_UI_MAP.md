# ZTEWM_C360_UI_MAP

## Finalidade

Mapeamento técnico de telas, seções, botões e extensões Fiori.

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
| UI_ID | ZDEWM_C360_E_RULE_ID | CHAR | 20 | X | X | ID do Elemento de UI |
| SCREEN_ID | CHAR | CHAR | 30 | X | X | ID da Tela (OVERVIEW, INBOUND, EXCEPTIONS...) |
| ELEMENT_TYPE | CHAR | CHAR | 20 | | X | Tipo: CARD, BUTTON, COLUMN, FILTER, SECTION |
| ELEMENT_ID | CHAR | CHAR | 30 | | X | ID do Elemento (nome técnico no XML/JS) |
| LABEL_TEXT | CHAR | CHAR | 80 | | X | Texto do Label/Título |
| ACTION_ID | ZDEWM_C360_E_ACTION_ID | CHAR | 30 | | | Ação vinculada (FK para ZTEWM_C360_ACTION) |
| CDS_FIELD | CHAR | CHAR | 30 | | | Campo CDS mapeado a este elemento |
| VISIBLE_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Elemento visível por padrão |
| REQUIRED_ROLE | CHAR | CHAR | 30 | | | Role necessária para visualizar |
| SEQUENCE_NO | ZDEWM_C360_E_COUNTER | INT4 | 4 | | | Ordem de exibição |
| ACTIVE_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Mapeamento ativo |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + UI_ID + SCREEN_ID`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | SCREEN_ID + ACTIVE_FLAG + SEQUENCE_NO | Leitura ordenada dos elementos por tela |

## Uso

Esta tabela serve como registro técnico de mapeamento entre UI Fiori e backend (CDS + Actions). Não controla layout diretamente — isso é feito via annotations CDS e manifest.json. Serve para rastreabilidade, suporte e diagnóstico.

## Dependências

- Tabela de ações: ZTEWM_C360_ACTION (ACTION_ID)
- CDS: ZI_EWM_C360_UI_MAP
- Manutenção: SM30 ou Fiori maintenance app

## Critérios de aceite

- Tabela ativa com todos os campos.
- ACTION_ID existente em ZTEWM_C360_ACTION quando preenchido.
- SCREEN_ID alinhado com as telas Fiori documentadas.
- Sequência de transporte: após ZTEWM_C360_ACTION.
