"! @testing-only
CLASS ltcl_auth_checker DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA: mo_cut    TYPE REF TO zcl_ewm_c360_auth,
          mo_auth   TYPE REF TO ltd_auth_mock.

    METHODS:
      setup,
      "-- Cenário: autorização concedida
      check_auth_granted      FOR TESTING,
      "-- Cenário: autorização negada por LGNUM errado
      check_auth_denied_lgnum FOR TESTING,
      "-- Cenário: autorização negada por ACTVT ausente
      check_auth_denied_actvt FOR TESTING,
      "-- Cenário: request com campo em branco levanta exceção
      check_empty_lgnum_raises FOR TESTING.
ENDCLASS.

"----------------------------------------------------------------------
CLASS ltd_auth_mock DEFINITION.
  PUBLIC SECTION.
    DATA: mv_subrc TYPE sy-subrc VALUE 0.
    METHODS: set_subrc IMPORTING iv_subrc TYPE sy-subrc.
ENDCLASS.

CLASS ltd_auth_mock IMPLEMENTATION.
  METHOD set_subrc.
    mv_subrc = iv_subrc.
  ENDMETHOD.
ENDCLASS.
"----------------------------------------------------------------------

CLASS ltcl_auth_checker IMPLEMENTATION.

  METHOD setup.
    mo_auth = NEW ltd_auth_mock( ).
    "-- Injeção de dependência: passa mock pelo CONSTRUCTOR
    mo_cut = NEW zcl_ewm_c360_auth( io_auth_mock = mo_auth ).
  ENDMETHOD.

  METHOD check_auth_granted.
    "-- Arrange
    mo_auth->set_subrc( 0 ).
    DATA(ls_request) = VALUE zif_ewm_c360_auth_checker=>ty_auth_request(
      lgnum      = 'WH01'
      process    = 'INBOUND'
      actvt      = '03'
      auth_object = 'Z_EWM_C360A'
    ).

    "-- Act + Assert: nenhuma exceção deve ser levantada
    TRY.
        mo_cut->check( ls_request ).
        cl_abap_unit_assert=>assert_true(
          act = abap_true
          msg = 'check() deve passar sem excecao quando subrc = 0'
        ).
      CATCH zcx_ewm_c360_auth INTO DATA(lx).
        cl_abap_unit_assert=>fail( msg = lx->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD check_auth_denied_lgnum.
    "-- Arrange: AUTHORITY-CHECK retornaria 4 (não autorizado)
    mo_auth->set_subrc( 4 ).
    DATA(ls_request) = VALUE zif_ewm_c360_auth_checker=>ty_auth_request(
      lgnum       = 'WH99'
      process     = 'INBOUND'
      actvt       = '03'
      auth_object = 'Z_EWM_C360A'
    ).

    "-- Act + Assert: exceção do tipo zcx_ewm_c360_auth esperada
    TRY.
        mo_cut->check( ls_request ).
        cl_abap_unit_assert=>fail( msg = 'Excecao nao levantada para LGNUM nao autorizado' ).
      CATCH zcx_ewm_c360_auth.
        "-- OK: exceção esperada
    ENDTRY.
  ENDMETHOD.

  METHOD check_auth_denied_actvt.
    mo_auth->set_subrc( 4 ).
    DATA(ls_request) = VALUE zif_ewm_c360_auth_checker=>ty_auth_request(
      lgnum       = 'WH01'
      process     = 'INBOUND'
      actvt       = '02'   "-- escrita sem permissão
      auth_object = 'Z_EWM_C360A'
    ).

    TRY.
        mo_cut->check( ls_request ).
        cl_abap_unit_assert=>fail( msg = 'Excecao nao levantada para ACTVT sem permissao' ).
      CATCH zcx_ewm_c360_auth.
        "-- OK
    ENDTRY.
  ENDMETHOD.

  METHOD check_empty_lgnum_raises.
    DATA(ls_request) = VALUE zif_ewm_c360_auth_checker=>ty_auth_request(
      lgnum       = ''    "-- inválido
      process     = 'INBOUND'
      actvt       = '03'
      auth_object = 'Z_EWM_C360A'
    ).

    TRY.
        mo_cut->check( ls_request ).
        cl_abap_unit_assert=>fail( msg = 'Excecao nao levantada para LGNUM vazio' ).
      CATCH zcx_ewm_c360_base.
        "-- OK: validação de entrada deve rejeitar campo em branco
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
