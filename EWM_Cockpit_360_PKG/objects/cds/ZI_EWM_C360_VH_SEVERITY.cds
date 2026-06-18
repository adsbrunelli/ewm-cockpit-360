/*
  View    : ZI_EWM_C360_VH_SEVERITY
  Tipo    : Value Help
  Fonte   : Domínio fixo ZDEWM_C360_SEVERITY
  Finalidade: Value help para campo SEVERITY em filtros de exceções.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'C360 - VH Severidade'
@Search.searchable: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #XS,
  dataClass:      #CUSTOMIZING
}
define view entity ZI_EWM_C360_VH_SEVERITY
  as select from I_DomainValue( P_DomainName: 'ZDEWM_C360_SEVERITY',
                                P_Language:   $session.system_language )
{
  @ObjectModel.text.element: ['SeverityText']
  @Search.defaultSearchElement: true
  key DomainValue as Severity,

  @Semantics.text: true
      DomainValueName as SeverityText,

  /* Criticality para colorir o VH */
  case DomainValue
    when 'CRITICAL' then 1
    when 'HIGH'     then 2
    when 'MEDIUM'   then 3
    when 'LOW'      then 0
    else 0
  end as SeverityCriticality
}
