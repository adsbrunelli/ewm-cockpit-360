/*
  DCL     : ZI_EWM_C360_ACTLOG
  Tipo    : Access Control (define role)
  Protege : ZI_EWM_C360_ACTLOG
  Objeto  : Z_EWM_C360L (Log/Auditoria — LGNUM + ACTVT)
  Estratégia: Logs de ação são separados do objeto operacional (Z_EWM_C360A).
              Somente usuários com Z_EWM_C360L/ACTVT=03 visualizam logs.
              Garante SoD: operadores NÃO leem logs de outros operadores.
              Role Z_EWM_C360_AUDIT tem LGNUM=* para auditoria completa.
*/
@EndUserText.label: 'Access control: ZI_EWM_C360_ACTLOG'
@MappingRole: true
define role ZI_EWM_C360_ACTLOG {
  grant select on ZI_EWM_C360_ACTLOG
    where (Lgnum) = aspect pfcg_auth(Z_EWM_C360L, LGNUM, ACTVT = '03');
}
