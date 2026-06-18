/*
  DCL     : ZC_EWM_C360_INBOUND
  Protege : ZC_EWM_C360_INBOUND
  Objeto  : Z_EWM_C360A (LGNUM + PROCESS=INBOUND + ACTVT=03)
  Nota    : A view já filtra ProcessType='INBOUND' no WHERE. O DCL reforça
            que o usuário deve ter PROCESS=INBOUND (ou *) autorizado no PFCG,
            impedindo que usuários OUTBOUND-only acessem via URL direta ou OData.
*/
@EndUserText.label: 'Access control: ZC_EWM_C360_INBOUND'
@MappingRole: true
define role ZC_EWM_C360_INBOUND {
  grant select on ZC_EWM_C360_INBOUND
    where (Lgnum) = aspect pfcg_auth(Z_EWM_C360A, LGNUM, PROCESS = 'INBOUND', ACTVT = '03');
}
