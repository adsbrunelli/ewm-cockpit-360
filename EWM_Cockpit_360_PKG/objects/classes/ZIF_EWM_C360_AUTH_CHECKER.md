# ZIF_EWM_C360_AUTH_CHECKER — Interface de Verificação de Autorização

## Finalidade

Contrato para qualquer implementação de verificação de autorização no cockpit. Garante que toda classe que valida acesso usa a mesma assinatura, permitindo mock em testes unitários.

## Implementada por

- `ZCL_EWM_C360_AUTH` (implementação real via AUTHORITY-CHECK)
- `ZCL_EWM_C360_AUTH_MOCK` (mock para testes unitários ABAP Unit)

## Tipos locais da interface

```abap
TYPES:
  BEGIN OF ty_auth_request,
    lgnum      TYPE zdewm_c360_e_lgnum,
    process    TYPE zdewm_c360_e_process,
    action_id  TYPE zdewm_c360_e_action_id,
    actvt      TYPE char2,
    reproc_t   TYPE char20,
    param_grp  TYPE char20,
    log_type   TYPE char10,
  END OF ty_auth_request.
```

## Métodos

### CHECK_COCKPIT_ACCESS
Verifica acesso geral ao cockpit (Z_EWM_C360A).

```abap
METHODS check_cockpit_access
  IMPORTING
    iv_lgnum   TYPE zdewm_c360_e_lgnum
    iv_process TYPE zdewm_c360_e_process
    iv_actvt   TYPE char2 DEFAULT '03'
  RAISING
    zcx_ewm_c360_auth.
```

### CHECK_REPROCESS_ACCESS
Verifica autorização para reprocessamento (Z_EWM_C360R).

```abap
METHODS check_reprocess_access
  IMPORTING
    iv_lgnum    TYPE zdewm_c360_e_lgnum
    iv_reproc_t TYPE char20 DEFAULT 'MANUAL'
  RAISING
    zcx_ewm_c360_auth.
```

### CHECK_ADMIN_ACCESS
Verifica autorização para administração de parâmetros (Z_EWM_C360M).

```abap
METHODS check_admin_access
  IMPORTING
    iv_param_grp TYPE char20
    iv_actvt     TYPE char2 DEFAULT '03'
  RAISING
    zcx_ewm_c360_auth.
```

### CHECK_LOG_ACCESS
Verifica autorização para consulta de logs (Z_EWM_C360L).

```abap
METHODS check_log_access
  IMPORTING
    iv_lgnum    TYPE zdewm_c360_e_lgnum
    iv_log_type TYPE char10 DEFAULT 'ACTION'
  RAISING
    zcx_ewm_c360_auth.
```

### IS_AUTHORIZED
Versão sem RAISING — retorna flag booleano. Útil para condicionar visibilidade na UI.

```abap
METHODS is_authorized
  IMPORTING
    is_request     TYPE ty_auth_request
  RETURNING
    VALUE(rv_auth) TYPE abap_bool.
```

## Esqueleto ABAP completo (SE24)

```abap
INTERFACE zif_ewm_c360_auth_checker
  PUBLIC.

  TYPES:
    BEGIN OF ty_auth_request,
      lgnum     TYPE zdewm_c360_e_lgnum,
      process   TYPE zdewm_c360_e_process,
      action_id TYPE zdewm_c360_e_action_id,
      actvt     TYPE char2,
      reproc_t  TYPE char20,
      param_grp TYPE char20,
      log_type  TYPE char10,
    END OF ty_auth_request.

  METHODS:
    check_cockpit_access
      IMPORTING
        iv_lgnum   TYPE zdewm_c360_e_lgnum
        iv_process TYPE zdewm_c360_e_process
        iv_actvt   TYPE char2 DEFAULT '03'
      RAISING
        zcx_ewm_c360_auth,

    check_reprocess_access
      IMPORTING
        iv_lgnum    TYPE zdewm_c360_e_lgnum
        iv_reproc_t TYPE char20 DEFAULT 'MANUAL'
      RAISING
        zcx_ewm_c360_auth,

    check_admin_access
      IMPORTING
        iv_param_grp TYPE char20
        iv_actvt     TYPE char2 DEFAULT '03'
      RAISING
        zcx_ewm_c360_auth,

    check_log_access
      IMPORTING
        iv_lgnum    TYPE zdewm_c360_e_lgnum
        iv_log_type TYPE char10 DEFAULT 'ACTION'
      RAISING
        zcx_ewm_c360_auth,

    is_authorized
      IMPORTING
        is_request     TYPE ty_auth_request
      RETURNING
        VALUE(rv_auth) TYPE abap_bool.

ENDINTERFACE.
```

## Dependências

- ZCX_EWM_C360_AUTH (exceção levantada)
- Authorization Objects: Z_EWM_C360A, Z_EWM_C360R, Z_EWM_C360M, Z_EWM_C360L

## Critérios de aceite

- ZCL_EWM_C360_AUTH implementa todos os métodos com AUTHORITY-CHECK real.
- ZCL_EWM_C360_AUTH_MOCK implementa todos os métodos com comportamento configurável para testes.
- Toda engine e handler injeta esta interface via CONSTRUCTOR (injeção de dependência).
