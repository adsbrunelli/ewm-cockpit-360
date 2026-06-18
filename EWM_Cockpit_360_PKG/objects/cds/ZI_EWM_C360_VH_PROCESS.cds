/*
  View    : ZI_EWM_C360_VH_PROCESS
  Tipo    : Value Help
  Fonte   : Domínio fixo ZDEWM_C360_PROCESS (valores parametrizados)
  Finalidade: Value help para campo PROCESS_TYPE em filtros do cockpit.
              Usa view de domínio fixo via I_DomainValue.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'C360 - VH Tipo de Processo'
@Search.searchable: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #XS,
  dataClass:      #CUSTOMIZING
}
define view entity ZI_EWM_C360_VH_PROCESS
  as select from I_DomainValue( P_DomainName: 'ZDEWM_C360_PROCESS',
                                P_Language:   $session.system_language )
{
  @ObjectModel.text.element: ['ProcessText']
  @Search.defaultSearchElement: true
  key DomainValue as ProcessType,

  @Semantics.text: true
      DomainValueName as ProcessText
}
