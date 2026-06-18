"! Testes de integração das CDS Views — requerem dados reais no banco.
"! Executar em ambiente de DEV/QAS com dados de teste carregados.
"! @testing-only
CLASS ltcl_cds_views DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL DANGEROUS.   "-- lê tabelas reais

  PRIVATE SECTION.
    CONSTANTS: gc_lgnum TYPE /scwm/lgnum VALUE 'WH01'.

    METHODS:
      "-- ZI_EWM_C360_HDR retorna registros para warehouse válido
      zi_hdr_returns_data              FOR TESTING,
      "-- ZI_EWM_C360_HDR AgingDays calculado (>= 0)
      zi_hdr_aging_days_positive       FOR TESTING,
      "-- ZI_EWM_C360_HDR StatusCriticality dentro do range válido (0-3)
      zi_hdr_criticality_valid_range   FOR TESTING,
      "-- ZI_EWM_C360_EXC SlaExpired consistente com SlaDueAt
      zi_exc_sla_expired_consistent    FOR TESTING,
      "-- ZI_EWM_C360_KPI DeviationPct calculado corretamente
      zi_kpi_deviation_calculated      FOR TESTING,
      "-- ZI_EWM_C360_VH_LGNUM retorna warehouses ativos
      zi_vh_lgnum_not_empty            FOR TESTING,
      "-- ZC_EWM_C360_EXCEPTION respeita access control (AUTHORITY-CHECK)
      zc_exception_auth_check          FOR TESTING,
      "-- ZC_EWM_C360_KPI JOIN com KPI_DEF não retorna KPIs sem definição ativa
      zc_kpi_only_active_defs          FOR TESTING.
ENDCLASS.

CLASS ltcl_cds_views IMPLEMENTATION.

  METHOD zi_hdr_returns_data.
    SELECT COUNT(*) FROM zi_ewm_c360_hdr
      WHERE lgnum = @gc_lgnum
      INTO @DATA(lv_count).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( lv_count > 0 )
      msg = |ZI_EWM_C360_HDR sem dados para LGNUM { gc_lgnum } — carregar dados de teste|
    ).
  ENDMETHOD.

  METHOD zi_hdr_aging_days_positive.
    SELECT aging_days FROM zi_ewm_c360_hdr
      WHERE lgnum = @gc_lgnum
      INTO TABLE @DATA(lt_aging).

    LOOP AT lt_aging ASSIGNING FIELD-SYMBOL(<ls>).
      cl_abap_unit_assert=>assert_true(
        act = xsdbool( <ls>-aging_days >= 0 )
        msg = |AgingDays negativo detectado — erro no campo calculado|
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zi_hdr_criticality_valid_range.
    SELECT status_criticality FROM zi_ewm_c360_hdr
      WHERE lgnum = @gc_lgnum
      INTO TABLE @DATA(lt_crit).

    LOOP AT lt_crit ASSIGNING FIELD-SYMBOL(<ls>).
      cl_abap_unit_assert=>assert_true(
        act = xsdbool( <ls>-status_criticality BETWEEN 0 AND 3 )
        msg = |StatusCriticality { <ls>-status_criticality } fora do range 0-3|
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zi_exc_sla_expired_consistent.
    "-- SlaExpired = 1 somente quando SlaDueAt < agora
    DATA(lv_now) = cl_abap_context_info=>get_system_date( ) && cl_abap_context_info=>get_system_time( ).

    SELECT sla_due_at, sla_expired FROM zi_ewm_c360_exc
      WHERE lgnum = @gc_lgnum
      INTO TABLE @DATA(lt_sla).

    LOOP AT lt_sla ASSIGNING FIELD-SYMBOL(<ls>).
      IF <ls>-sla_expired = abap_true.
        cl_abap_unit_assert=>assert_true(
          act = xsdbool( <ls>-sla_due_at < lv_now )
          msg = |SlaExpired=true mas SlaDueAt { <ls>-sla_due_at } esta no futuro — inconsistencia|
        ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zi_kpi_deviation_calculated.
    "-- DeviationPct = (ActualValue - TargetValue) / TargetValue * 100
    SELECT actual_value, target_value, deviation_pct FROM zi_ewm_c360_kpi
      WHERE lgnum = @gc_lgnum AND target_value <> 0
      INTO TABLE @DATA(lt_kpi).

    LOOP AT lt_kpi ASSIGNING FIELD-SYMBOL(<ls>).
      DATA(lv_expected) = ( <ls>-actual_value - <ls>-target_value ) / <ls>-target_value * 100.
      "-- Tolerância de 0.01 para arredondamento de ponto flutuante
      cl_abap_unit_assert=>assert_true(
        act = xsdbool( abs( <ls>-deviation_pct - lv_expected ) < '0.01' )
        msg = |DeviationPct calculado incorretamente para KPI|
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zi_vh_lgnum_not_empty.
    SELECT COUNT(*) FROM zi_ewm_c360_vh_lgnum INTO @DATA(lv_count).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( lv_count > 0 )
      msg = 'ZI_EWM_C360_VH_LGNUM vazio — /SCWM/T331 sem warehouses ativos'
    ).
  ENDMETHOD.

  METHOD zc_exception_auth_check.
    "-- View com @AccessControl: usuário atual deve ver apenas LGNUMs autorizados
    "-- Este teste verifica que a view não retorna dados de outros warehouses
    SELECT lgnum FROM zc_ewm_c360_exception
      INTO TABLE @DATA(lt_exc).

    "-- Todo LGNUM retornado deve ser autorizado para o usuário de teste
    LOOP AT lt_exc ASSIGNING FIELD-SYMBOL(<ls>).
      AUTHORITY-CHECK OBJECT 'Z_EWM_C360A'
        ID 'LGNUM'   FIELD <ls>-lgnum
        ID 'PROCESS' FIELD 'EXCEPTION'
        ID 'ACTVT'   FIELD '03'.

      cl_abap_unit_assert=>assert_equals(
        act = sy-subrc
        exp = 0
        msg = |View retornou LGNUM { <ls>-lgnum } sem autorizacao — falha no access control|
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zc_kpi_only_active_defs.
    "-- JOIN com ZTEWM_C360_KPI_DEF: não deve retornar KPIs cuja definição está inativa
    SELECT kpi_id FROM zc_ewm_c360_kpi
      WHERE lgnum = @gc_lgnum
      INTO TABLE @DATA(lt_kpis).

    LOOP AT lt_kpis ASSIGNING FIELD-SYMBOL(<ls>).
      SELECT SINGLE active_flag FROM ztewm_c360_kpi_def
        WHERE kpi_id = @<ls>-kpi_id
        INTO @DATA(lv_active).

      cl_abap_unit_assert=>assert_equals(
        act = lv_active
        exp = 'X'
        msg = |ZC_EWM_C360_KPI retornou KPI { <ls>-kpi_id } com definicao inativa|
      ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
