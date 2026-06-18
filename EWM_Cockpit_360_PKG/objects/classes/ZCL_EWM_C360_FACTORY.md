# ZCL_EWM_C360_FACTORY — Factory de Componentes do Cockpit

## Finalidade

Centralizar a criação de todas as classes de negócio do EWM Cockpit 360º com suas dependências
corretamente injetadas. Garante padrão único de instanciação e facilita substituição por mocks
em testes ABAP Unit.

**Problema resolvido (ARQ-04)**: sem esta classe, cada ponto de uso criava instâncias com
variações de injeção (io_auth vs io_checker vs construtor sem parâmetros), quebrando
testabilidade e possibilitando instâncias sem log ou sem validação de autorização.

## Padrão de uso

```abap
"-- Em produção: factory cria instâncias reais com todas dependências
DATA(lo_kpi) = zcl_ewm_c360_factory=>get_kpi_engine( ).
lo_kpi->calculate( ls_input ).

"-- Em testes: sobrescrever factory com mocks via SET_INSTANCE
zcl_ewm_c360_factory=>set_instance(
  iv_type     = 'KPI_ENGINE'
  io_instance = mo_kpi_mock
).
DATA(lo_kpi) = zcl_ewm_c360_factory=>get_kpi_engine( ).   "-- retorna mock
```

## Métodos públicos

### GET_KPI_ENGINE
```abap
CLASS-METHODS get_kpi_engine
  RETURNING VALUE(ro_engine) TYPE REF TO zif_ewm_c360_kpi_engine.
```
Retorna instância de `ZCL_EWM_C360_KPI_ENGINE` com `io_auth` e `io_log` injetados.

### GET_EXCEPTION_ENGINE
```abap
CLASS-METHODS get_exception_engine
  RETURNING VALUE(ro_engine) TYPE REF TO zif_ewm_c360_exception_engine.
```

### GET_REPROCESSOR
```abap
CLASS-METHODS get_reprocessor
  RETURNING VALUE(ro_reprocessor) TYPE REF TO zif_ewm_c360_reprocessor.
```

### GET_SNAPSHOT_RUNNER
```abap
CLASS-METHODS get_snapshot_runner
  RETURNING VALUE(ro_runner) TYPE REF TO zif_ewm_c360_snapshot_runner.
```

### GET_ACTION_DISPATCHER
```abap
CLASS-METHODS get_action_dispatcher
  RETURNING VALUE(ro_dispatcher) TYPE REF TO zif_ewm_c360_action_dispatcher.
```

### GET_AUTH_CHECKER
```abap
CLASS-METHODS get_auth_checker
  RETURNING VALUE(ro_auth) TYPE REF TO zif_ewm_c360_auth_checker.
```

### GET_LOG_WRITER
```abap
CLASS-METHODS get_log_writer
  RETURNING VALUE(ro_log) TYPE REF TO zif_ewm_c360_log_writer.
```

### SET_INSTANCE (somente para testes)
```abap
CLASS-METHODS set_instance
  IMPORTING
    iv_type     TYPE string   "-- 'KPI_ENGINE', 'EXCEPTION_ENGINE', etc.
    io_instance TYPE REF TO object.
```
Substitui a instância que será retornada pelo getter correspondente.
Deve ser chamado apenas em classes de teste (`FOR TESTING`).

### RESET_INSTANCES (somente para testes)
```abap
CLASS-METHODS reset_instances.
```
Limpa todas as substituições de teste e volta ao comportamento padrão.
Chamar no `teardown` de cada classe de teste para evitar contaminação entre testes.

## Esqueleto ABAP completo (SE24)

```abap
CLASS zcl_ewm_c360_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS:
      get_kpi_engine
        RETURNING VALUE(ro_engine) TYPE REF TO zif_ewm_c360_kpi_engine,

      get_exception_engine
        RETURNING VALUE(ro_engine) TYPE REF TO zif_ewm_c360_exception_engine,

      get_reprocessor
        RETURNING VALUE(ro_reprocessor) TYPE REF TO zif_ewm_c360_reprocessor,

      get_snapshot_runner
        RETURNING VALUE(ro_runner) TYPE REF TO zif_ewm_c360_snapshot_runner,

      get_action_dispatcher
        RETURNING VALUE(ro_dispatcher) TYPE REF TO zif_ewm_c360_action_dispatcher,

      get_auth_checker
        RETURNING VALUE(ro_auth) TYPE REF TO zif_ewm_c360_auth_checker,

      get_log_writer
        RETURNING VALUE(ro_log) TYPE REF TO zif_ewm_c360_log_writer,

      set_instance
        IMPORTING
          iv_type     TYPE string
          io_instance TYPE REF TO object,

      reset_instances.

  PRIVATE SECTION.
    CLASS-DATA:
      go_kpi_engine        TYPE REF TO zif_ewm_c360_kpi_engine,
      go_exception_engine  TYPE REF TO zif_ewm_c360_exception_engine,
      go_reprocessor       TYPE REF TO zif_ewm_c360_reprocessor,
      go_snapshot_runner   TYPE REF TO zif_ewm_c360_snapshot_runner,
      go_action_dispatcher TYPE REF TO zif_ewm_c360_action_dispatcher,
      go_auth_checker      TYPE REF TO zif_ewm_c360_auth_checker,
      go_log_writer        TYPE REF TO zif_ewm_c360_log_writer.

ENDCLASS.

CLASS zcl_ewm_c360_factory IMPLEMENTATION.

  METHOD get_auth_checker.
    IF go_auth_checker IS INITIAL.
      go_auth_checker = NEW zcl_ewm_c360_auth( ).
    ENDIF.
    ro_auth = go_auth_checker.
  ENDMETHOD.

  METHOD get_log_writer.
    IF go_log_writer IS INITIAL.
      go_log_writer = NEW zcl_ewm_c360_log( ).
    ENDIF.
    ro_log = go_log_writer.
  ENDMETHOD.

  METHOD get_kpi_engine.
    IF go_kpi_engine IS INITIAL.
      go_kpi_engine = NEW zcl_ewm_c360_kpi_engine(
        io_auth = get_auth_checker( )
        io_log  = get_log_writer( )
      ).
    ENDIF.
    ro_engine = go_kpi_engine.
  ENDMETHOD.

  METHOD get_exception_engine.
    IF go_exception_engine IS INITIAL.
      go_exception_engine = NEW zcl_ewm_c360_exception_engine(
        io_auth = get_auth_checker( )
        io_log  = get_log_writer( )
      ).
    ENDIF.
    ro_engine = go_exception_engine.
  ENDMETHOD.

  METHOD get_reprocessor.
    IF go_reprocessor IS INITIAL.
      go_reprocessor = NEW zcl_ewm_c360_reprocessor(
        io_auth = get_auth_checker( )
        io_log  = get_log_writer( )
      ).
    ENDIF.
    ro_reprocessor = go_reprocessor.
  ENDMETHOD.

  METHOD get_snapshot_runner.
    IF go_snapshot_runner IS INITIAL.
      go_snapshot_runner = NEW zcl_ewm_c360_snapshot_runner(
        io_log = get_log_writer( )
      ).
    ENDIF.
    ro_runner = go_snapshot_runner.
  ENDMETHOD.

  METHOD get_action_dispatcher.
    IF go_action_dispatcher IS INITIAL.
      go_action_dispatcher = NEW zcl_ewm_c360_action_dispatcher(
        io_auth = get_auth_checker( )
        io_log  = get_log_writer( )
      ).
    ENDIF.
    ro_dispatcher = go_action_dispatcher.
  ENDMETHOD.

  METHOD set_instance.
    CASE iv_type.
      WHEN 'KPI_ENGINE'.        go_kpi_engine        ?= io_instance.
      WHEN 'EXCEPTION_ENGINE'.  go_exception_engine  ?= io_instance.
      WHEN 'REPROCESSOR'.       go_reprocessor       ?= io_instance.
      WHEN 'SNAPSHOT_RUNNER'.   go_snapshot_runner   ?= io_instance.
      WHEN 'ACTION_DISPATCHER'. go_action_dispatcher ?= io_instance.
      WHEN 'AUTH_CHECKER'.      go_auth_checker      ?= io_instance.
      WHEN 'LOG_WRITER'.        go_log_writer        ?= io_instance.
    ENDCASE.
  ENDMETHOD.

  METHOD reset_instances.
    CLEAR: go_kpi_engine, go_exception_engine, go_reprocessor,
           go_snapshot_runner, go_action_dispatcher,
           go_auth_checker, go_log_writer.
  ENDMETHOD.

ENDCLASS.
```

## Dependências

- `ZIF_EWM_C360_KPI_ENGINE`, `ZIF_EWM_C360_EXCEPTION_ENGINE`, `ZIF_EWM_C360_REPROCESSOR`
- `ZIF_EWM_C360_SNAPSHOT_RUNNER`, `ZIF_EWM_C360_ACTION_DISPATCHER`
- `ZIF_EWM_C360_AUTH_CHECKER`, `ZIF_EWM_C360_LOG_WRITER`
- Implementações: `ZCL_EWM_C360_AUTH`, `ZCL_EWM_C360_LOG`

## Sequência de transporte

Wave 6 — Classes (após interfaces de Wave 5). Deve ser transportada antes de qualquer
classe que use os getters.

## Critérios de aceite

- `GET_KPI_ENGINE` chamado duas vezes retorna a mesma instância (singleton por sessão).
- Em teste com `SET_INSTANCE('KPI_ENGINE', lo_mock)`, `GET_KPI_ENGINE` retorna o mock.
- `RESET_INSTANCES` após SET_INSTANCE faz `GET_KPI_ENGINE` criar nova instância real.
- Nenhum caller externo usa `NEW zcl_ewm_c360_*( )` diretamente — sempre via factory.
