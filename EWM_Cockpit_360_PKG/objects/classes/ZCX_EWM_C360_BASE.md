# ZCX_EWM_C360_BASE — Exception Class Base

## Finalidade

Classe raiz de todas as exceções do cockpit. Todas as ZCX_EWM_C360_* herdam desta classe. Permite captura genérica por chamadores que não precisam distinguir o tipo específico.

## Herança

`CX_STATIC_CHECK` → `ZCX_EWM_C360_BASE`

## Atributos

| Atributo | Tipo | Descrição |
|---|---|---|
| LGNUM | ZDEWM_C360_E_LGNUM | Warehouse de contexto |
| PROCESS | ZDEWM_C360_E_PROCESS | Processo de contexto |
| CONTEXT | STRING | Informação adicional de contexto |

## TextIDs (constantes de mensagem)

| TextID | Texto padrão |
|---|---|
| GENERIC_ERROR | Erro interno no Cockpit 360: &1 |
| NOT_AUTHORIZED | Acesso não autorizado: warehouse &1, processo &2 |
| INVALID_INPUT | Entrada inválida: &1 |
| OBJECT_NOT_FOUND | Objeto não encontrado: &1 |

## Subclasses obrigatórias

| Classe | Uso |
|---|---|
| ZCX_EWM_C360_AUTH | Erros de autorização |
| ZCX_EWM_C360_KPI | Erros do KPI Engine |
| ZCX_EWM_C360_EXCEPTION_ENG | Erros do Exception Engine |
| ZCX_EWM_C360_ACTION | Erros de execução de ação |
| ZCX_EWM_C360_REPROC | Erros de reprocessamento |
| ZCX_EWM_C360_SNAPSHOT | Erros de snapshot |

## Esqueleto ABAP (SE24)

```abap
CLASS zcx_ewm_c360_base DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_t100_message.

    CONSTANTS:
      BEGIN OF generic_error,
        msgid TYPE symsgid VALUE 'ZEWM_C360_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'CONTEXT',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF generic_error,
      BEGIN OF not_authorized,
        msgid TYPE symsgid VALUE 'ZEWM_C360_MSG',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'LGNUM',
        attr2 TYPE scx_attrname VALUE 'PROCESS',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_authorized,
      BEGIN OF invalid_input,
        msgid TYPE symsgid VALUE 'ZEWM_C360_MSG',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'CONTEXT',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_input,
      BEGIN OF object_not_found,
        msgid TYPE symsgid VALUE 'ZEWM_C360_MSG',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'CONTEXT',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF object_not_found.

    DATA:
      lgnum   TYPE zdewm_c360_e_lgnum,
      process TYPE zdewm_c360_e_process,
      context TYPE string.

    METHODS constructor
      IMPORTING
        !textid  LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        !lgnum   TYPE zdewm_c360_e_lgnum   OPTIONAL
        !process TYPE zdewm_c360_e_process OPTIONAL
        !context TYPE string               OPTIONAL.

ENDCLASS.
```

## Sequência de transporte

Deve ser criada antes de todas as outras classes e interfaces do projeto.
