/*
  View    : ZI_EWM_C360_EXC
  Tipo    : Interface View (ZI_)
  Fonte   : ZTEWM_C360_EXC
  Finalidade: Exposição semântica das exceções operacionais e técnicas.
              Base para ZC_EWM_C360_EXCEPTION.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Exceções Operacionais (Interface)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #L,
  dataClass:      #TRANSACTIONAL
}
define view entity ZI_EWM_C360_EXC
  as select from ztewm_c360_exc as Exc
  association [0..1] to ZI_EWM_C360_HDR as _Header
    on  $projection.Lgnum = _Header.Lgnum
    and $projection.DocId = _Header.DocId
{
  key Exc.lgnum         as Lgnum,
  key Exc.exc_id        as ExcId,

      Exc.doc_id        as DocId,
      Exc.item_no       as ItemNo,
      Exc.process_type  as ProcessType,
      Exc.exc_type      as ExcType,
      Exc.severity      as Severity,
      Exc.status_code   as StatusCode,
      Exc.root_cause    as RootCause,
      Exc.message_id    as MessageId,
      Exc.message_no    as MessageNo,
      Exc.sla_due_at    as SlaDueAt,
      Exc.sla_hours     as SlaHours,
      Exc.owner         as Owner,
      Exc.resolved_flag as ResolvedFlag,
      Exc.resolved_at   as ResolvedAt,
      Exc.resolved_by   as ResolvedBy,
      Exc.reproc_flag   as ReprocFlag,
      Exc.retry_count   as RetryCount,
      Exc.created_at    as CreatedAt,
      Exc.changed_at    as ChangedAt,

      /* Criticality baseada em severidade */
      case Exc.severity
        when 'CRITICAL' then 1
        when 'HIGH'     then 2
        when 'MEDIUM'   then 3
        when 'LOW'      then 0
        else 0
      end as SeverityCriticality,

      /* SLA expirado */
      case when Exc.sla_due_at < $session.system_date and Exc.resolved_flag = ''
        then abap_true
        else abap_false
      end as SlaExpired,

      _Header
}
where Exc.mandt = $session.client
