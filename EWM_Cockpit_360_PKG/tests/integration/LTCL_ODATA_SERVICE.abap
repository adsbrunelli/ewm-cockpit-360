"! Testes de integração do OData Service ZEWM_C360_SRV.
"! Verificam metadados, leitura de entity sets e filtros básicos.
"! Executar com usuário que tenha Z_EWM_C360_EXEC no ambiente de QAS.
"! @testing-only
CLASS ltcl_odata_service DEFINITION FINAL FOR TESTING
  DURATION LONG
  RISK LEVEL DANGEROUS.

  PRIVATE SECTION.
    CONSTANTS:
      gc_service_name TYPE string VALUE 'ZEWM_C360_SRV',
      gc_lgnum        TYPE string VALUE 'WH01'.

    METHODS:
      "-- Serviço existe e está ativo no Gateway
      service_is_registered             FOR TESTING,
      "-- $metadata retorna todos os entity types esperados
      metadata_contains_all_entities    FOR TESTING,
      "-- ZC_EWM_C360_EXCEPTION aceita filtro por Lgnum
      exception_entity_lgnum_filter     FOR TESTING,
      "-- ZC_EWM_C360_KPI aceita filtro por Granularity
      kpi_entity_granularity_filter     FOR TESTING,
      "-- Action 'resolve' existe nos metadados
      resolve_action_in_metadata        FOR TESTING.
ENDCLASS.

CLASS ltcl_odata_service IMPLEMENTATION.

  METHOD service_is_registered.
    "-- Verificar existência do serviço na tabela /IWFND/MAINT_SERVICE
    SELECT SINGLE service_name FROM /iwfnd/med_srhl
      WHERE ext_service_name = @gc_service_name
      INTO @DATA(lv_svc).

    cl_abap_unit_assert=>assert_not_initial(
      act = lv_svc
      msg = |Servico { gc_service_name } nao registrado no Gateway — executar /IWFND/MAINT_SERVICE|
    ).
  ENDMETHOD.

  METHOD metadata_contains_all_entities.
    "-- Lista de entity sets esperados no serviço
    DATA(lt_expected) = VALUE string_table(
      ( `ZC_EWM_C360_OVERVIEW` )
      ( `ZC_EWM_C360_INBOUND` )
      ( `ZC_EWM_C360_OUTBOUND` )
      ( `ZC_EWM_C360_HU` )
      ( `ZC_EWM_C360_WT` )
      ( `ZC_EWM_C360_EXCEPTION` )
      ( `ZC_EWM_C360_KPI` )
    ).

    "-- Lê entity sets registrados para o serviço
    SELECT entity_set_name FROM /iwbep/i_sbdef_es
      WHERE service_name = @gc_service_name
      INTO TABLE @DATA(lt_registered).

    LOOP AT lt_expected ASSIGNING FIELD-SYMBOL(<lv_exp>).
      READ TABLE lt_registered WITH KEY table_line = <lv_exp> TRANSPORTING NO FIELDS.
      cl_abap_unit_assert=>assert_subrc(
        act = sy-subrc
        exp = 0
        msg = |Entity set { <lv_exp> } ausente no servico { gc_service_name }|
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD exception_entity_lgnum_filter.
    "-- SELECT com filtro Lgnum não deve levantar exceção de sintaxe CDS
    SELECT COUNT(*) FROM zc_ewm_c360_exception
      WHERE lgnum = @gc_lgnum
      INTO @DATA(lv_count).

    "-- O teste valida apenas que a query executa sem DUMP
    cl_abap_unit_assert=>assert_true(
      act = xsdbool( lv_count >= 0 )
      msg = 'Query com filtro Lgnum em ZC_EWM_C360_EXCEPTION falhou'
    ).
  ENDMETHOD.

  METHOD kpi_entity_granularity_filter.
    SELECT COUNT(*) FROM zc_ewm_c360_kpi
      WHERE lgnum      = @gc_lgnum
        AND granularity = 'DAY'
      INTO @DATA(lv_count).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( lv_count >= 0 )
      msg = 'Query com filtro Granularity=DAY em ZC_EWM_C360_KPI falhou'
    ).
  ENDMETHOD.

  METHOD resolve_action_in_metadata.
    "-- Verificar que a function import 'resolve' está registrada
    SELECT SINGLE func_import_name FROM /iwbep/i_sbdef_fi
      WHERE service_name      = @gc_service_name
        AND func_import_name  = 'resolve'
      INTO @DATA(lv_action).

    cl_abap_unit_assert=>assert_not_initial(
      act = lv_action
      msg = |Action 'resolve' nao encontrada no servico { gc_service_name }|
    ).
  ENDMETHOD.

ENDCLASS.
