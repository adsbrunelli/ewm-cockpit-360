# ZIF_EWM_C360_ACTION_HANDLER — Interface de Handler de Ação

## Finalidade

Contrato que todo handler de ação Fiori deve implementar. O ACTION_DISPATCHER instancia o handler correto via ZTEWM_C360_ACTION (HANDLER_CLASS + HANDLER_METHOD) e chama EXECUTE. Garante que todas as ações seguem o mesmo ciclo: validar → autorizar → executar → logar → retornar.

## Implementada por

- `ZCL_EWM_C360_ACTION_INBOUND_CONFIRM` (confirmar recebimento)
- `ZCL_EWM_C360_ACTION_OUTBOUND_RELEASE` (liberar expedição)
- `ZCL_EWM_C360_ACTION_HU_REPACK` (reempacotar HU)
- `ZCL_EWM_C360_ACTION_WT_CANCEL` (cancelar WT)
- `ZCL_EWM_C360_ACTION_EXC_RESOLVE` (resolver exceção)
- _(qualquer novo handler de ação)_

## Tipos locais da interface

```abap
TYPES:
  BEGIN OF ty_action_input,
    lgnum      TYPE zdewm_c360_e_lgnum,
    action_id  TYPE zdewm_c360_e_action_id,
    doc_id     TYPE zdewm_c360_e_doc_id,
    item_no    TYPE numc6,
    parameters TYPE string,           " JSON de parâmetros adicionais
    exec_user  TYPE uname,
  END OF ty_action_input,

  BEGIN OF ty_action_result,
    success    TYPE abap_bool,
    log_id     TYPE zdewm_c360_e_doc_id,
    msg_text   TYPE zdewm_c360_e_msg_text,
    message_id TYPE symsgid,
    message_no TYPE symsgno,
  END OF ty_action_result.
```

## Métodos

### VALIDATE_INPUT
Valida parâmetros obrigatórios e consistência de entrada.

```abap
METHODS validate_input
  IMPORTING
    is_input TYPE ty_action_input
  RAISING
    zcx_ewm_c360_action.
```

### CHECK_AUTHORIZATION
Verifica autorização para executar a ação no warehouse/processo.

```abap
METHODS check_authorization
  IMPORTING
    is_input TYPE ty_action_input
  RAISING
    zcx_ewm_c360_auth.
```

### EXECUTE
Executa a lógica de negócio da ação. Implementado por cada handler específico.

```abap
METHODS execute
  IMPORTING
    is_input         TYPE ty_action_input
  RETURNING
    VALUE(rs_result) TYPE ty_action_result
  RAISING
    zcx_ewm_c360_action
    zcx_ewm_c360_auth.
```

### WRITE_LOG
Grava resultado da execução em ZTEWM_C360_ACTLOG.

```abap
METHODS write_log
  IMPORTING
    is_input  TYPE ty_action_input
    is_result TYPE ty_action_result.
```

## Esqueleto ABAP completo (SE24)

```abap
INTERFACE zif_ewm_c360_action_handler
  PUBLIC.

  TYPES:
    BEGIN OF ty_action_input,
      lgnum      TYPE zdewm_c360_e_lgnum,
      action_id  TYPE zdewm_c360_e_action_id,
      doc_id     TYPE zdewm_c360_e_doc_id,
      item_no    TYPE numc6,
      parameters TYPE string,
      exec_user  TYPE uname,
    END OF ty_action_input,

    BEGIN OF ty_action_result,
      success    TYPE abap_bool,
      log_id     TYPE zdewm_c360_e_doc_id,
      msg_text   TYPE zdewm_c360_e_msg_text,
      message_id TYPE symsgid,
      message_no TYPE symsgno,
    END OF ty_action_result.

  METHODS:
    validate_input
      IMPORTING
        is_input TYPE ty_action_input
      RAISING
        zcx_ewm_c360_action,

    check_authorization
      IMPORTING
        is_input TYPE ty_action_input
      RAISING
        zcx_ewm_c360_auth,

    execute
      IMPORTING
        is_input         TYPE ty_action_input
      RETURNING
        VALUE(rs_result) TYPE ty_action_result
      RAISING
        zcx_ewm_c360_action
        zcx_ewm_c360_auth,

    write_log
      IMPORTING
        is_input  TYPE ty_action_input
        is_result TYPE ty_action_result.

ENDINTERFACE.
```

## Padrão de implementação obrigatório em cada handler

```abap
METHOD zif_ewm_c360_action_handler~execute.
  " 1. Validar entrada
  validate_input( is_input ).

  " 2. Verificar autorização
  check_authorization( is_input ).

  " 3. Executar lógica de negócio
  TRY.
      " ... lógica específica do handler ...
      rs_result-success = abap_true.
    CATCH zcx_ewm_c360_base INTO DATA(lx_error).
      rs_result-success  = abap_false.
      rs_result-msg_text = lx_error->get_text( ).
  ENDTRY.

  " 4. Gravar log (sempre — sucesso ou falha)
  write_log( is_input = is_input  is_result = rs_result ).
ENDMETHOD.
```

## Dependências

- ZTEWM_C360_ACTION (definição da ação — HANDLER_CLASS, IS_CRITICAL)
- ZIF_EWM_C360_AUTH_CHECKER (injetada no construtor)
- ZIF_EWM_C360_LOG_WRITER (injetada no construtor)
- ZCL_EWM_C360_ACTION_DISPATCHER (instancia o handler correto)

## Critérios de aceite

- WRITE_LOG é sempre chamado após EXECUTE — mesmo em caso de exceção.
- Nenhum handler captura ZCX_EWM_C360_AUTH — ela propaga para o dispatcher.
- Todo novo handler criado deve implementar esta interface sem exceção.
- ABAP Unit: cada handler tem teste com mock de auth (autorizado e não autorizado).
