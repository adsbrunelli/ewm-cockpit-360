/*
  View    : ZC_EWM_C360_OVERVIEW
  Tipo    : Consumption View (ZC_) — Overview Page / OVP
  Fonte   : ZI_EWM_C360_HDR (agregação por warehouse e processo)
  Finalidade: Visão consolidada por warehouse para o card de Overview.
              Expõe contadores por STATUS e HAS_EXCEPTION para cards analíticos.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Overview por Warehouse'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Warehouse',
  typeNamePlural: 'Warehouses',
  title:          { type: #STANDARD, value: 'Lgnum' },
  description:    { type: #STANDARD, value: 'ProcessType' }
}

@Search.searchable: true

define view entity ZC_EWM_C360_OVERVIEW
  as select from ZI_EWM_C360_HDR
{
  @UI.facet: [{
    id:       'Overview',
    purpose:  #STANDARD,
    type:     #COLLECTION,
    label:    'Visão Geral',
    position: 10
  }]

  @UI.selectionField:   [{ position: 10 }]
  @UI.lineItem:         [{ position: 10, label: 'Warehouse' }]
  @Search.defaultSearchElement: true
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_LGNUM', element: 'Lgnum' } }]
  key Lgnum,

  @UI.selectionField:   [{ position: 20 }]
  @UI.lineItem:         [{ position: 20, label: 'Processo' }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_PROCESS', element: 'ProcessType' } }]
  key ProcessType,

  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem:       [{ position: 30, label: 'Status' }]
  key StatusCode,

  @UI.dataPoint: { title: 'Total de Documentos', criticality: 'StatusCriticality' }
  @UI.lineItem:  [{ position: 40, label: 'Total Docs', type: #AS_DATAPOINT }]
  count( DocId ) as TotalDocs,

  @UI.dataPoint: { title: 'Com Exceção', criticality: { value: 2 } }
  @UI.lineItem:  [{ position: 50, label: 'Com Exceção', type: #AS_DATAPOINT }]
  count( case HasException when 'X' then 1 end ) as DocsWithException,

  @UI.dataPoint: { title: 'Aging Médio (dias)' }
  avg( AgingDays ) as AvgAgingDays,

  StatusCriticality
}
group by Lgnum, ProcessType, StatusCode, StatusCriticality
