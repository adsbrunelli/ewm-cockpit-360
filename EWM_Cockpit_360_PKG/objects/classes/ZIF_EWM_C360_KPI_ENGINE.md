# ZIF_EWM_C360_KPI_ENGINE — Interface do KPI Engine

## Finalidade

Contrato para cálculo, validação e persistência de KPIs. A engine principal (ZCL_EWM_C360_KPI_ENGINE) implementa o ciclo completo. Cada KPI individual tem sua própria classe calculadora referenciada por CALC_CLASS em ZTEWM_C360_KPI_DEF.

## Implementada por

- `ZCL_EWM_C360_KPI_ENGINE` (orquestrador — lê catálogo, instancia calculadoras, persiste)
- Classes calculadoras individuais: `ZCL_EWM_C360_KPI_PRODUCTIVITY`, `ZCL_EWM_C360_KPI_LEAD_TIME`, etc.

## Tipos locais da interface

```abap
TYPES:
  BEGIN OF ty_kpi_input,
    lgnum        TYPE zdewm_c360_e_lgnum,
    process_type TYPE zdewm_c360_e_process,
    period_date  TYPE dats,
    granularity  TYPE zdewm_c360_e_granul,
  END OF ty_kpi_input,

  BEGIN OF ty_kpi_result,
    kpi_id        TYPE zdewm_c360_e_kpi_id,
    actual_value  TYPE zdewm_c360_e_value,
    target_value  TYPE zdewm_c360_e_value,
    tolerance_pct TYPE zdewm_c360_e_value,
    status_code   TYPE zdewm_c360_e_status,  " OK / WARNING / CRITICAL
    calc_ts       TYPE timestamp,
  END OF ty_kpi_result,

  tt_kpi_results TYPE STANDARD TABLE OF ty_kpi_result WITH KEY kpi_id.
```

## Métodos

### VALIDATE_INPUT
Valida os parâmetros de entrada antes do cálculo.

```abap
METHODS validate_input
  IMPORTING
    is_input TYPE ty_kpi_input
  RAISING
    zcx_ewm_c360_kpi.
```

### CALCULATE
Executa o cálculo para todos os KPIs ativos do processo/warehouse.

```abap
METHODS calculate
  IMPORTING
    is_input          TYPE ty_kpi_input
  RETURNING
    VALUE(rt_results) TYPE tt_kpi_results
  RAISING
    zcx_ewm_c360_kpi.
```

### CALCULATE_SINGLE
Executa o cálculo para um KPI específico.

```abap
METHODS calculate_single
  IMPORTING
    is_input         TYPE ty_kpi_input
    iv_kpi_id        TYPE zdewm_c360_e_kpi_id
  RETURNING
    VALUE(rs_result) TYPE ty_kpi_result
  RAISING
    zcx_ewm_c360_kpi.
```

### PERSIST_RESULTS
Persiste os resultados calculados em ZTEWM_C360_KPI.

```abap
METHODS persist_results
  IMPORTING
    is_input   TYPE ty_kpi_input
    it_results TYPE tt_kpi_results
  RAISING
    zcx_ewm_c360_kpi.
```

### GET_LAST_RESULTS
Lê os últimos resultados calculados para um warehouse/processo.

```abap
METHODS get_last_results
  IMPORTING
    iv_lgnum          TYPE zdewm_c360_e_lgnum
    iv_process_type   TYPE zdewm_c360_e_process
    iv_granularity    TYPE zdewm_c360_e_granul DEFAULT 'DAILY'
  RETURNING
    VALUE(rt_results) TYPE tt_kpi_results
  RAISING
    zcx_ewm_c360_kpi.
```

## Esqueleto ABAP completo (SE24)

```abap
INTERFACE zif_ewm_c360_kpi_engine
  PUBLIC.

  TYPES:
    BEGIN OF ty_kpi_input,
      lgnum        TYPE zdewm_c360_e_lgnum,
      process_type TYPE zdewm_c360_e_process,
      period_date  TYPE dats,
      granularity  TYPE zdewm_c360_e_granul,
    END OF ty_kpi_input,

    BEGIN OF ty_kpi_result,
      kpi_id        TYPE zdewm_c360_e_kpi_id,
      actual_value  TYPE zdewm_c360_e_value,
      target_value  TYPE zdewm_c360_e_value,
      tolerance_pct TYPE zdewm_c360_e_value,
      status_code   TYPE zdewm_c360_e_status,
      calc_ts       TYPE timestamp,
    END OF ty_kpi_result,

    tt_kpi_results TYPE STANDARD TABLE OF ty_kpi_result WITH KEY kpi_id.

  METHODS:
    validate_input
      IMPORTING
        is_input TYPE ty_kpi_input
      RAISING
        zcx_ewm_c360_kpi,

    calculate
      IMPORTING
        is_input          TYPE ty_kpi_input
      RETURNING
        VALUE(rt_results) TYPE tt_kpi_results
      RAISING
        zcx_ewm_c360_kpi,

    calculate_single
      IMPORTING
        is_input         TYPE ty_kpi_input
        iv_kpi_id        TYPE zdewm_c360_e_kpi_id
      RETURNING
        VALUE(rs_result) TYPE ty_kpi_result
      RAISING
        zcx_ewm_c360_kpi,

    persist_results
      IMPORTING
        is_input   TYPE ty_kpi_input
        it_results TYPE tt_kpi_results
      RAISING
        zcx_ewm_c360_kpi,

    get_last_results
      IMPORTING
        iv_lgnum        TYPE zdewm_c360_e_lgnum
        iv_process_type TYPE zdewm_c360_e_process
        iv_granularity  TYPE zdewm_c360_e_granul DEFAULT 'DAILY'
      RETURNING
        VALUE(rt_results) TYPE tt_kpi_results
      RAISING
        zcx_ewm_c360_kpi.

ENDINTERFACE.
```

## Dependências

- ZTEWM_C360_KPI_DEF (catálogo de KPIs — CALC_CLASS referencia a classe calculadora)
- ZTEWM_C360_KPI (persistência de resultados)
- ZIF_EWM_C360_AUTH_CHECKER (injetada no construtor)
- ZIF_EWM_C360_LOG_WRITER (injetada no construtor)
- ZCX_EWM_C360_KPI (exceção específica do engine)

## Padrão de injeção de dependência

```abap
" No CONSTRUCTOR da ZCL_EWM_C360_KPI_ENGINE:
METHODS constructor
  IMPORTING
    io_auth TYPE REF TO zif_ewm_c360_auth_checker OPTIONAL
    io_log  TYPE REF TO zif_ewm_c360_log_writer   OPTIONAL.
```

## Critérios de aceite

- CALCULATE retorna tabela vazia (não levanta exceção) se nenhum KPI ativo encontrado.
- STATUS_CODE calculado automaticamente: ACTUAL/TARGET dentro de TOLERANCE_PCT → OK; até CRITICAL_PCT → WARNING; acima → CRITICAL.
- PERSIST_RESULTS usa MODIFY para upsert — não duplica registro para mesma chave.
- ABAP Unit: mock de ZIF_EWM_C360_AUTH_CHECKER e ZIF_EWM_C360_LOG_WRITER injetados no construtor.
