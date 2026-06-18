# ZIF_EWM_C360_EXCEPTION_ENGINE — Interface do Exception Engine

## Finalidade

Contrato para classificação, persistência, resolução e consulta de exceções operacionais e técnicas. Resolve severidade via ZTEWM_C360_SEV_RULE e persiste em ZTEWM_C360_EXC.

## Implementada por

- `ZCL_EWM_C360_EXCEPTION_ENGINE` (implementação real)

## Tipos locais da interface

```abap
TYPES:
  BEGIN OF ty_exc_input,
    lgnum        TYPE zdewm_c360_e_lgnum,
    doc_id       TYPE zdewm_c360_e_doc_id,
    item_no      TYPE numc6,
    process_type TYPE zdewm_c360_e_process,
    exc_type     TYPE zdewm_c360_e_exc_type,
    root_cause   TYPE zdewm_c360_e_msg_text,
    message_id   TYPE symsgid,
    message_no   TYPE symsgno,
    reproc_flag  TYPE zdewm_c360_e_flag,
  END OF ty_exc_input,

  BEGIN OF ty_exc_result,
    exc_id      TYPE zdewm_c360_e_doc_id,
    severity    TYPE zdewm_c360_e_severity,
    sla_due_at  TYPE timestamp,
    status_code TYPE zdewm_c360_e_status,
  END OF ty_exc_result,

  tt_exceptions TYPE STANDARD TABLE OF ztewm_c360_exc WITH KEY lgnum exc_id.
```

## Métodos

### CLASSIFY
Resolve severidade e SLA via matriz ZTEWM_C360_SEV_RULE.

```abap
METHODS classify
  IMPORTING
    is_input         TYPE ty_exc_input
  RETURNING
    VALUE(rs_result) TYPE ty_exc_result
  RAISING
    zcx_ewm_c360_exception_eng.
```

### RAISE_EXCEPTION
Classifica e persiste a exceção em ZTEWM_C360_EXC. Retorna o EXC_ID gerado.

```abap
METHODS raise_exception
  IMPORTING
    is_input        TYPE ty_exc_input
  RETURNING
    VALUE(rv_exc_id) TYPE zdewm_c360_e_doc_id
  RAISING
    zcx_ewm_c360_exception_eng.
```

### RESOLVE
Marca exceção como resolvida (RESOLVED_FLAG = 'X', STATUS = 'RESOLVED').

```abap
METHODS resolve
  IMPORTING
    iv_lgnum  TYPE zdewm_c360_e_lgnum
    iv_exc_id TYPE zdewm_c360_e_doc_id
    iv_reason TYPE zdewm_c360_e_msg_text OPTIONAL
  RAISING
    zcx_ewm_c360_exception_eng
    zcx_ewm_c360_auth.
```

### GET_OPEN_EXCEPTIONS
Lê exceções abertas com filtro opcional por severidade e processo.

```abap
METHODS get_open_exceptions
  IMPORTING
    iv_lgnum        TYPE zdewm_c360_e_lgnum
    iv_process_type TYPE zdewm_c360_e_process OPTIONAL
    iv_severity     TYPE zdewm_c360_e_severity OPTIONAL
  RETURNING
    VALUE(rt_exceptions) TYPE tt_exceptions
  RAISING
    zcx_ewm_c360_exception_eng.
```

### CHECK_SLA_VIOLATIONS
Retorna exceções com SLA_DUE_AT expirado e ainda abertas.

```abap
METHODS check_sla_violations
  IMPORTING
    iv_lgnum             TYPE zdewm_c360_e_lgnum
  RETURNING
    VALUE(rt_violations) TYPE tt_exceptions.
```

## Esqueleto ABAP completo (SE24)

```abap
INTERFACE zif_ewm_c360_exception_engine
  PUBLIC.

  TYPES:
    BEGIN OF ty_exc_input,
      lgnum        TYPE zdewm_c360_e_lgnum,
      doc_id       TYPE zdewm_c360_e_doc_id,
      item_no      TYPE numc6,
      process_type TYPE zdewm_c360_e_process,
      exc_type     TYPE zdewm_c360_e_exc_type,
      root_cause   TYPE zdewm_c360_e_msg_text,
      message_id   TYPE symsgid,
      message_no   TYPE symsgno,
      reproc_flag  TYPE zdewm_c360_e_flag,
    END OF ty_exc_input,

    BEGIN OF ty_exc_result,
      exc_id      TYPE zdewm_c360_e_doc_id,
      severity    TYPE zdewm_c360_e_severity,
      sla_due_at  TYPE timestamp,
      status_code TYPE zdewm_c360_e_status,
    END OF ty_exc_result,

    tt_exceptions TYPE STANDARD TABLE OF ztewm_c360_exc WITH KEY lgnum exc_id.

  METHODS:
    classify
      IMPORTING
        is_input         TYPE ty_exc_input
      RETURNING
        VALUE(rs_result) TYPE ty_exc_result
      RAISING
        zcx_ewm_c360_exception_eng,

    raise_exception
      IMPORTING
        is_input         TYPE ty_exc_input
      RETURNING
        VALUE(rv_exc_id) TYPE zdewm_c360_e_doc_id
      RAISING
        zcx_ewm_c360_exception_eng,

    resolve
      IMPORTING
        iv_lgnum  TYPE zdewm_c360_e_lgnum
        iv_exc_id TYPE zdewm_c360_e_doc_id
        iv_reason TYPE zdewm_c360_e_msg_text OPTIONAL
      RAISING
        zcx_ewm_c360_exception_eng
        zcx_ewm_c360_auth,

    get_open_exceptions
      IMPORTING
        iv_lgnum        TYPE zdewm_c360_e_lgnum
        iv_process_type TYPE zdewm_c360_e_process OPTIONAL
        iv_severity     TYPE zdewm_c360_e_severity OPTIONAL
      RETURNING
        VALUE(rt_exceptions) TYPE tt_exceptions
      RAISING
        zcx_ewm_c360_exception_eng,

    check_sla_violations
      IMPORTING
        iv_lgnum             TYPE zdewm_c360_e_lgnum
      RETURNING
        VALUE(rt_violations) TYPE tt_exceptions.

ENDINTERFACE.
```

## Dependências

- ZTEWM_C360_EXC (persistência)
- ZTEWM_C360_SEV_RULE (resolução de severidade — lógica: LGNUM específico → LGNUM='*')
- ZIF_EWM_C360_AUTH_CHECKER (RESOLVE exige ACTVT=16)
- ZIF_EWM_C360_LOG_WRITER (RESOLVE grava em ACTLOG)
- ZCX_EWM_C360_EXCEPTION_ENG

## Critérios de aceite

- RAISE_EXCEPTION gera EXC_ID via UUID — nunca duplicado.
- CLASSIFY retorna severidade MEDIUM como default se nenhuma regra encontrada em SEV_RULE.
- RESOLVE chama CHECK_COCKPIT_ACCESS com ACTVT=16 antes de alterar o registro.
- RESOLVE grava ACTION_ID = 'EXCEPTION_RESOLVE' em ZTEWM_C360_ACTLOG.
- CHECK_SLA_VIOLATIONS nunca levanta exceção — retorna tabela vazia em caso de erro.
