# ZIF_EWM_C360_SNAPSHOT_RUNNER — Interface do Runner de Snapshot

## Finalidade

Contrato para execução de snapshots delta e full conforme ADR-007. Controla lock de execução via ZTEWM_C360_SNAP_CTL, lê dados EWM standard e persiste em ZTEWM_C360_HDR/ITEM.

## Implementada por

- `ZCL_EWM_C360_SNAPSHOT_RUNNER` (implementação real)

## Tipos locais da interface

```abap
TYPES:
  BEGIN OF ty_snap_request,
    lgnum        TYPE zdewm_c360_e_lgnum,
    snap_type    TYPE char10,           " FULL / DELTA
    process_type TYPE zdewm_c360_e_process,
    requested_by TYPE uname,
  END OF ty_snap_request,

  BEGIN OF ty_snap_result,
    snap_id        TYPE zdewm_c360_e_doc_id,
    records_read   TYPE zdewm_c360_e_counter,
    records_written TYPE zdewm_c360_e_counter,
    status_code    TYPE zdewm_c360_e_status,
    error_msg      TYPE zdewm_c360_e_msg_text,
    started_at     TYPE timestamp,
    finished_at    TYPE timestamp,
  END OF ty_snap_result.
```

## Métodos

### ACQUIRE_LOCK
Tenta adquirir lock em ZTEWM_C360_SNAP_CTL de forma **atômica**.
Retorna `abap_true` se o lock foi adquirido, `abap_false` se já estava bloqueado.

O método usa UPDATE condicional (WHERE LOCK_FLAG = '') em vez de SELECT + UPDATE separados,
eliminando a race condition onde dois processos paralelos poderiam ambos ler '' e ambos gravar 'X'.
O banco de dados serializa a escrita; `sy-dbcnt = 1` confirma que este processo foi o único a colocar o lock.

```abap
METHODS acquire_lock
  IMPORTING
    is_request        TYPE ty_snap_request
  RETURNING
    VALUE(rv_acquired) TYPE abap_bool.
```

**Implementação de referência (ZCL_EWM_C360_SNAPSHOT_RUNNER):**
```abap
METHOD zif_ewm_c360_snapshot_runner~acquire_lock.
  DATA lv_now TYPE timestamp.
  GET TIME STAMP FIELD lv_now.

  UPDATE ztewm_c360_snap_ctl
    SET lock_flag  = abap_true
        lock_by    = sy-uname
        lock_since = lv_now
    WHERE mandt        = sy-mandt
      AND lgnum        = is_request-lgnum
      AND snap_type    = is_request-snap_type
      AND process_type = is_request-process_type
      AND lock_flag    = abap_false.   " condição atômica

  rv_acquired = xsdbool( sy-dbcnt = 1 ).
ENDMETHOD.
```

### RELEASE_LOCK
Libera o lock e atualiza STATUS_CODE e FINISHED_AT.

```abap
METHODS release_lock
  IMPORTING
    is_request  TYPE ty_snap_request
    is_result   TYPE ty_snap_result.
```

### GET_DELTA_RANGE
Retorna o intervalo de timestamp para o delta (FROM = último snapshot sucesso, TO = agora).

```abap
METHODS get_delta_range
  IMPORTING
    is_request      TYPE ty_snap_request
  EXPORTING
    ev_from_ts      TYPE timestamp
    ev_to_ts        TYPE timestamp.
```

### RUN
Executa o snapshot completo: lock → leitura EWM → persistência → release.

```abap
METHODS run
  IMPORTING
    is_request       TYPE ty_snap_request
  RETURNING
    VALUE(rs_result) TYPE ty_snap_result
  RAISING
    zcx_ewm_c360_snapshot.
```

### RUN_ALL_PROCESSES
Executa snapshot para todos os processos ativos de um warehouse.

```abap
METHODS run_all_processes
  IMPORTING
    iv_lgnum    TYPE zdewm_c360_e_lgnum
    iv_snap_type TYPE char10 DEFAULT 'DELTA'
  RAISING
    zcx_ewm_c360_snapshot.
```

## Esqueleto ABAP completo (SE24)

```abap
INTERFACE zif_ewm_c360_snapshot_runner
  PUBLIC.

  TYPES:
    BEGIN OF ty_snap_request,
      lgnum        TYPE zdewm_c360_e_lgnum,
      snap_type    TYPE char10,
      process_type TYPE zdewm_c360_e_process,
      requested_by TYPE uname,
    END OF ty_snap_request,

    BEGIN OF ty_snap_result,
      snap_id         TYPE zdewm_c360_e_doc_id,
      records_read    TYPE zdewm_c360_e_counter,
      records_written TYPE zdewm_c360_e_counter,
      status_code     TYPE zdewm_c360_e_status,
      error_msg       TYPE zdewm_c360_e_msg_text,
      started_at      TYPE timestamp,
      finished_at     TYPE timestamp,
    END OF ty_snap_result.

  METHODS:
    acquire_lock
      IMPORTING
        is_request         TYPE ty_snap_request
      RETURNING
        VALUE(rv_acquired) TYPE abap_bool,

    release_lock
      IMPORTING
        is_request TYPE ty_snap_request
        is_result  TYPE ty_snap_result,

    get_delta_range
      IMPORTING
        is_request TYPE ty_snap_request
      EXPORTING
        ev_from_ts TYPE timestamp
        ev_to_ts   TYPE timestamp,

    run
      IMPORTING
        is_request       TYPE ty_snap_request
      RETURNING
        VALUE(rs_result) TYPE ty_snap_result
      RAISING
        zcx_ewm_c360_snapshot,

    run_all_processes
      IMPORTING
        iv_lgnum     TYPE zdewm_c360_e_lgnum
        iv_snap_type TYPE char10 DEFAULT 'DELTA'
      RAISING
        zcx_ewm_c360_snapshot.

ENDINTERFACE.
```

## Dependências

- ZTEWM_C360_SNAP_CTL (lock e controle de delta)
- ZTEWM_C360_HDR / ZTEWM_C360_ITEM (destino dos dados)
- ZTEWM_C360_CUST (SNAP_DELTA_MINUTES)
- Tabelas EWM standard: /SCWM/ORDIM_C, /SCWM/HU_HEADER, /SCWM/PRDI, etc.
- ZCX_EWM_C360_SNAPSHOT

## Critérios de aceite

- ACQUIRE_LOCK usa UPDATE ... SET LOCK_FLAG com ENQUEUE (ou UPDATE + READ-FOR-UPDATE) — atômico.
- RELEASE_LOCK sempre chamado — inclusive em catch de ZCX_EWM_C360_SNAPSHOT.
- GET_DELTA_RANGE retorna ev_from_ts = '00000000000000' para primeiro snapshot (FULL implícito).
- RUN_ALL_PROCESSES lê processos ativos de ZTEWM_C360_CUST (PARAM_KEY = 'ACTIVE_PROCESSES').
- Snapshot FULL: MODIFY (upsert) em HDR/ITEM — não limpa tabela antes.
