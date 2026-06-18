/*
  View    : ZI_EWM_C360_ACTLOG
  Tipo    : Interface View (ZI_)
  Fonte   : ZTEWM_C360_ACTLOG
  Finalidade: Exposição semântica do log de ações. Base para consumo de auditoria.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Action Log (Interface)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #XL,
  dataClass:      #TRANSACTIONAL
}
define view entity ZI_EWM_C360_ACTLOG
  as select from ztewm_c360_actlog as Log
  association [0..1] to ZI_EWM_C360_HDR as _Header
    on  $projection.Lgnum = _Header.Lgnum
    and $projection.DocId = _Header.DocId
{
  key Log.lgnum          as Lgnum,
  key Log.log_id         as LogId,

      Log.action_id      as ActionId,
      Log.process_type   as ProcessType,
      Log.doc_id         as DocId,
      Log.item_no        as ItemNo,
      Log.exec_user      as ExecUser,
      Log.exec_timestamp as ExecTimestamp,
      Log.result         as Result,
      Log.msg_text       as MsgText,
      Log.message_id     as MessageId,
      Log.message_no     as MessageNo,
      Log.ip_address     as IpAddress,
      Log.session_id     as SessionId,

      /* Criticality pelo resultado */
      case Log.result
        when 'ERROR'   then 1
        when 'PARTIAL' then 2
        when 'SUCCESS' then 3
        else 0
      end as ResultCriticality,

      _Header
}
where Log.mandt = $session.client
