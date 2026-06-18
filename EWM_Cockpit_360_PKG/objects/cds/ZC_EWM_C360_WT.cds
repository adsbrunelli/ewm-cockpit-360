/*
  View    : ZC_EWM_C360_WT
  Tipo    : Consumption View (ZC_) — List Report + Object Page
  Fonte   : ZI_EWM_C360_HDR (filtrado por PROCESS_TYPE = 'WT')
  Finalidade: Monitoração de Warehouse Tasks — tarefas abertas, aging e exceções.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Tarefas de Armazém (WT)'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Tarefa de Armazém',
  typeNamePlural: 'Tarefas de Armazém',
  title:          { type: #STANDARD, value: 'DocId' },
  description:    { type: #STANDARD, value: 'StatusCode' }
}

@Search.searchable: true

define view entity ZC_EWM_C360_WT
  as select from ZI_EWM_C360_HDR
  where ProcessType = 'WT'
{
  @UI.facet: [
    { id: 'WTHeader',  purpose: #HEADER,   type: #DATAPOINT_REFERENCE,    targetQualifier: 'Status',    position: 10 },
    { id: 'WTHeader',  purpose: #HEADER,   type: #DATAPOINT_REFERENCE,    targetQualifier: 'AgingDays', position: 20 },
    { id: 'WTDetails', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Detalhes',          position: 10 },
    { id: 'WTItems',   purpose: #STANDARD, type: #LINEITEM_REFERENCE,        label: 'Itens',
      targetElement: '_Items',                                                                            position: 20 }
  ]

  @UI.selectionField: [{ position: 10 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_LGNUM', element: 'Lgnum' } }]
  key Lgnum,

  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem: [{ position: 10, label: 'Tarefa (WT)' }]
  @UI.identification: [{ position: 10 }]
  @Search.defaultSearchElement: true
  key DocId,

  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem: [{ position: 20, label: 'Status', criticality: 'StatusCriticality' }]
  @UI.dataPoint: { qualifier: 'Status', title: 'Status', criticality: 'StatusCriticality' }
  @UI.identification: [{ position: 20 }]
  StatusCode,

  @UI.lineItem: [{ position: 30, label: 'Referência' }]
  @UI.identification: [{ position: 30 }]
  SourceRef,

  @UI.selectionField: [{ position: 40 }]
  @UI.lineItem: [{ position: 40, label: 'Data Criação' }]
  OpenDate,

  @UI.selectionField: [{ position: 50 }]
  @UI.lineItem: [{ position: 50, label: 'Prazo' }]
  DueDate,

  @UI.lineItem: [{ position: 60, label: 'Aging (dias)', criticality: 'StatusCriticality' }]
  @UI.dataPoint: { qualifier: 'AgingDays', title: 'Aging (dias)', criticality: 'StatusCriticality' }
  AgingDays,

  @UI.lineItem: [{ position: 70, label: 'Com Exceção' }]
  HasException,

  @UI.lineItem: [{ position: 80, label: 'Responsável' }]
  @UI.identification: [{ position: 30 }]
  ResponsibleUser,

  @UI.lineItem: [{ position: 90, label: 'Prioridade' }]
  Priority,

  ProcessType,
  StatusCriticality,
  _Items
}
