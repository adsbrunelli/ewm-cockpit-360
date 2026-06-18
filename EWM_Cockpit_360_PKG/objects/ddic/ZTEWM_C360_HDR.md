# ZTEWM_C360_HDR

## Finalidade

Cabeçalho operacional dos documentos monitorados pelo cockpit. Armazena a chave principal, processo, warehouse, status e metadados de rastreabilidade de cada documento capturado.

## Camada

DDIC — Tabela transparente

## Status

Especificado

## Campos

| Campo | Data Element | Tipo | Compr. | K | Obrig. | Descrição |
|---|---|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | X | X | Mandante |
| LGNUM | ZDEWM_C360_E_LGNUM | CHAR | 4 | X | X | Número do Warehouse |
| DOC_ID | ZDEWM_C360_E_DOC_ID | CHAR | 20 | X | X | ID do Documento (chave do processo) |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | | X | Tipo de Processo (INBOUND, OUTBOUND, HU, WT) |
| DOC_TYPE | CHAR | CHAR | 10 | | X | Tipo do Documento SAP (EWM standard) |
| STATUS_CODE | ZDEWM_C360_E_STATUS | CHAR | 4 | | X | Status do Documento |
| PRIORITY | ZDEWM_C360_E_SEVERITY | CHAR | 10 | | | Prioridade Operacional |
| OWNER | ZDEWM_C360_E_OWNER | CHAR | 12 | | | Responsável pelo Documento |
| REFERENCE_DOC | ZDEWM_C360_E_DOC_ID | CHAR | 20 | | | Documento de Referência (ERP/EWM) |
| OPEN_DATE | DATS | DATS | 8 | | | Data de Abertura |
| OPEN_TIME | TIMS | TIMS | 6 | | | Hora de Abertura |
| DUE_DATE | DATS | DATS | 8 | | | Data Limite / Vencimento |
| CLOSED_DATE | DATS | DATS | 8 | | | Data de Encerramento |
| HAS_EXCEPTION | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Possui Exceção Aberta |
| SNAPSHOT_TS | TIMESTAMP | DEC | 15 | | | Timestamp do Último Snapshot |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + LGNUM + DOC_ID`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | LGNUM + PROCESS_TYPE + STATUS_CODE | Filtro principal do cockpit por processo e status |
| Z02 | LGNUM + OPEN_DATE + HAS_EXCEPTION | Consultas de aging e exceções abertas |
| Z03 | LGNUM + DUE_DATE | Alertas de vencimento |

## Dependências

- Domínios: ZDEWM_C360_LGNUM, ZDEWM_C360_DOC_ID, ZDEWM_C360_PROCESS, ZDEWM_C360_STATUS
- Data Elements: ZDEWM_C360_E_LGNUM, ZDEWM_C360_E_DOC_ID, ZDEWM_C360_E_PROCESS
- CDS: ZI_EWM_C360_HDR (interface view)
- Classe consumidora: ZCL_EWM_C360_READER_HDR, ZCL_EWM_C360_SNAPSHOT_RUNNER
- Tabela filha: ZTEWM_C360_ITEM (JOIN por LGNUM + DOC_ID)

## Critérios de aceite

- Tabela ativa no DDIC com todos os campos.
- Chave primária não permite duplicidade.
- Índices Z01 e Z02 criados e testados com volume de produção.
- CDS ZI_EWM_C360_HDR ativa e associada.
- Usada por snapshot runner sem erro.
- Sequência de transporte: após domínios e data elements.

## Manutenção

Não exposta via SM30. Populada exclusivamente por jobs de snapshot e handlers ABAP.
