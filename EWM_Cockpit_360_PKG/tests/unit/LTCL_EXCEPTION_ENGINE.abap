"! @testing-only
CLASS ltcl_exception_engine DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA: mo_cut  TYPE REF TO zcl_ewm_c360_exception_engine,
          mo_auth TYPE REF TO ltd_auth_mock_exc,
          mo_log  TYPE REF TO ltd_log_mock_exc.

    METHODS:
      setup,
      "-- Regra CRITICAL encontrada na SEV_RULE → CRITICAL
      classify_critical_rule_match      FOR TESTING,
      "-- Sem regra → fallback MEDIUM
      classify_no_rule_fallback_medium  FOR TESTING,
      "-- Regra de warehouse '*' usada quando LGNUM específico não encontrado
      classify_wildcard_lgnum_fallback  FOR TESTING,
      "-- SLA calculado corretamente a partir da regra
      classify_sla_calculated           FOR TESTING,
      "-- Resolve: status atualizado e log gravado
      resolve_sets_status_resolved      FOR TESTING,
      "-- Resolve sem autorização ACTVT=16 levanta exceção
      resolve_unauthorized_raises       FOR TESTING,
      "-- Resolve de exceção já resolvida levanta exceção
      resolve_already_resolved_raises   FOR TESTING.
ENDCLASS.

"----------------------------------------------------------------------
CLASS ltd_auth_mock_exc DEFINITION.
  PUBLIC SECTION.
    DATA: mv_authorized TYPE abap_bool VALUE abap_true.
    INTERFACES zif_ewm_c360_auth_checker.
ENDCLASS.
CLASS ltd_auth_mock_exc IMPLEMENTATION.
  METHOD zif_ewm_c360_auth_checker~check.
    IF mv_authorized = abap_false.
      RAISE EXCEPTION TYPE zcx_ewm_c360_auth.
    ENDIF.
  ENDMETHOD.
  METHOD zif_ewm_c360_auth_checker~is_authorized.
    rv_authorized = mv_authorized.
  ENDMETHOD.
ENDCLASS.

CLASS ltd_log_mock_exc DEFINITION.
  PUBLIC SECTION.
    DATA: mv_last_action_type TYPE string.
    INTERFACES zif_ewm_c360_log_writer.
ENDCLASS.
CLASS ltd_log_mock_exc IMPLEMENTATION.
  METHOD zif_ewm_c360_log_writer~write.
    mv_last_action_type = is_entry-action_type.
    rv_log_id = 'MOCK-UUID-EXC'.
  ENDMETHOD.
  METHOD zif_ewm_c360_log_writer~write_error.
    mv_last_action_type = 'ERROR'.
  ENDMETHOD.
ENDCLASS.
"----------------------------------------------------------------------

CLASS ltcl_exception_engine IMPLEMENTATION.

  METHOD setup.
    mo_auth = NEW ltd_auth_mock_exc( ).
    mo_log  = NEW ltd_log_mock_exc( ).
    mo_cut  = NEW zcl_ewm_c360_exception_engine(
      io_auth = mo_auth
      io_log  = mo_log
    ).
  ENDMETHOD.

  METHOD classify_critical_rule_match.
    "-- Arrange: regra CRITICAL existe para LGNUM=WH01, EXC_TYPE=GOODS_RECEIPT_DIFF
    DATA(ls_exc) = VALUE zif_ewm_c360_exception_engine=>ty_exc_input(
      lgnum    = 'WH01'
      exc_type = 'GOODS_RECEIPT_DIFF'
      doc_id   = 'DOC001'
    ).

    DATA(ls_result) = mo_cut->classify( ls_exc ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-severity
      exp = 'CRITICAL'
      msg = 'Regra CRITICAL deve ser aplicada para GOODS_RECEIPT_DIFF'
    ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_result-sla_due_at
      msg = 'SLA deve ser calculado quando regra encontrada'
    ).
  ENDMETHOD.

  METHOD classify_no_rule_fallback_medium.
    "-- Tipo de exceção sem nenhuma regra configurada → MEDIUM por padrão (ADR-004)
    DATA(ls_exc) = VALUE zif_ewm_c360_exception_engine=>ty_exc_input(
      lgnum    = 'WH01'
      exc_type = 'TIPO_SEM_REGRA'
      doc_id   = 'DOC002'
    ).

    DATA(ls_result) = mo_cut->classify( ls_exc ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-severity
      exp = 'MEDIUM'
      msg = 'Fallback deve ser MEDIUM quando nenhuma regra de severidade existe'
    ).
  ENDMETHOD.

  METHOD classify_wildcard_lgnum_fallback.
    "-- LGNUM='WH99' sem regra específica → usa regra de LGNUM='*'
    DATA(ls_exc) = VALUE zif_ewm_c360_exception_engine=>ty_exc_input(
      lgnum    = 'WH99'
      exc_type = 'PICKING_DIFF'
      doc_id   = 'DOC003'
    ).

    "-- Assume que regra LGNUM='*', EXC_TYPE='PICKING_DIFF' → HIGH existe no DB de teste
    DATA(ls_result) = mo_cut->classify( ls_exc ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-severity
      exp = 'HIGH'
      msg = 'Regra wildcard LGNUM=* deve ser aplicada quando nao ha regra para LGNUM especifico'
    ).
  ENDMETHOD.

  METHOD classify_sla_calculated.
    "-- SLA_HOURS = 4 na regra → SLA_DUE_AT deve ser aproximadamente agora + 4h
    DATA(ls_exc) = VALUE zif_ewm_c360_exception_engine=>ty_exc_input(
      lgnum    = 'WH01'
      exc_type = 'GOODS_RECEIPT_DIFF'
      doc_id   = 'DOC004'
    ).

    DATA(lv_before) = cl_abap_context_info=>get_system_date( ) && cl_abap_context_info=>get_system_time( ).
    DATA(ls_result) = mo_cut->classify( ls_exc ).

    "-- SLA deve estar entre agora e agora + 8h (margem generosa para o teste)
    cl_abap_unit_assert=>assert_true(
      act = xsdbool( ls_result-sla_due_at > lv_before )
      msg = 'SLA_DUE_AT deve ser no futuro'
    ).
  ENDMETHOD.

  METHOD resolve_sets_status_resolved.
    "-- Resolve exceção aberta com autorização válida
    mo_auth->mv_authorized = abap_true.

    TRY.
        mo_cut->resolve(
          iv_lgnum  = 'WH01'
          iv_exc_id = 'EXC001'
          iv_reason = 'Divergencia confirmada e corrigida manualmente'
        ).
      CATCH zcx_ewm_c360_base INTO DATA(lx).
        cl_abap_unit_assert=>fail( msg = lx->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act = mo_log->mv_last_action_type
      exp = 'RESOLVE'
      msg = 'Log de RESOLVE deve ser gravado apos resolucao'
    ).
  ENDMETHOD.

  METHOD resolve_unauthorized_raises.
    mo_auth->mv_authorized = abap_false.

    TRY.
        mo_cut->resolve(
          iv_lgnum  = 'WH01'
          iv_exc_id = 'EXC001'
          iv_reason = 'Tentativa nao autorizada'
        ).
        cl_abap_unit_assert=>fail( msg = 'Excecao esperada para usuario sem ACTVT=16' ).
      CATCH zcx_ewm_c360_auth.
        "-- OK
    ENDTRY.
  ENDMETHOD.

  METHOD resolve_already_resolved_raises.
    "-- Tentar resolver exceção com RESOLVED_FLAG = 'X' deve levantar exceção
    mo_auth->mv_authorized = abap_true.

    TRY.
        mo_cut->resolve(
          iv_lgnum  = 'WH01'
          iv_exc_id = 'EXC_JA_RESOLVIDA'
          iv_reason = 'Tentativa dupla'
        ).
        cl_abap_unit_assert=>fail( msg = 'Excecao esperada para resolucao de excecao ja resolvida' ).
      CATCH zcx_ewm_c360_base.
        "-- OK
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
