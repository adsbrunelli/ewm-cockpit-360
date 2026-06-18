"! @testing-only
CLASS ltcl_snapshot_runner DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA: mo_cut TYPE REF TO zcl_ewm_c360_snapshot_runner,
          mo_log TYPE REF TO ltd_log_mock_snap.

    METHODS:
      setup,
      "-- Lock adquirido com sucesso → execução prossegue
      acquire_lock_success              FOR TESTING,
      "-- Lock já existe → execução bloqueada sem exceção destrutiva
      acquire_lock_already_locked       FOR TESTING,
      "-- Release chamado mesmo após falha (finally)
      release_always_called_after_error FOR TESTING,
      "-- Delta timestamp calculado corretamente
      delta_timestamp_calculated        FOR TESTING,
      "-- SNAP_TYPE=FULL ignora DELTA_FROM_TS
      full_snapshot_ignores_delta       FOR TESTING.
ENDCLASS.

"----------------------------------------------------------------------
CLASS ltd_log_mock_snap DEFINITION.
  PUBLIC SECTION.
    DATA: mv_write_called TYPE abap_bool.
    INTERFACES zif_ewm_c360_log_writer.
ENDCLASS.
CLASS ltd_log_mock_snap IMPLEMENTATION.
  METHOD zif_ewm_c360_log_writer~write.
    mv_write_called = abap_true.
    rv_log_id = 'MOCK-SNAP'.
  ENDMETHOD.
  METHOD zif_ewm_c360_log_writer~write_error.
    mv_write_called = abap_true.
  ENDMETHOD.
ENDCLASS.
"----------------------------------------------------------------------

CLASS ltcl_snapshot_runner IMPLEMENTATION.

  METHOD setup.
    mo_log = NEW ltd_log_mock_snap( ).
    mo_cut = NEW zcl_ewm_c360_snapshot_runner( io_log = mo_log ).
  ENDMETHOD.

  METHOD acquire_lock_success.
    "-- LOCK_FLAG = '' → deve adquirir lock e retornar abap_true
    DATA(lv_locked) = mo_cut->acquire_lock( iv_lgnum = 'WH01' iv_snap_type = 'DELTA' ).

    cl_abap_unit_assert=>assert_true(
      act = lv_locked
      msg = 'Lock deve ser adquirido quando SNAP_CTL esta disponivel'
    ).

    "-- Cleanup: liberar lock para não poluir outros testes
    mo_cut->release_lock( iv_lgnum = 'WH01' iv_snap_type = 'DELTA' ).
  ENDMETHOD.

  METHOD acquire_lock_already_locked.
    "-- Simula execução concorrente: lock já adquirido por outro processo
    "-- Primeiro acquire: sucesso
    mo_cut->acquire_lock( iv_lgnum = 'WH01' iv_snap_type = 'DELTA' ).

    "-- Segundo acquire do mesmo registro: deve retornar abap_false (não levantar exceção)
    DATA(lv_second) = mo_cut->acquire_lock( iv_lgnum = 'WH01' iv_snap_type = 'DELTA' ).

    cl_abap_unit_assert=>assert_false(
      act = lv_second
      msg = 'Segundo acquire deve retornar false quando ja bloqueado (sem excecao)'
    ).

    mo_cut->release_lock( iv_lgnum = 'WH01' iv_snap_type = 'DELTA' ).
  ENDMETHOD.

  METHOD release_always_called_after_error.
    "-- Mesmo com erro durante execução do snapshot, release_lock deve ser chamado
    mo_cut->acquire_lock( iv_lgnum = 'WH01' iv_snap_type = 'DELTA' ).

    TRY.
        mo_cut->run(
          iv_lgnum     = 'WH01'
          iv_snap_type = 'DELTA'
          iv_force_error = abap_true  "-- parâmetro de teste para simular falha
        ).
      CATCH zcx_ewm_c360_base.
        "-- Esperado
    ENDTRY.

    "-- Após o erro, LOCK_FLAG deve estar limpo (release foi chamado no CLEANUP/finally)
    DATA(lv_still_locked) = mo_cut->is_locked( iv_lgnum = 'WH01' iv_snap_type = 'DELTA' ).
    cl_abap_unit_assert=>assert_false(
      act = lv_still_locked
      msg = 'LOCK_FLAG deve ser limpo mesmo apos excecao durante execucao'
    ).
  ENDMETHOD.

  METHOD delta_timestamp_calculated.
    "-- DELTA_FROM_TS deve ser = última execução bem-sucedida (DELTA_TO_TS anterior)
    "-- DELTA_TO_TS deve ser = agora (momento do início da execução)
    DATA(ls_timestamps) = mo_cut->get_delta_range( iv_lgnum = 'WH01' ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( ls_timestamps-delta_to > ls_timestamps-delta_from )
      msg = 'DELTA_TO deve ser posterior a DELTA_FROM'
    ).
    cl_abap_unit_assert=>assert_not_initial(
      act = ls_timestamps-delta_from
      msg = 'DELTA_FROM nao deve ser vazio (usar ultima execucao)'
    ).
  ENDMETHOD.

  METHOD full_snapshot_ignores_delta.
    "-- FULL snapshot não deve usar DELTA_FROM_TS — lê tudo
    DATA(ls_timestamps) = mo_cut->get_delta_range(
      iv_lgnum     = 'WH01'
      iv_snap_type = 'FULL'
    ).

    cl_abap_unit_assert=>assert_initial(
      act = ls_timestamps-delta_from
      msg = 'SNAP_TYPE=FULL deve ignorar DELTA_FROM_TS (ler tudo)'
    ).
  ENDMETHOD.

ENDCLASS.
