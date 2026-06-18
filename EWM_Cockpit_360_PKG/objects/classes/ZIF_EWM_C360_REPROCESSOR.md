# ZIF_EWM_C360_REPROCESSOR — Interface do Framework de Reprocessamento

## Finalidade

Contrato para reprocessamento auditável de exceções elegíveis (REPROC_FLAG = 'X'). Controla retry policy (MAX_RETRY=3, intervalo exponencial) e grava resultado em ACTLOG. Definido em ADR-005.

## Implementada por

- `ZCL_EWM_C360_REPROCESSOR` (implementação real)

## Tipos locais da interface

```abap
TYPES:
  BEGIN OF ty_reproc_request,
    lgnum      TYPE zdewm_c360_e_lgnum,
    exc_id     TYPE zdewm_c360_e_doc_id,
    reproc_t   TYPE char20,            " MANUAL / AUTO / BULK
    requested_by TYPE uname,
  END OF ty_reproc_request,

  BEGIN OF ty_reproc_result,
    exc_id     TYPE zdewm_c360_e_doc_id,
    success    TYPE abap_bool,
    retry_count TYPE zdewm_c360_e_counter,
    log_id     TYPE zdewm_c360_e_doc_id,
    msg_text   TYPE zdewm_c360_e_msg_text,
  END OF ty_reproc_result,

  tt_reproc_results TYPE STANDARD TABLE OF ty_reproc_result WITH KEY exc_id.
```

## Métodos

### IS_ELIGIBLE
Verifica se a exceção é elegível para reprocessamento (REPROC_FLAG = 'X' e RETRY_COUNT < MAX_RETRY).

```abap
METHODS is_eligible
  IMPORTING
    iv_lgnum         TYPE zdewm_c360_e_lgnum
    iv_exc_id        TYPE zdewm_c360_e_doc_id
  RETURNING
    VALUE(rv_eligible) TYPE abap_bool.
```

### REPROCESS
Executa o reprocessamento de uma única exceção.

```abap
METHODS reprocess
  IMPORTING
    is_request       TYPE ty_reproc_request
  RETURNING
    VALUE(rs_result) TYPE ty_reproc_result
  RAISING
    zcx_ewm_c360_reproc
    zcx_ewm_c360_auth.
```

### REPROCESS_BULK
Executa reprocessamento em lote para todas as exceções elegíveis de um warehouse.

```abap
METHODS reprocess_bulk
  IMPORTING
    iv_lgnum          TYPE zdewm_c360_e_lgnum
    iv_process_type   TYPE zdewm_c360_e_process OPTIONAL
  RETURNING
    VALUE(rt_results) TYPE tt_reproc_results
  RAISING
    zcx_ewm_c360_auth.
```

### GET_RETRY_INTERVAL
Retorna o intervalo de espera em minutos para o próximo retry (lógica exponencial).

```abap
METHODS get_retry_interval
  IMPORTING
    iv_retry_count     TYPE zdewm_c360_e_counter
  RETURNING
    VALUE(rv_minutes)  TYPE i.
" Lógica: retry 1 = 5min, retry 2 = 15min, retry 3 = 45min
```

## Esqueleto ABAP completo (SE24)

```abap
INTERFACE zif_ewm_c360_reprocessor
  PUBLIC.

  TYPES:
    BEGIN OF ty_reproc_request,
      lgnum        TYPE zdewm_c360_e_lgnum,
      exc_id       TYPE zdewm_c360_e_doc_id,
      reproc_t     TYPE char20,
      requested_by TYPE uname,
    END OF ty_reproc_request,

    BEGIN OF ty_reproc_result,
      exc_id      TYPE zdewm_c360_e_doc_id,
      success     TYPE abap_bool,
      retry_count TYPE zdewm_c360_e_counter,
      log_id      TYPE zdewm_c360_e_doc_id,
      msg_text    TYPE zdewm_c360_e_msg_text,
    END OF ty_reproc_result,

    tt_reproc_results TYPE STANDARD TABLE OF ty_reproc_result WITH KEY exc_id.

  METHODS:
    is_eligible
      IMPORTING
        iv_lgnum           TYPE zdewm_c360_e_lgnum
        iv_exc_id          TYPE zdewm_c360_e_doc_id
      RETURNING
        VALUE(rv_eligible) TYPE abap_bool,

    reprocess
      IMPORTING
        is_request       TYPE ty_reproc_request
      RETURNING
        VALUE(rs_result) TYPE ty_reproc_result
      RAISING
        zcx_ewm_c360_reproc
        zcx_ewm_c360_auth,

    reprocess_bulk
      IMPORTING
        iv_lgnum          TYPE zdewm_c360_e_lgnum
        iv_process_type   TYPE zdewm_c360_e_process OPTIONAL
      RETURNING
        VALUE(rt_results) TYPE tt_reproc_results
      RAISING
        zcx_ewm_c360_auth,

    get_retry_interval
      IMPORTING
        iv_retry_count    TYPE zdewm_c360_e_counter
      RETURNING
        VALUE(rv_minutes) TYPE i.

ENDINTERFACE.
```

## Dependências

- ZTEWM_C360_EXC (leitura de elegibilidade e atualização de RETRY_COUNT)
- ZTEWM_C360_CUST (MAX_RETRY lido de PARAM_KEY = 'MAX_RETRY')
- ZIF_EWM_C360_AUTH_CHECKER (REPROC_T validado via Z_EWM_C360R)
- ZIF_EWM_C360_LOG_WRITER (grava em ACTLOG para cada tentativa)
- ZCX_EWM_C360_REPROC

## Critérios de aceite

- REPROCESS bloqueia se RETRY_COUNT >= MAX_RETRY (lido de ZTEWM_C360_CUST).
- Exceção com STATUS = 'FAILED' (max retry esgotado) não é elegível para IS_ELIGIBLE.
- REPROCESS_BULK exige Z_EWM_C360R com REPROC_T = 'BULK' — não concedido a INBOUND/OUTBOUND.
- GET_RETRY_INTERVAL: retry 1 → 5 min, retry 2 → 15 min, retry 3 → 45 min (exponencial base 3).
- Cada tentativa grava em ZTEWM_C360_ACTLOG com ACTION_ID = 'EXCEPTION_REPROCESS'.
