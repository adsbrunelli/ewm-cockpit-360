*&---------------------------------------------------------------------*
*& Programa : ZEWM_C360_LOAD_TEST_DATA
*& Objetivo : Carregar dados de teste para execução dos cenários E2E
*&            em ambiente DEV/QAS. NÃO executar em PRD.
*& Uso      : SE38 → executar com LGNUM desejado
*&            Limpar dados: executar com p_clear = 'X' (default ativo)
*&---------------------------------------------------------------------*
REPORT zewm_c360_load_test_data.

PARAMETERS:
  p_lgnum TYPE /scwm/lgnum DEFAULT 'WH01' OBLIGATORY,
  p_clear TYPE abap_bool   DEFAULT 'X'    "-- 'X' = limpar antes (default ON)
    AS CHECKBOX.

START-OF-SELECTION.
  "-- Bloquear execução em PRD
  IF sy-sysid CP '*P' OR sy-sysid CP '*PRD'.
    WRITE: / 'ABORT: Este script NÃO pode ser executado em produção (SID:', sy-sysid, ')'.
    STOP.
  ENDIF.

  "-- Validar que LGNUM existe em /SCWM/T331
  SELECT SINGLE lgnum FROM /scwm/t331 INTO @DATA(lv_check)
    WHERE lgnum = @p_lgnum.
  IF sy-subrc <> 0.
    WRITE: / 'ERRO: Warehouse', p_lgnum, 'não existe em /SCWM/T331. Execução cancelada.'.
    STOP.
  ENDIF.

  "-- Alertar se já existem dados de teste
  IF p_clear = abap_false.
    SELECT COUNT(*) FROM ztewm_c360_hdr INTO @DATA(lv_count)
      WHERE lgnum = @p_lgnum AND doc_id LIKE 'TEST%'.
    IF lv_count > 0.
      WRITE: / 'AVISO:', lv_count, 'registros de teste já existem.',
             / 'Use p_clear=X para limpar antes de inserir. Abortando.'.
      STOP.
    ENDIF.
  ELSE.
    PERFORM clear_test_data USING p_lgnum.
  ENDIF.

  PERFORM load_hdr_data      USING p_lgnum.
  PERFORM load_item_data     USING p_lgnum.
  PERFORM load_exc_data      USING p_lgnum.
  PERFORM load_kpi_def_data  USING p_lgnum.
  PERFORM load_kpi_data      USING p_lgnum.
  PERFORM load_sev_rules     USING p_lgnum.
  PERFORM load_cust_params   USING p_lgnum.

  WRITE: / 'Dados de teste carregados com sucesso para LGNUM:', p_lgnum.

*----------------------------------------------------------------------*
FORM clear_test_data USING iv_lgnum TYPE /scwm/lgnum.
  DELETE FROM ztewm_c360_hdr    WHERE lgnum = iv_lgnum AND doc_id LIKE 'TEST%'.
  DELETE FROM ztewm_c360_item   WHERE lgnum = iv_lgnum AND doc_id LIKE 'TEST%'.
  DELETE FROM ztewm_c360_exc    WHERE lgnum = iv_lgnum AND exc_id LIKE 'EXC-TEST%'.
  DELETE FROM ztewm_c360_kpi    WHERE lgnum = iv_lgnum AND kpi_id LIKE 'TEST%'.
  DELETE FROM ztewm_c360_actlog WHERE lgnum = iv_lgnum AND doc_id LIKE 'TEST%'.
  COMMIT WORK.
  WRITE: / 'Dados de teste removidos para LGNUM:', iv_lgnum.
ENDFORM.

*----------------------------------------------------------------------*
FORM load_hdr_data USING iv_lgnum TYPE /scwm/lgnum.
  DATA: lt_hdr TYPE TABLE OF ztewm_c360_hdr,
        lv_now TYPE timestamp.

  GET TIME STAMP FIELD lv_now.

  APPEND VALUE #(
    lgnum             = iv_lgnum
    doc_id            = 'IBD-TEST-001'
    process_type      = 'INBOUND'
    status_code       = 'BLOCKED'
    reference_doc     = 'PO-TEST-001'
    open_date         = sy-datum - 3
    due_date          = sy-datum - 1
    has_exception     = 'X'
    reproc_flag       = 'X'
    retry_count       = 0
    responsible_user  = 'TESTUSER_IBD'
    priority          = '1'
    created_by        = sy-uname
    created_at        = lv_now
  ) TO lt_hdr.

  APPEND VALUE #(
    lgnum             = iv_lgnum
    doc_id            = 'OBD-TEST-001'
    process_type      = 'OUTBOUND'
    status_code       = 'BLOCKED'
    reference_doc     = 'SO-TEST-001'
    open_date         = sy-datum - 2
    due_date          = sy-datum
    has_exception     = ' '
    reproc_flag       = 'X'
    retry_count       = 0
    responsible_user  = 'TESTUSER_OBD'
    priority          = '2'
    created_by        = sy-uname
    created_at        = lv_now
  ) TO lt_hdr.

  APPEND VALUE #(
    lgnum             = iv_lgnum
    doc_id            = 'WT-TEST-001'
    process_type      = 'WT'
    status_code       = 'OPEN'
    reference_doc     = 'IBD-TEST-001'
    open_date         = sy-datum - 3   "-- 3 dias aberto, acima do WT_AGING_WARN_DAYS=2
    due_date          = sy-datum - 1
    has_exception     = ' '
    reproc_flag       = ' '
    retry_count       = 0
    responsible_user  = 'TESTUSER_C360'
    priority          = '1'
    created_by        = sy-uname
    created_at        = lv_now
  ) TO lt_hdr.

  "-- 10 documentos Inbound OPEN para E2E-001
  DO 10 TIMES.
    APPEND VALUE #(
      lgnum         = iv_lgnum
      doc_id        = |IBD-TEST-{ sy-index ALPHA = IN WIDTH = 3 }|
      process_type  = 'INBOUND'
      status_code   = 'OPEN'
      open_date     = sy-datum - sy-index
      due_date      = sy-datum + 1
      has_exception = ' '
      reproc_flag   = ' '
      retry_count   = 0
      created_by    = sy-uname
      created_at    = lv_now
    ) TO lt_hdr.
  ENDDO.

  INSERT ztewm_c360_hdr FROM TABLE lt_hdr ACCEPTING DUPLICATE KEYS.
  COMMIT WORK.
  WRITE: / '  HDR: ', sy-dbcnt, 'registros inseridos.'.
ENDFORM.

*----------------------------------------------------------------------*
FORM load_item_data USING iv_lgnum TYPE /scwm/lgnum.
  DATA lv_now TYPE timestamp.
  GET TIME STAMP FIELD lv_now.

  INSERT ztewm_c360_item FROM TABLE VALUE #(
    ( lgnum = iv_lgnum doc_id = 'IBD-TEST-001' item_no = '001'
      matnr = 'MAT-001' qty_planned = '100' qty_actual = '85'
      unit = 'PC' storage_bin = 'BIN-001' status_code = 'OPEN'
      created_at = lv_now )
    ( lgnum = iv_lgnum doc_id = 'IBD-TEST-001' item_no = '002'
      matnr = 'MAT-002' qty_planned = '50' qty_actual = '50'
      unit = 'PC' storage_bin = 'BIN-002' status_code = 'COMPLETED'
      created_at = lv_now )
  ) ACCEPTING DUPLICATE KEYS.
  COMMIT WORK.
  WRITE: / '  ITEM:', sy-dbcnt, 'registros inseridos.'.
ENDFORM.

*----------------------------------------------------------------------*
FORM load_exc_data USING iv_lgnum TYPE /scwm/lgnum.
  DATA lv_now TYPE timestamp.
  GET TIME STAMP FIELD lv_now.

  DATA(lv_sla_due) = cl_abap_tstmp=>add(
    tstmp   = lv_now
    secs    = -3600  "-- SLA vencido há 1 hora
  ).

  INSERT ztewm_c360_exc FROM TABLE VALUE #(
    "-- Exceção CRITICAL com SLA vencido (para E2E-001 e E2E-002)
    ( lgnum = iv_lgnum exc_id = 'EXC-TEST-001' exc_type = 'GOODS_RECEIPT_DIFF'
      severity = 'CRITICAL' status_code = 'OPEN' process_type = 'INBOUND'
      doc_id = 'IBD-TEST-001' item_no = '001'
      root_cause = 'Divergencia de quantidade no recebimento'
      sla_due_at = lv_sla_due
      reproc_flag = 'X' retry_count = 0 resolved_flag = ' '
      created_by = sy-uname created_at = lv_now )
    "-- Exceção HIGH
    ( lgnum = iv_lgnum exc_id = 'EXC-TEST-002' exc_type = 'PICKING_DIFF'
      severity = 'HIGH' status_code = 'OPEN' process_type = 'OUTBOUND'
      doc_id = 'OBD-TEST-001'
      sla_due_at = cl_abap_tstmp=>add( tstmp = lv_now secs = 7200 )
      reproc_flag = 'X' retry_count = 0 resolved_flag = ' '
      created_by = sy-uname created_at = lv_now )
    "-- Exceção CRITICAL adicional
    ( lgnum = iv_lgnum exc_id = 'EXC-TEST-003' exc_type = 'GOODS_RECEIPT_DIFF'
      severity = 'CRITICAL' status_code = 'OPEN' process_type = 'INBOUND'
      doc_id = 'IBD-TEST-002'
      sla_due_at = lv_sla_due
      reproc_flag = ' ' retry_count = 0 resolved_flag = ' '
      created_by = sy-uname created_at = lv_now )
    "-- Exceção já resolvida (para testar filtro de RESOLVED)
    ( lgnum = iv_lgnum exc_id = 'EXC-JA-RESOLVIDA' exc_type = 'PICKING_DIFF'
      severity = 'LOW' status_code = 'RESOLVED' process_type = 'INBOUND'
      doc_id = 'IBD-TEST-003' resolved_flag = 'X'
      created_by = sy-uname created_at = lv_now )
  ) ACCEPTING DUPLICATE KEYS.
  COMMIT WORK.
  WRITE: / '  EXC: ', sy-dbcnt, 'registros inseridos.'.
ENDFORM.

*----------------------------------------------------------------------*
FORM load_kpi_def_data USING iv_lgnum TYPE /scwm/lgnum.
  INSERT ztewm_c360_kpi_def FROM TABLE VALUE #(
    ( kpi_id = 'INBOUND_ACCURACY' kpi_name = 'Acurácia de Recebimento'
      process_type = 'INBOUND' formula = '(QTY_ACTUAL / QTY_PLANNED) * 100'
      data_source = 'ZTEWM_C360_ITEM' calc_class = 'ZCL_EWM_C360_KPI_INBOUND'
      unit = '%' tolerance_pct = '10' target_value = '95' owner = 'TESTUSER_SUP'
      active_flag = 'X' )
    ( kpi_id = 'OUTBOUND_OTIF' kpi_name = 'OTIF Outbound'
      process_type = 'OUTBOUND' formula = 'ON_TIME_IN_FULL / TOTAL_ORDERS * 100'
      data_source = 'ZTEWM_C360_HDR' calc_class = 'ZCL_EWM_C360_KPI_OUTBOUND'
      unit = '%' tolerance_pct = '5' target_value = '98' owner = 'TESTUSER_SUP'
      active_flag = 'X' )
  ) ACCEPTING DUPLICATE KEYS.
  COMMIT WORK.
  WRITE: / '  KPI_DEF:', sy-dbcnt, 'registros inseridos.'.
ENDFORM.

*----------------------------------------------------------------------*
FORM load_kpi_data USING iv_lgnum TYPE /scwm/lgnum.
  DATA lv_now TYPE timestamp.
  GET TIME STAMP FIELD lv_now.

  "-- KPI com desvio CRITICAL para E2E-004 (valores de domínio: OK/WARNING/CRITICAL)
  INSERT ztewm_c360_kpi FROM TABLE VALUE #(
    ( lgnum = iv_lgnum kpi_id = 'INBOUND_ACCURACY' period_date = sy-datum
      granularity = 'DAY' process_type = 'INBOUND'
      actual_value = '78' target_value = '95' deviation_pct = '-17.89'
      status_code = 'CRITICAL' calc_timestamp = lv_now )
    ( lgnum = iv_lgnum kpi_id = 'OUTBOUND_OTIF' period_date = sy-datum
      granularity = 'DAY' process_type = 'OUTBOUND'
      actual_value = '99' target_value = '98' deviation_pct = '1.02'
      status_code = 'OK' calc_timestamp = lv_now )
  ) ACCEPTING DUPLICATE KEYS.
  COMMIT WORK.
  WRITE: / '  KPI: ', sy-dbcnt, 'registros inseridos.'.
ENDFORM.

*----------------------------------------------------------------------*
FORM load_sev_rules USING iv_lgnum TYPE /scwm/lgnum.
  "-- Regra global (LGNUM='*') como fallback
  INSERT ztewm_c360_sev_rule FROM TABLE VALUE #(
    ( lgnum = '*'       exc_type = 'GOODS_RECEIPT_DIFF' severity = 'CRITICAL' sla_hours = 4 active_flag = 'X' )
    ( lgnum = '*'       exc_type = 'PICKING_DIFF'       severity = 'HIGH'     sla_hours = 8 active_flag = 'X' )
    ( lgnum = iv_lgnum  exc_type = 'GOODS_RECEIPT_DIFF' severity = 'CRITICAL' sla_hours = 2 active_flag = 'X' )
  ) ACCEPTING DUPLICATE KEYS.
  COMMIT WORK.
  WRITE: / '  SEV_RULES:', sy-dbcnt, 'registros inseridos.'.
ENDFORM.

*----------------------------------------------------------------------*
FORM load_cust_params USING iv_lgnum TYPE /scwm/lgnum.
  INSERT ztewm_c360_cust FROM TABLE VALUE #(
    ( param_key = 'SNAP_DELTA_MINUTES' param_value = '15' )
    ( param_key = 'MAX_RETRY'          param_value = '3'  )
    ( param_key = 'WT_AGING_WARN_DAYS' param_value = '2'  )
    ( param_key = 'KPI_HISTORY_POINTS' param_value = '30' )
  ) ACCEPTING DUPLICATE KEYS.
  COMMIT WORK.
  WRITE: / '  CUST:', sy-dbcnt, 'registros inseridos.'.
ENDFORM.
