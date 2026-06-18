/*
  DCL     : ZI_EWM_C360_KPI
  Tipo    : Access Control (define role)
  Protege : ZI_EWM_C360_KPI
  Objeto  : Z_EWM_C360A (LGNUM + PROCESS + ACTVT)
  Estratégia: KPIs filtrados por warehouse e processo.
              Role Z_EWM_C360_EXEC deve ter PROCESS=KPI ou PROCESS=*
              para visualizar os indicadores.
*/
@EndUserText.label: 'Access control: ZI_EWM_C360_KPI'
@MappingRole: true
define role ZI_EWM_C360_KPI {
  grant select on ZI_EWM_C360_KPI
    where (Lgnum, ProcessType) = aspect pfcg_auth(Z_EWM_C360A, LGNUM, PROCESS, ACTVT = '03');
}
