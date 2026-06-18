/*
  DCL     : ZC_EWM_C360_WT
  Protege : ZC_EWM_C360_WT
  Objeto  : Z_EWM_C360A (LGNUM + PROCESS=WT + ACTVT=03)
*/
@EndUserText.label: 'Access control: ZC_EWM_C360_WT'
@MappingRole: true
define role ZC_EWM_C360_WT {
  grant select on ZC_EWM_C360_WT
    where (Lgnum) = aspect pfcg_auth(Z_EWM_C360A, LGNUM, PROCESS = 'WT', ACTVT = '03');
}
