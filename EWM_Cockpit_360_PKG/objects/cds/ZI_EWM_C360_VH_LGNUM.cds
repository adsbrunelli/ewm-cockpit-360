/*
  View    : ZI_EWM_C360_VH_LGNUM
  Tipo    : Value Help
  Fonte   : /SCWM/T331 (tabela de warehouses EWM standard)
  Finalidade: Value help para campo LGNUM em filtros do cockpit.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'C360 - VH Número do Warehouse'
@Search.searchable: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #S,
  dataClass:      #CUSTOMIZING
}
define view entity ZI_EWM_C360_VH_LGNUM
  as select from /scwm/t331 as Wh
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @ObjectModel.text.element: ['LgnumText']
  key Wh.lgnum  as Lgnum,

  @Semantics.text: true
      Wh.lgnum_descr as LgnumText
}
where Wh.mandt = $session.client
