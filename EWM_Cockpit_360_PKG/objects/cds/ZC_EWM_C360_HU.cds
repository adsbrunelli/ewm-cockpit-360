/*
  View    : ZC_EWM_C360_HU
  Tipo    : Consumption View (ZC_) — List Report + Object Page
  Fonte   : ZI_EWM_C360_HDR (filtrado por PROCESS_TYPE = 'HU')
  Finalidade: Gestão de Handling Units — rastreamento e status de HUs no armazém.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Gestão de HU'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Handling Unit',
  typeNamePlural: 'Handling Units',
  title:          { type: #STANDARD, value: 'DocId' },
  description:    { type: #STANDARD, value: 'StatusCode' }
}

@Search.searchable: true

define view entity ZC_EWM_C360_HU
  as select from ZI_EWM_C360_HDR
  where ProcessType = 'HU'
{
  @UI.facet: [
    { id: 'HUHeader',  purpose: #HEADER,   type: #DATAPOINT_REFERENCE,    targetQualifier: 'Status',    position: 10 },
    { id: 'HUDetails', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Detalhes HU',       position: 10 },
    { id: 'HUItems',   purpose: #STANDARD, type: #LINEITEM_REFERENCE,        label: 'Conteúdo',
      targetElement: '_Items',                                                                            position: 20 }
  ]

  @UI.selectionField: [{ position: 10 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_LGNUM', element: 'Lgnum' } }]
  key Lgnum,

  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem: [{ position: 10, label: 'HU / Documento' }]
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
  @UI.lineItem: [{ position: 40, label: 'Data Entrada' }]
  OpenDate,

  @UI.lineItem: [{ position: 50, label: 'Aging (dias)', criticality: 'StatusCriticality' }]
  @UI.dataPoint: { qualifier: 'AgingDays', title: 'Aging (dias)', criticality: 'StatusCriticality' }
  AgingDays,

  @UI.lineItem: [{ position: 60, label: 'Com Exceção' }]
  HasException,

  @UI.identification: [{ position: 40 }]
  ResponsibleUser,

  ProcessType,
  DueDate,
  Priority,
  StatusCriticality,
  _Items
}
