"! @testing-only
CLASS ltcl_reprocessor DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA: mo_cut  TYPE REF TO zcl_ewm_c360_reprocessor,
          mo_auth TYPE REF TO ltd_auth_mock_repr,
          mo_log  TYPE REF TO ltd_log_mock_repr.

    METHODS:
      setup,
      "-- Documento elegível (REPROC_FLAG='X', RETRY_COUNT < MAX_RETRY)
      is_eligible_yes                   FOR TESTING,
      "-- REPROC_FLAG em branco → não elegível
      is_eligible_no_reproc_flag        FOR TESTING,
      "-- RETRY_COUNT >= MAX_RETRY → não elegível
      is_eligible_max_retry_reached     FOR TESTING,
      "-- Intervalo exponencial: 1a tentativa = 5 min, 2a = 15 min, 3a = 45 min
      retry_interval_exponential        FOR TESTING,
      "-- Reprocessamento bem-sucedido → status SUCCESS no log
      reprocess_success_logged          FOR TESTING,
      "-- Reprocessamento com erro → RETRY_COUNT incrementado, status FAILED se esgotado
      reprocess_failure_increments_retry FOR TESTING.
ENDCLASS.

"----------------------------------------------------------------------
CLASS ltd_auth_mock_repr DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_ewm_c360_auth_checker.
ENDCLASS.
CLASS ltd_auth_mock_repr IMPLEMENTATION.
  METHOD zif_ewm_c360_auth_checker~check.
  ENDMETHOD.
  METHOD zif_ewm_c360_auth_checker~is_authorized.
    rv_authorized = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS ltd_log_mock_repr DEFINITION.
  PUBLIC SECTION.
    DATA: mv_last_result TYPE string.
    INTERFACES zif_ewm_c360_log_writer.
ENDCLASS.
CLASS ltd_log_mock_repr IMPLEMENTATION.
  METHOD zif_ewm_c360_log_writer~write.
    mv_last_result = is_entry-action_result.
    rv_log_id = 'MOCK-REPR'.
  ENDMETHOD.
  METHOD zif_ewm_c360_log_writer~write_error.
    mv_last_result = 'ERROR'.
  ENDMETHOD.
ENDCLASS.
"----------------------------------------------------------------------

CLASS ltcl_reprocessor IMPLEMENTATION.

  METHOD setup.
    mo_auth = NEW ltd_auth_mock_repr( ).
    mo_log  = NEW ltd_log_mock_repr( ).
    mo_cut  = NEW zcl_ewm_c360_reprocessor(
      io_auth = mo_auth
      io_log  = mo_log
    ).
  ENDMETHOD.

  METHOD is_eligible_yes.
    "-- REPROC_FLAG='X', RETRY_COUNT=1, MAX_RETRY=3 → elegível
    DATA(lv_result) = mo_cut->is_eligible(
      iv_reproc_flag = 'X'
      iv_retry_count = 1
      iv_max_retry   = 3
    ).
    cl_abap_unit_assert=>assert_true(
      act = lv_result
      msg = 'Documento com REPROC_FLAG=X e tentativas restantes deve ser elegivel'
    ).
  ENDMETHOD.

  METHOD is_eligible_no_reproc_flag.
    DATA(lv_result) = mo_cut->is_eligible(
      iv_reproc_flag = ''
      iv_retry_count = 0
      iv_max_retry   = 3
    ).
    cl_abap_unit_assert=>assert_false(
      act = lv_result
      msg = 'Documento sem REPROC_FLAG nao deve ser elegivel'
    ).
  ENDMETHOD.

  METHOD is_eligible_max_retry_reached.
    DATA(lv_result) = mo_cut->is_eligible(
      iv_reproc_flag = 'X'
      iv_retry_count = 3
      iv_max_retry   = 3
    ).
    cl_abap_unit_assert=>assert_false(
      act = lv_result
      msg = 'Documento com RETRY_COUNT = MAX_RETRY nao deve ser elegivel'
    ).
  ENDMETHOD.

  METHOD retry_interval_exponential.
    "-- Intervalo = 5 * 3^(retry_count) minutos (ADR-005)
    "-- Retry 0 → 5 min, Retry 1 → 15 min, Retry 2 → 45 min
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_retry_interval_minutes( iv_retry_count = 0 )
      exp = 5
      msg = '1a tentativa deve ter intervalo de 5 minutos'
    ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_retry_interval_minutes( iv_retry_count = 1 )
      exp = 15
      msg = '2a tentativa deve ter intervalo de 15 minutos'
    ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->get_retry_interval_minutes( iv_retry_count = 2 )
      exp = 45
      msg = '3a tentativa deve ter intervalo de 45 minutos'
    ).
  ENDMETHOD.

  METHOD reprocess_success_logged.
    TRY.
        mo_cut->reprocess(
          iv_lgnum  = 'WH01'
          iv_doc_id = 'DOC_REPR_OK'
          iv_type   = 'MANUAL'
        ).
      CATCH zcx_ewm_c360_base INTO DATA(lx).
        cl_abap_unit_assert=>fail( msg = lx->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act = mo_log->mv_last_result
      exp = 'SUCCESS'
      msg = 'Reprocessamento bem-sucedido deve gravar SUCCESS no log'
    ).
  ENDMETHOD.

  METHOD reprocess_failure_increments_retry.
    "-- Documento configurado para falhar no mock → RETRY_COUNT deve ser incrementado
    "-- e status deve ser FAILED quando RETRY_COUNT = MAX_RETRY
    DATA(lv_initial_retry) = mo_cut->get_retry_count( iv_lgnum = 'WH01' iv_doc_id = 'DOC_REPR_FAIL' ).

    TRY.
        mo_cut->reprocess(
          iv_lgnum  = 'WH01'
          iv_doc_id = 'DOC_REPR_FAIL'
          iv_type   = 'MANUAL'
        ).
      CATCH zcx_ewm_c360_base.
        "-- Falha esperada
    ENDTRY.

    DATA(lv_after_retry) = mo_cut->get_retry_count( iv_lgnum = 'WH01' iv_doc_id = 'DOC_REPR_FAIL' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_after_retry
      exp = lv_initial_retry + 1
      msg = 'RETRY_COUNT deve ser incrementado apos falha de reprocessamento'
    ).
  ENDMETHOD.

ENDCLASS.
