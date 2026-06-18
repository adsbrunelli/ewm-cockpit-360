/*
  DCL     : ZC_EWM_C360_OUTBOUND
  Protege : ZC_EWM_C360_OUTBOUND
  Objeto  : Z_EWM_C360A (LGNUM + PROCESS=OUTBOUND + ACTVT=03)
*/
@EndUserText.label: 'Access control: ZC_EWM_C360_OUTBOUND'
@MappingRole: true
define role ZC_EWM_C360_OUTBOUND {
  grant select on ZC_EWM_C360_OUTBOUND
    where (Lgnum) = aspect pfcg_auth(Z_EWM_C360A, LGNUM, PROCESS = 'OUTBOUND', ACTVT = '03');
}
