/*
  View    : ZC_EWM_C360_KPI
  Tipo    : Consumption View (ZC_) — List Report + Object Page
  Fonte   : ZI_EWM_C360_KPI
  Finalidade: Painel de KPIs com status, desvio e histórico por granularidade.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Painel de KPIs'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'KPI',
  typeNamePlural: 'KPIs',
  title:          { type: #STANDARD, value: 'KpiName' },
  description:    { type: #STANDARD, value: 'ProcessType' }
}

@Search.searchable: true

define view entity ZC_EWM_C360_KPI
  as select from ZI_EWM_C360_KPI
{
  @UI.selectionField: [{ position: 10 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_LGNUM', element: 'Lgnum' } }]
  key Lgnum,

  @UI.selectionField: [{ position: 20 }]
  key KpiId,

  @UI.selectionField: [{ position: 30 }]
  key PeriodDate,

  @UI.selectionField: [{ position: 40 }]
  key Granularity,

  @UI.selectionField: [{ position: 50 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_PROCESS', element: 'ProcessType' } }]
  key ProcessType,

  @UI.lineItem: [{ position: 10, label: 'KPI' }]
  @UI.identification: [{ position: 10 }]
  @Search.defaultSearchElement: true
  KpiName,

  @UI.lineItem: [{ position: 20, label: 'Valor Real', type: #AS_DATAPOINT }]
  @UI.dataPoint: { qualifier: 'ActualValue', title: 'Valor Real', criticality: 'StatusCriticality' }
  @Semantics.quantity.unitOfMeasure: 'Unit'
  ActualValue,

  @UI.lineItem: [{ position: 30, label: 'Meta' }]
  @Semantics.quantity.unitOfMeasure: 'Unit'
  TargetValue,

  @UI.lineItem: [{ position: 40, label: 'Desvio %', criticality: 'StatusCriticality' }]
  @UI.dataPoint: { qualifier: 'Deviation', title: 'Desvio %', criticality: 'StatusCriticality' }
  DeviationPct,

  @UI.lineItem: [{ position: 50, label: 'Status', criticality: 'StatusCriticality' }]
  StatusCode,

  @UI.lineItem: [{ position: 60, label: 'Atualizado em' }]
  CalcTimestamp,

  Unit,
  Owner,
  Formula,
  TolerancePct,
  StatusCriticality
}
