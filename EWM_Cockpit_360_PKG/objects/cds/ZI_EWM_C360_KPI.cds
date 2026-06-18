/*
  View    : ZI_EWM_C360_KPI
  Tipo    : Interface View (ZI_)
  Fonte   : ZTEWM_C360_KPI + ZTEWM_C360_KPI_DEF
  Finalidade: Une valores calculados com definição mestre do KPI.
              Base para ZC_EWM_C360_KPI e ZC_EWM_C360_ANA_KPI.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - KPIs Calculados (Interface)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #L,
  dataClass:      #TRANSACTIONAL
}
define view entity ZI_EWM_C360_KPI
  as select from ztewm_c360_kpi as Kpi
  inner join   ztewm_c360_kpi_def as Def
    on  Kpi.mandt   = Def.mandt
    and Kpi.kpi_id  = Def.kpi_id
{
  key Kpi.lgnum         as Lgnum,
  key Kpi.kpi_id        as KpiId,
  key Kpi.period_date   as PeriodDate,
  key Kpi.granularity   as Granularity,
  key Kpi.process_type  as ProcessType,

      Def.kpi_name      as KpiName,
      Def.formula       as Formula,
      Def.owner         as Owner,
      Def.unit          as Unit,

      Kpi.actual_value  as ActualValue,
      Kpi.target_value  as TargetValue,
      Kpi.tolerance_pct as TolerancePct,
      Kpi.status_code   as StatusCode,
      Kpi.calc_timestamp as CalcTimestamp,
      Kpi.snap_ref      as SnapRef,

      /* Criticality para Fiori */
      case Kpi.status_code
        when 'CRITICAL' then 1
        when 'WARNING'  then 2
        when 'OK'       then 3
        else 0
      end as StatusCriticality,

      /* Desvio percentual */
      case when Kpi.target_value <> 0
        then cast( ( Kpi.actual_value - Kpi.target_value ) * 100 / Kpi.target_value as zdewm_c360_e_value )
        else cast( 0 as zdewm_c360_e_value )
      end as DeviationPct
}
where Kpi.mandt = $session.client
