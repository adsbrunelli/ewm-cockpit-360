/*
  DCL     : ZI_EWM_C360_ITEM
  Tipo    : Access Control (define role)
  Protege : ZI_EWM_C360_ITEM
  Objeto  : Z_EWM_C360A (LGNUM + ACTVT)
  Estratégia: Item não carrega ProcessType diretamente — acesso filtrado só
              por LGNUM. A granularidade por processo é controlada via HDR.
              PROCESS fixo como '*' na role: acesso concedido se usuário tem
              qualquer processo no warehouse.
*/
@EndUserText.label: 'Access control: ZI_EWM_C360_ITEM'
@MappingRole: true
define role ZI_EWM_C360_ITEM {
  grant select on ZI_EWM_C360_ITEM
    where (Lgnum) = aspect pfcg_auth(Z_EWM_C360A, LGNUM, ACTVT = '03');
}
