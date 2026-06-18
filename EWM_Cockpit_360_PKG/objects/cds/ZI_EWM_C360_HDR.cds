/*
  View    : ZI_EWM_C360_HDR
  Tipo    : Interface View (ZI_)
  Fonte   : ZTEWM_C360_HDR
  Finalidade: Exposição semântica do cabeçalho operacional.
              Base para ZC_EWM_C360_INBOUND, ZC_EWM_C360_OUTBOUND e ZC_EWM_C360_OVERVIEW.
  Sem anotações UI — consumo feito pelas ZC_ correspondentes.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Cabeçalho Operacional (Interface)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #XL,
  dataClass:      #TRANSACTIONAL
}
define view entity ZI_EWM_C360_HDR
  as select from ztewm_c360_hdr as Hdr
{
  key Hdr.lgnum          as Lgnum,
  key Hdr.doc_id         as DocId,

      Hdr.process_type   as ProcessType,
      Hdr.doc_type       as DocType,
      Hdr.status_code    as StatusCode,
      Hdr.priority       as Priority,
      Hdr.owner          as Owner,
      Hdr.reference_doc  as ReferenceDoc,
      Hdr.open_date      as OpenDate,
      Hdr.open_time      as OpenTime,
      Hdr.due_date       as DueDate,
      Hdr.closed_date    as ClosedDate,
      Hdr.has_exception  as HasException,
      Hdr.snapshot_ts    as SnapshotTs,
      Hdr.created_by     as CreatedBy,
      Hdr.created_at     as CreatedAt,
      Hdr.changed_by     as ChangedBy,
      Hdr.changed_at     as ChangedAt,

      /* Campos calculados */
      case Hdr.status_code
        when 'OPEN'  then 3   -- Crítico
        when 'PROC'  then 2   -- Warning
        when 'DONE'  then 1   -- OK
        else 0
      end                as StatusCriticality,

      dats_days_between( Hdr.open_date, $session.system_date ) as AgingDays

}
where Hdr.mandt = $session.client
