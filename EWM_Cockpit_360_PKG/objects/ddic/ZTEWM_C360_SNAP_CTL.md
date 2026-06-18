# ZTEWM_C360_SNAP_CTL

## Finalidade

Controle de execução dos snapshots delta/full.

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
| SNAP_TYPE | CHAR | CHAR | 10 | X | X | Tipo: FULL ou DELTA |
| PROCESS_TYPE | ZDEWM_C360_E_PROCESS | CHAR | 20 | X | X | Processo alvo do snapshot |
| SNAP_ID | ZDEWM_C360_E_DOC_ID | CHAR | 20 | | X | ID único do snapshot (GUID) |
| STATUS_CODE | ZDEWM_C360_E_STATUS | CHAR | 4 | | X | Status: RUNNING, SUCCESS, ERROR, LOCKED |
| STARTED_AT | TIMESTAMP | DEC | 15 | | X | Início da Execução (UTC) |
| FINISHED_AT | TIMESTAMP | DEC | 15 | | | Fim da Execução (UTC) |
| RECORDS_READ | ZDEWM_C360_E_COUNTER | INT4 | 4 | | | Registros Lidos |
| RECORDS_WRITTEN | ZDEWM_C360_E_COUNTER | INT4 | 4 | | | Registros Gravados |
| DELTA_FROM_TS | TIMESTAMP | DEC | 15 | | | Timestamp Inicial do Delta |
| DELTA_TO_TS | TIMESTAMP | DEC | 15 | | | Timestamp Final do Delta |
| LOCK_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Snapshot em Execução (lock) — 'X' = bloqueado |
| LOCK_BY | UNAME | CHAR | 12 | | | Usuário/Job que detém o lock (preenchido junto com LOCK_FLAG) |
| LOCK_SINCE | TIMESTAMP | DEC | 15 | | | Timestamp UTC de aquisição do lock |
| ERROR_MSG | ZDEWM_C360_E_MSG_TEXT | CHAR | 255 | | | Mensagem de Erro |
| JOB_NAME | CHAR | CHAR | 32 | | | Nome do Job SM36 |
| EXEC_USER | UNAME | CHAR | 12 | | X | Usuário/Job Executor |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |

## Chave primária

`MANDT + LGNUM + SNAP_TYPE + PROCESS_TYPE`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | LGNUM + STATUS_CODE + STARTED_AT | Monitoramento de snapshots recentes |
| Z02 | LGNUM + PROCESS_TYPE + FINISHED_AT | Controle de último snapshot bem-sucedido |

## Regras de controle

### Lock atômico (DDI-01 — padrão obrigatório)

O lock **não pode** ser implementado como SELECT + UPDATE separados (check-then-act), pois dois processos paralelos podem ambos ler LOCK_FLAG = '' e ambos gravar 'X', causando dupla execução.

O padrão correto usa UPDATE condicional — o banco de dados serializa escritas concorrentes na mesma linha; apenas um UPDATE encontrará WHERE LOCK_FLAG = '' verdadeiro:

```abap
" CORRETO — UPDATE atômico com condição na chave
UPDATE ztewm_c360_snap_ctl
  SET lock_flag  = 'X'
      lock_by    = sy-uname
      lock_since = <timestamp_utc>
  WHERE mandt        = sy-mandt
    AND lgnum        = is_request-lgnum
    AND snap_type    = is_request-snap_type
    AND process_type = is_request-process_type
    AND lock_flag    = ''.   " <-- condição que torna a operação atômica

rv_acquired = xsdbool( sy-dbcnt = 1 ).
" sy-dbcnt = 1 → lock adquirido
" sy-dbcnt = 0 → outro processo já havia bloqueado
```

```abap
" ERRADO — race condition: dois processos leem '' antes de qualquer UPDATE
SELECT SINGLE lock_flag INTO lv_flag
  FROM ztewm_c360_snap_ctl
  WHERE lgnum = ... AND snap_type = ... AND process_type = ...
IF lv_flag = ''. " <-- janela de concorrência aqui
  UPDATE ... SET lock_flag = 'X'.
ENDIF.
```

### Regras adicionais

- Job deve gravar STATUS_CODE = 'RUNNING' e LOCK_FLAG = 'X' antes de iniciar, via padrão atômico acima.
- Em caso de erro, gravar STATUS_CODE = 'ERROR', limpar LOCK_FLAG/LOCK_BY/LOCK_SINCE e registrar ERROR_MSG.
- RELEASE_LOCK deve ser chamado em qualquer desvio — inclusive dentro de CATCH de ZCX_EWM_C360_SNAPSHOT.
- DELTA_FROM_TS = DELTA_TO_TS do snapshot anterior bem-sucedido.
- Lock abandonado (LOCK_FLAG = 'X' há mais de N minutos sem STATUS = 'RUNNING' ativo) deve ser limpo por job de watchdog — ver RUNBOOK_SNAPSHOT.

## Dependências

- Classes: ZCL_EWM_C360_SNAPSHOT_RUNNER
- Jobs SM36: um job por PROCESS_TYPE
- Tabelas populadas: ZTEWM_C360_HDR, ZTEWM_C360_ITEM

## Critérios de aceite

- Tabela ativa com controle de lock funcional.
- Dois snapshots concorrentes para o mesmo LGNUM+PROCESS_TYPE são bloqueados.
- Índice Z02 permite recuperar o último snapshot com sucesso para cálculo do delta.
- Sequência de transporte: antes dos jobs.
