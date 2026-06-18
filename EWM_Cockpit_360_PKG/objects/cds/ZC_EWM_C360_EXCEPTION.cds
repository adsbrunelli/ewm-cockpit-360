/*
  View    : ZC_EWM_C360_EXCEPTION
  Tipo    : Consumption View (ZC_) — List Report + Object Page
  Fonte   : ZI_EWM_C360_EXC
  Finalidade: Painel de exceções com filtros, criticality, SLA e ações.
              Usada pelo app Fiori de gestão de exceções.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Painel de Exceções'
@Metadata.allowExtensions: true

@UI.headerInfo: {
  typeName:       'Exceção',
  typeNamePlural: 'Exceções',
  title:          { type: #STANDARD, value: 'ExcId' },
  description:    { type: #STANDARD, value: 'ExcType' }
}

@Search.searchable: true

define view entity ZC_EWM_C360_EXCEPTION
  as select from ZI_EWM_C360_EXC
{
  @UI.facet: [
    { id: 'ExcHeader', purpose: #HEADER,   type: #DATAPOINT_REFERENCE, targetQualifier: 'Severity',   position: 10 },
    { id: 'ExcHeader', purpose: #HEADER,   type: #DATAPOINT_REFERENCE, targetQualifier: 'SlaExpired', position: 20 },
    { id: 'Details',   purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Detalhes',        position: 10 },
    { id: 'Context',   purpose: #STANDARD, type: #FIELD_GROUP_REFERENCE,    targetQualifier: 'Context', label: 'Contexto', position: 20 }
  ]

  /* Filtros de seleção */
  @UI.selectionField: [{ position: 10 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_LGNUM', element: 'Lgnum' } }]
  key Lgnum,

  @UI.selectionField: [{ position: 20 }]
  key ExcId,

  @UI.selectionField: [{ position: 30 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_SEVERITY', element: 'Severity' } }]
  Severity,

  @UI.selectionField: [{ position: 40 }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_EWM_C360_VH_PROCESS', element: 'ProcessType' } }]
  ProcessType,

  @UI.selectionField: [{ position: 50 }]
  StatusCode,

  /* Colunas da lista */
  @UI.lineItem: [{ position: 10, criticality: 'SeverityCriticality', label: 'Exceção' }]
  @UI.identification: [{ position: 10 }]
  ExcType,

  @UI.lineItem: [{ position: 20, criticality: 'SeverityCriticality', label: 'Severidade' }]
  @UI.dataPoint: { qualifier: 'Severity', title: 'Severidade', criticality: 'SeverityCriticality' }
  @UI.identification: [{ position: 20 }]
  SeverityCriticality,

  @UI.lineItem: [{ position: 30, label: 'Status' }]
  @UI.identification: [{ position: 30 }]
  StatusCode,

  @UI.lineItem: [{ position: 40, label: 'Vencimento SLA', criticality: 'SeverityCriticality' }]
  @UI.dataPoint: { qualifier: 'SlaExpired', title: 'SLA Expirado', criticality: 'SeverityCriticality' }
  SlaDueAt,

  @UI.lineItem: [{ position: 50, label: 'Owner' }]
  Owner,

  /* Grupo de campos — Contexto */
  @UI.fieldGroup: [{ qualifier: 'Context', position: 10, label: 'Documento Origem' }]
  DocId,

  @UI.fieldGroup: [{ qualifier: 'Context', position: 20, label: 'Item' }]
  ItemNo,

  @UI.fieldGroup: [{ qualifier: 'Context', position: 30, label: 'Causa Raiz' }]
  RootCause,

  @UI.fieldGroup: [{ qualifier: 'Context', position: 40, label: 'Tentativas Reproc.' }]
  RetryCount,

  /* Campos de referência e cálculo */
  SeverityCriticality,
  SlaExpired,
  ReprocFlag,
  ResolvedFlag,
  CreatedAt,
  ChangedAt,

  /* Ações Fiori (definidas no metadata extension) */
  @UI.identification: [{ position: 90, label: 'Resolver', type: #FOR_ACTION, dataAction: 'resolve', invocationGrouping: #SINGLE_INSTANCE }]
  ExcId as ExcIdAction : redirected to ZC_EWM_C360_EXCEPTION
}
