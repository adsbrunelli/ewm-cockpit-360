# ZIF_EWM_C360_LOG_WRITER — Interface de Gravação de Log

## Finalidade

Contrato para gravação de action log em ZTEWM_C360_ACTLOG. Permite mock em testes unitários sem gravar no banco. Toda ação crítica usa esta interface.

## Implementada por

- `ZCL_EWM_C360_LOG` (implementação real — grava em ZTEWM_C360_ACTLOG)
- `ZCL_EWM_C360_LOG_MOCK` (mock para ABAP Unit — sem gravação)

## Tipos locais da interface

```abap
TYPES:
  BEGIN OF ty_log_entry,
    lgnum          TYPE zdewm_c360_e_lgnum,
    action_id      TYPE zdewm_c360_e_action_id,
    process_type   TYPE zdewm_c360_e_process,
    doc_id         TYPE zdewm_c360_e_doc_id,
    item_no        TYPE numc6,
    exec_user      TYPE uname,
    result         TYPE zdewm_c360_e_result,
    msg_text       TYPE zdewm_c360_e_msg_text,
    message_id     TYPE symsgid,
    message_no     TYPE symsgno,
  END OF ty_log_entry.
```

## Métodos

### WRITE
Grava uma entrada no action log. LOG_ID gerado internamente via UUID.

```abap
METHODS write
  IMPORTING
    is_entry       TYPE ty_log_entry
  RETURNING
    VALUE(rv_log_id) TYPE zdewm_c360_e_doc_id
  RAISING
    zcx_ewm_c360_base.
```

### WRITE_ERROR
Atalho para gravar resultado de erro com mensagem de exceção.

```abap
METHODS write_error
  IMPORTING
    is_entry   TYPE ty_log_entry
    ix_error   TYPE REF TO zcx_ewm_c360_base
  RETURNING
    VALUE(rv_log_id) TYPE zdewm_c360_e_doc_id.
```

### WRITE_SLG1
Grava também em SLG1 (BAL) para correlação com log técnico padrão SAP.

```abap
METHODS write_slg1
  IMPORTING
    iv_lgnum   TYPE zdewm_c360_e_lgnum
    iv_process TYPE zdewm_c360_e_process
    iv_msg_id  TYPE symsgid
    iv_msg_no  TYPE symsgno
    iv_msg_ty  TYPE symsgty DEFAULT 'E'
    it_params  TYPE bal_t_msg OPTIONAL.
```

## Esqueleto ABAP completo (SE24)

```abap
INTERFACE zif_ewm_c360_log_writer
  PUBLIC.

  TYPES:
    BEGIN OF ty_log_entry,
      lgnum        TYPE zdewm_c360_e_lgnum,
      action_id    TYPE zdewm_c360_e_action_id,
      process_type TYPE zdewm_c360_e_process,
      doc_id       TYPE zdewm_c360_e_doc_id,
      item_no      TYPE numc6,
      exec_user    TYPE uname,
      result       TYPE zdewm_c360_e_result,
      msg_text     TYPE zdewm_c360_e_msg_text,
      message_id   TYPE symsgid,
      message_no   TYPE symsgno,
    END OF ty_log_entry.

  METHODS:
    write
      IMPORTING
        is_entry         TYPE ty_log_entry
      RETURNING
        VALUE(rv_log_id) TYPE zdewm_c360_e_doc_id
      RAISING
        zcx_ewm_c360_base,

    write_error
      IMPORTING
        is_entry         TYPE ty_log_entry
        ix_error         TYPE REF TO zcx_ewm_c360_base
      RETURNING
        VALUE(rv_log_id) TYPE zdewm_c360_e_doc_id,

    write_slg1
      IMPORTING
        iv_lgnum   TYPE zdewm_c360_e_lgnum
        iv_process TYPE zdewm_c360_e_process
        iv_msg_id  TYPE symsgid
        iv_msg_no  TYPE symsgno
        iv_msg_ty  TYPE symsgty DEFAULT 'E'
        it_params  TYPE bal_t_msg OPTIONAL.

ENDINTERFACE.
```

## Dependências

- ZTEWM_C360_ACTLOG (tabela de destino)
- ZCX_EWM_C360_BASE (exceção levantada)
- BAL (Business Application Log) para WRITE_SLG1

## Critérios de aceite

- LOG_ID gerado via CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC — nunca duplicado.
- WRITE_ERROR nunca levanta exceção — absorve erro de gravação e retorna LOG_ID vazio.
- Toda ação com IS_CRITICAL = 'X' em ZTEWM_C360_ACTION chama WRITE antes de retornar.
