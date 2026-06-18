/*
  DCL     : ZI_EWM_C360_HDR
  Tipo    : Access Control (define role)
  Protege : ZI_EWM_C360_HDR
  Objeto  : Z_EWM_C360A (LGNUM + PROCESS + ACTVT)
  Estratégia: Filtra linhas onde o usuário tem ACTVT=03 (Display)
              para o warehouse (LGNUM) e processo (PROCESS) da linha.
*/
@EndUserText.label: 'Access control: ZI_EWM_C360_HDR'
@MappingRole: true
define role ZI_EWM_C360_HDR {
  grant select on ZI_EWM_C360_HDR
    where (Lgnum, ProcessType) = aspect pfcg_auth(Z_EWM_C360A, LGNUM, PROCESS, ACTVT = '03');
}
