/*
  View    : ZC_EWM_C360_OUTBOUND
  Tipo    : Consumption View (ZC_) — List Report + Object Page
  Fonte   : ZI_EWM_C360_HDR (filtrado por PROCESS_TYPE = 'OUTBOUND')
  Finalidade: Monitoração de documentos de saída (Outbound Deliveries).
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Monitor Outbound'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Outbound',
  typeNamePlural: 'Outbound',
  title:          { type: #STANDARD, value: 'DocId' },
  description:    { type: #STANDARD, value: 'StatusCode' }
}

@Search.searchable: true

define view entity ZC_EWM_C360_OUTBOUND
  as select from ZI_EWM_C360_HDR
  where ProcessType = 'OUTBOUND'
{
  @UI.facet: [
    { id: 'DocHeader', purpose: #HEADER,   type: #DATAPOINT_REFERENCE, targetQualifier: 'Status',    position: 10 },
    { id: 'DocHeader', purpose: #HEADER,   type: #DATAPOINT_REFERENCE, targetQualifier: 'AgingDays', position: 20 },
    { id: 'Details',   purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Cabeçalho',     position: 10 },
    { id: 'Items',     purpose: #STANDARD, type: #LINEITEM_REFERENCE,        label: 'Itens',
      targetElement: '_Items',                                                                        position: 20 }
  ]

  @UI.selectionField: [{ position: 10 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_LGNUM', element: 'Lgnum' } }]
  key Lgnum,

  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem: [{ position: 10, label: 'Documento' }]
  @UI.identification: [{ position: 10 }]
  @Search.defaultSearchElement: true
  key DocId,

  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem: [{ position: 20, label: 'Status', criticality: 'StatusCriticality' }]
  @UI.dataPoint: { qualifier: 'Status', title: 'Status', criticality: 'StatusCriticality' }
  @UI.identification: [{ position: 20 }]
  StatusCode,

  @UI.lineItem: [{ position: 30, label: 'Destino' }]
  @UI.identification: [{ position: 30 }]
  SourceRef,

  @UI.selectionField: [{ position: 40 }]
  @UI.lineItem: [{ position: 40, label: 'Data Abertura' }]
  OpenDate,

  @UI.selectionField: [{ position: 50 }]
  @UI.lineItem: [{ position: 50, label: 'Data Prevista' }]
  DueDate,

  @UI.lineItem: [{ position: 60, label: 'Aging (dias)', criticality: 'StatusCriticality' }]
  @UI.dataPoint: { qualifier: 'AgingDays', title: 'Aging (dias)', criticality: 'StatusCriticality' }
  AgingDays,

  @UI.lineItem: [{ position: 70, label: 'Com Exceção' }]
  HasException,

  @UI.identification: [{ position: 40 }]
  ResponsibleUser,

  @UI.identification: [{ position: 50 }]
  Priority,

  ProcessType,
  StatusCriticality,
  _Items
}
