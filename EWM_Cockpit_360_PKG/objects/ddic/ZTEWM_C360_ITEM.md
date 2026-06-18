# ZTEWM_C360_ITEM

## Finalidade

Itens operacionais vinculados ao cabeçalho: WT, HU, delivery item, produto, quantidades e status parcial.

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
| DOC_ID | ZDEWM_C360_E_DOC_ID | CHAR | 20 | X | X | ID do Documento (FK para HDR) |
| ITEM_NO | NUMC | NUMC | 6 | X | X | Número do Item |
| ITEM_TYPE | CHAR | CHAR | 10 | | X | Tipo do Item |
| MATNR | MATNR | CHAR | 18 | | | Material |
| CHARG | CHARG_D | CHAR | 10 | | | Lote |
| LGPLA | /SCWM/LGPLA | CHAR | 18 | | | Posição de Armazenagem |
| LGTYP | /SCWM/LGTYP | CHAR | 3 | | | Tipo de Armazenagem |
| QTY_PLANNED | ZDEWM_C360_E_VALUE | DEC | 15,3 | | | Quantidade Planejada |
| QTY_ACTUAL | ZDEWM_C360_E_VALUE | DEC | 15,3 | | | Quantidade Realizada |
| UOM | MEINS | UNIT | 3 | | | Unidade de Medida |
| STATUS_CODE | ZDEWM_C360_E_STATUS | CHAR | 4 | | X | Status do Item |
| HAS_EXCEPTION | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Possui Exceção Associada |
| EXC_ID | ZDEWM_C360_E_DOC_ID | CHAR | 20 | | | FK para ZTEWM_C360_EXC |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |

## Chave primária

`MANDT + LGNUM + DOC_ID + ITEM_NO`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | LGNUM + DOC_ID | JOIN com cabeçalho |
| Z02 | LGNUM + MATNR + STATUS_CODE | Consultas por material e status |
| Z03 | LGNUM + HAS_EXCEPTION | Itens com exceção aberta |

## Dependências

- Tabela pai: ZTEWM_C360_HDR (LGNUM + DOC_ID)
- Data Elements: ZDEWM_C360_E_LGNUM, ZDEWM_C360_E_DOC_ID, ZDEWM_C360_E_STATUS
- CDS: ZI_EWM_C360_ITEM
- Classe consumidora: ZCL_EWM_C360_READER_ITEM

## Critérios de aceite

- Tabela ativa com todos os campos.
- FK para HDR validada em classe (sem constraint SAP).
- Índices Z01 e Z02 ativos e testados.
- Campos de quantidade DEC 15,3 sem perda de precisão.
- Sequência de transporte: após ZTEWM_C360_HDR.
