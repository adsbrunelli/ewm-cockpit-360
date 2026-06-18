/*
  View    : ZI_EWM_C360_ITEM
  Tipo    : Interface View (ZI_)
  Fonte   : ZTEWM_C360_ITEM
  Finalidade: Exposição semântica dos itens operacionais.
              Associação ao cabeçalho via ZI_EWM_C360_HDR.
*/
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'C360 - Itens Operacionais (Interface)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #A,
  sizeCategory:   #XL,
  dataClass:      #TRANSACTIONAL
}
define view entity ZI_EWM_C360_ITEM
  as select from ztewm_c360_item as Item
  association [1..1] to ZI_EWM_C360_HDR as _Header
    on  $projection.Lgnum = _Header.Lgnum
    and $projection.DocId = _Header.DocId
{
  key Item.lgnum        as Lgnum,
  key Item.doc_id       as DocId,
  key Item.item_no      as ItemNo,

      Item.item_type    as ItemType,
      Item.matnr        as Matnr,
      Item.charg        as Charg,
      Item.lgpla        as Lgpla,
      Item.lgtyp        as Lgtyp,
      Item.qty_planned  as QtyPlanned,
      Item.qty_actual   as QtyActual,
      Item.uom          as Uom,
      Item.status_code  as StatusCode,
      Item.has_exception as HasException,
      Item.exc_id       as ExcId,
      Item.created_by   as CreatedBy,
      Item.created_at   as CreatedAt,

      /* Diferença de quantidade */
      ( Item.qty_actual - Item.qty_planned ) as QtyVariance,

      /* Exposição da associação */
      _Header
}
where Item.mandt = $session.client
