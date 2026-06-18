/*
  DCL     : ZC_EWM_C360_HU
  Protege : ZC_EWM_C360_HU
  Objeto  : Z_EWM_C360A (LGNUM + PROCESS=HU + ACTVT=03)
*/
@EndUserText.label: 'Access control: ZC_EWM_C360_HU'
@MappingRole: true
define role ZC_EWM_C360_HU {
  grant select on ZC_EWM_C360_HU
    where (Lgnum) = aspect pfcg_auth(Z_EWM_C360A, LGNUM, PROCESS = 'HU', ACTVT = '03');
}
