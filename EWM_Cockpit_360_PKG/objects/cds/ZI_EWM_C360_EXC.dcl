/*
  DCL     : ZI_EWM_C360_EXC
  Tipo    : Access Control (define role)
  Protege : ZI_EWM_C360_EXC
  Objeto  : Z_EWM_C360A (LGNUM + PROCESS + ACTVT)
  Estratégia: Filtra exceções pelo warehouse e processo do usuário.
              Usuário com PROCESS=EXCEPTION e LGNUM=* vê todas as exceções.
              Usuário com LGNUM específico vê apenas seu warehouse.
*/
@EndUserText.label: 'Access control: ZI_EWM_C360_EXC'
@MappingRole: true
define role ZI_EWM_C360_EXC {
  grant select on ZI_EWM_C360_EXC
    where (Lgnum, ProcessType) = aspect pfcg_auth(Z_EWM_C360A, LGNUM, PROCESS, ACTVT = '03');
}
