# Índice de Classes e Interfaces ABAP: EWM Cockpit 360º

## Sequência de criação no SE24

Respeitar esta ordem — cada item depende dos anteriores.

| Seq | Objeto | Tipo | Depende de | Arquivo |
|---|---|---|---|---|
| 1 | ZCX_EWM_C360_BASE | Exception Class | CX_STATIC_CHECK | ZCX_EWM_C360_BASE.md |
| 2 | ZCX_EWM_C360_AUTH | Exception Class | ZCX_EWM_C360_BASE | — |
| 3 | ZCX_EWM_C360_KPI | Exception Class | ZCX_EWM_C360_BASE | — |
| 4 | ZCX_EWM_C360_EXCEPTION_ENG | Exception Class | ZCX_EWM_C360_BASE | — |
| 5 | ZCX_EWM_C360_ACTION | Exception Class | ZCX_EWM_C360_BASE | — |
| 6 | ZCX_EWM_C360_REPROC | Exception Class | ZCX_EWM_C360_BASE | — |
| 7 | ZCX_EWM_C360_SNAPSHOT | Exception Class | ZCX_EWM_C360_BASE | — |
| 8 | ZIF_EWM_C360_AUTH_CHECKER | Interface | ZCX_EWM_C360_AUTH | ZIF_EWM_C360_AUTH_CHECKER.md |
| 9 | ZIF_EWM_C360_LOG_WRITER | Interface | ZCX_EWM_C360_BASE | ZIF_EWM_C360_LOG_WRITER.md |
| 10 | ZIF_EWM_C360_KPI_ENGINE | Interface | ZCX_EWM_C360_KPI | ZIF_EWM_C360_KPI_ENGINE.md |
| 11 | ZIF_EWM_C360_EXCEPTION_ENGINE | Interface | ZCX_EWM_C360_EXCEPTION_ENG | ZIF_EWM_C360_EXCEPTION_ENGINE.md |
| 12 | ZIF_EWM_C360_ACTION_HANDLER | Interface | ZCX_EWM_C360_ACTION, ZCX_EWM_C360_AUTH | ZIF_EWM_C360_ACTION_HANDLER.md |
| 13 | ZIF_EWM_C360_REPROCESSOR | Interface | ZCX_EWM_C360_REPROC, ZCX_EWM_C360_AUTH | ZIF_EWM_C360_REPROCESSOR.md |
| 14 | ZIF_EWM_C360_SNAPSHOT_RUNNER | Interface | ZCX_EWM_C360_SNAPSHOT | ZIF_EWM_C360_SNAPSHOT_RUNNER.md |
| 15 | ZCL_EWM_C360_AUTH | Class | ZIF_EWM_C360_AUTH_CHECKER | — |
| 16 | ZCL_EWM_C360_AUTH_MOCK | Class (test) | ZIF_EWM_C360_AUTH_CHECKER | — |
| 17 | ZCL_EWM_C360_LOG | Class | ZIF_EWM_C360_LOG_WRITER | — |
| 18 | ZCL_EWM_C360_LOG_MOCK | Class (test) | ZIF_EWM_C360_LOG_WRITER | — |
| 19 | ZCL_EWM_C360_KPI_ENGINE | Class | ZIF_EWM_C360_KPI_ENGINE | — |
| 20 | ZCL_EWM_C360_EXCEPTION_ENGINE | Class | ZIF_EWM_C360_EXCEPTION_ENGINE | — |
| 21 | ZCL_EWM_C360_ACTION_DISPATCHER | Class | ZIF_EWM_C360_ACTION_HANDLER | — |
| 22 | ZCL_EWM_C360_ACTION_* | Classes handler | ZIF_EWM_C360_ACTION_HANDLER | — |
| 23 | ZCL_EWM_C360_REPROCESSOR | Class | ZIF_EWM_C360_REPROCESSOR | — |
| 24 | ZCL_EWM_C360_SNAPSHOT_RUNNER | Class | ZIF_EWM_C360_SNAPSHOT_RUNNER | — |
| 25 | ZCL_EWM_C360_DEPENDENCY_CHECK | Class | ZTEWM_C360_DEP | — |

## Padrão de injeção de dependência

Todas as engines e handlers recebem `io_auth` e `io_log` via CONSTRUCTOR:

```abap
METHODS constructor
  IMPORTING
    io_auth TYPE REF TO zif_ewm_c360_auth_checker OPTIONAL
    io_log  TYPE REF TO zif_ewm_c360_log_writer   OPTIONAL.

METHOD constructor.
  mo_auth = COALESCE( io_auth, NEW zcl_ewm_c360_auth( ) ).
  mo_log  = COALESCE( io_log,  NEW zcl_ewm_c360_log( ) ).
ENDMETHOD.
```

Isso permite:
- Produção: injeção automática das implementações reais.
- Testes ABAP Unit: injeção de mocks sem alterar código de produção.

## Interfaces vs Classes — resumo rápido

| Interface | Implementação real | Mock para teste |
|---|---|---|
| ZIF_EWM_C360_AUTH_CHECKER | ZCL_EWM_C360_AUTH | ZCL_EWM_C360_AUTH_MOCK |
| ZIF_EWM_C360_LOG_WRITER | ZCL_EWM_C360_LOG | ZCL_EWM_C360_LOG_MOCK |
| ZIF_EWM_C360_KPI_ENGINE | ZCL_EWM_C360_KPI_ENGINE | — |
| ZIF_EWM_C360_EXCEPTION_ENGINE | ZCL_EWM_C360_EXCEPTION_ENGINE | — |
| ZIF_EWM_C360_ACTION_HANDLER | ZCL_EWM_C360_ACTION_* (vários) | — |
| ZIF_EWM_C360_REPROCESSOR | ZCL_EWM_C360_REPROCESSOR | — |
| ZIF_EWM_C360_SNAPSHOT_RUNNER | ZCL_EWM_C360_SNAPSHOT_RUNNER | — |
