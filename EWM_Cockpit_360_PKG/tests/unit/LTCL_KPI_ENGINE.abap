"! @testing-only
CLASS ltcl_kpi_engine DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA: mo_cut  TYPE REF TO zcl_ewm_c360_kpi_engine,
          mo_auth TYPE REF TO ltd_auth_mock_kpi,
          mo_log  TYPE REF TO ltd_log_mock_kpi.

    METHODS:
      setup,
      "-- KPI dentro da tolerância → status GREEN
      calculate_within_tolerance      FOR TESTING,
      "-- KPI fora da tolerância → status RED
      calculate_outside_tolerance     FOR TESTING,
      "-- KPI exatamente no limite da tolerância → status YELLOW
      calculate_at_tolerance_boundary FOR TESTING,
      "-- KPI sem definição ativa → exceção
      calculate_missing_kpi_def       FOR TESTING,
      "-- Valor real = 0 não causa divisão por zero
      calculate_zero_actual_safe      FOR TESTING,
      "-- Log gravado após cálculo
      calculate_writes_log            FOR TESTING.
ENDCLASS.

"----------------------------------------------------------------------
CLASS ltd_auth_mock_kpi DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_ewm_c360_auth_checker.
ENDCLASS.
CLASS ltd_auth_mock_kpi IMPLEMENTATION.
  METHOD zif_ewm_c360_auth_checker~check. "-- sempre autorizado
  ENDMETHOD.
  METHOD zif_ewm_c360_auth_checker~is_authorized.
    rv_authorized = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS ltd_log_mock_kpi DEFINITION.
  PUBLIC SECTION.
    DATA: mv_write_called TYPE abap_bool.
    INTERFACES zif_ewm_c360_log_writer.
ENDCLASS.
CLASS ltd_log_mock_kpi IMPLEMENTATION.
  METHOD zif_ewm_c360_log_writer~write.
    mv_write_called = abap_true.
    rv_log_id = 'MOCK-UUID-001'.
  ENDMETHOD.
  METHOD zif_ewm_c360_log_writer~write_error.
    mv_write_called = abap_true.
  ENDMETHOD.
ENDCLASS.
"----------------------------------------------------------------------

CLASS ltcl_kpi_engine IMPLEMENTATION.

  METHOD setup.
    mo_auth = NEW ltd_auth_mock_kpi( ).
    mo_log  = NEW ltd_log_mock_kpi( ).
    mo_cut  = NEW zcl_ewm_c360_kpi_engine(
      io_auth = mo_auth
      io_log  = mo_log
    ).
  ENDMETHOD.

  METHOD calculate_within_tolerance.
    "-- Meta = 100, Actual = 95, Tolerância = 10% → GREEN
    DATA(ls_input) = VALUE zif_ewm_c360_kpi_engine=>ty_kpi_input(
      lgnum         = 'WH01'
      kpi_id        = 'INBOUND_ACCURACY'
      actual_value  = '95'
      target_value  = '100'
      tolerance_pct = '10'
    ).

    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-status_code
      exp = 'GREEN'
      msg = 'Desvio de 5% dentro de tolerancia 10% deve ser GREEN'
    ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-deviation_pct
      exp = '-5'
      msg = 'Desvio calculado incorreto'
    ).
  ENDMETHOD.

  METHOD calculate_outside_tolerance.
    "-- Meta = 100, Actual = 80, Tolerância = 10% → RED (desvio 20%)
    DATA(ls_input) = VALUE zif_ewm_c360_kpi_engine=>ty_kpi_input(
      lgnum         = 'WH01'
      kpi_id        = 'INBOUND_ACCURACY'
      actual_value  = '80'
      target_value  = '100'
      tolerance_pct = '10'
    ).

    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-status_code
      exp = 'RED'
      msg = 'Desvio de 20% acima de tolerancia 10% deve ser RED'
    ).
  ENDMETHOD.

  METHOD calculate_at_tolerance_boundary.
    "-- Meta = 100, Actual = 90, Tolerância = 10% → YELLOW (exatamente no limite)
    DATA(ls_input) = VALUE zif_ewm_c360_kpi_engine=>ty_kpi_input(
      lgnum         = 'WH01'
      kpi_id        = 'INBOUND_ACCURACY'
      actual_value  = '90'
      target_value  = '100'
      tolerance_pct = '10'
    ).

    DATA(ls_result) = mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-status_code
      exp = 'YELLOW'
      msg = 'Desvio exatamente no limite deve ser YELLOW'
    ).
  ENDMETHOD.

  METHOD calculate_missing_kpi_def.
    "-- KPI sem definição ativa em ZTEWM_C360_KPI_DEF
    DATA(ls_input) = VALUE zif_ewm_c360_kpi_engine=>ty_kpi_input(
      lgnum   = 'WH01'
      kpi_id  = 'KPI_INEXISTENTE'
      actual_value  = '50'
      target_value  = '100'
      tolerance_pct = '5'
    ).

    TRY.
        mo_cut->calculate( ls_input ).
        cl_abap_unit_assert=>fail( msg = 'Excecao esperada para KPI sem definicao ativa' ).
      CATCH zcx_ewm_c360_base.
        "-- OK
    ENDTRY.
  ENDMETHOD.

  METHOD calculate_zero_actual_safe.
    "-- Actual = 0 não deve causar divisão por zero no cálculo de desvio
    DATA(ls_input) = VALUE zif_ewm_c360_kpi_engine=>ty_kpi_input(
      lgnum         = 'WH01'
      kpi_id        = 'INBOUND_ACCURACY'
      actual_value  = '0'
      target_value  = '100'
      tolerance_pct = '5'
    ).

    TRY.
        DATA(ls_result) = mo_cut->calculate( ls_input ).
        cl_abap_unit_assert=>assert_equals(
          act = ls_result-status_code
          exp = 'RED'
          msg = 'Actual = 0 deve resultar em RED sem DUMP'
        ).
      CATCH zcx_ewm_c360_base INTO DATA(lx).
        cl_abap_unit_assert=>fail( msg = lx->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD calculate_writes_log.
    DATA(ls_input) = VALUE zif_ewm_c360_kpi_engine=>ty_kpi_input(
      lgnum         = 'WH01'
      kpi_id        = 'INBOUND_ACCURACY'
      actual_value  = '95'
      target_value  = '100'
      tolerance_pct = '10'
    ).

    mo_cut->calculate( ls_input ).

    cl_abap_unit_assert=>assert_true(
      act = mo_log->mv_write_called
      msg = 'Log deve ser gravado apos calculo de KPI'
    ).
  ENDMETHOD.

ENDCLASS.
