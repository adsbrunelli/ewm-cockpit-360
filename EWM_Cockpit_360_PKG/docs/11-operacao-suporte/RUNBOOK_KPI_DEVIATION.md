# Runbook — KPI com Desvio Inesperado ou Dado Errado

## Identificação do problema

**Sintoma A** — KPI exibe valor zerado ou vazio:
- `ACTUAL_VALUE = 0` mas há movimentos no armazém
- Dashboard KPI sem dados para o período atual

**Sintoma B** — KPI com valor muito diferente do esperado:
- Desvio > 50% sem ocorrência operacional relevante
- STATUS_CODE mudou de GREEN para RED de um período para outro sem motivo

**Sintoma C** — KPI não atualiza (CalcTimestamp antigo):
- `CALC_TIMESTAMP` do KPI tem mais de 1 hora (para granularidade DAY)

---

## Diagnóstico

### Passo 1 — Verificar dados na tabela de KPI (SE16)

```
SE16 → ZTEWM_C360_KPI
Filtro: LGNUM = <warehouse>, KPI_ID = <id>, PERIOD_DATE = hoje
Verificar: ACTUAL_VALUE, TARGET_VALUE, DEVIATION_PCT, STATUS_CODE, CALC_TIMESTAMP
```

### Passo 2 — Verificar definição do KPI (SE16)

```
SE16 → ZTEWM_C360_KPI_DEF
Filtro: KPI_ID = <id>
Verificar:
  ACTIVE_FLAG   — deve ser 'X'
  FORMULA       — conferir fórmula de cálculo
  DATA_SOURCE   — conferir origem dos dados
  CALC_CLASS    — classe ABAP responsável pelo cálculo
  TOLERANCE_PCT — conferir se tolerância está correta
```

### Passo 3 — Verificar log do último cálculo (SE16)

```
SE16 → ZTEWM_C360_ACTLOG
Filtro: DOC_ID = <kpi_id>, ACTION_TYPE = 'KPI_CALC'
Verificar: ACTION_RESULT, ERROR_MSG, ACTION_AT
```

### Passo 4 — Testar cálculo manual (SE24)

```
SE24 → <CALC_CLASS definido em ZTEWM_C360_KPI_DEF>
  Método: CALCULATE
  → Executar com parâmetros de teste
  → Verificar retorno de ACTUAL_VALUE
```

---

## Resolução

### Caso A — KPI zerado (fonte de dados vazia)

1. Verificar se `DATA_SOURCE` aponta para a tabela/CDS correta
2. Verificar se há dados na fonte para o período:
   ```
   SE16 → <tabela da DATA_SOURCE>
   Filtro: LGNUM = <warehouse>, data = hoje
   ```
3. Se a fonte está vazia: problema operacional (ausência de movimentos) — informar supervisor
4. Se a fonte tem dados mas o KPI está zerado: bug no `CALC_CLASS` — escalar para desenvolvedor

### Caso B — Valor muito diferente do esperado

1. Verificar se `FORMULA` foi alterada recentemente (comparar com git history do `ZTEWM_C360_KPI_DEF`)
2. Verificar se `TARGET_VALUE` foi atualizado (mudança de meta)
3. Verificar se `TOLERANCE_PCT` foi reduzido (mudança de sensibilidade)
4. Se nenhuma configuração mudou: verificar dados brutos na `DATA_SOURCE`

### Caso C — KPI não atualiza

1. Verificar se job `ZEWM_C360_SNAPSHOT_DELTA` está executando (SM37)
2. Verificar se snapshot completa sem erro (RUNBOOK_SNAPSHOT.md)
3. Verificar `ZTEWM_C360_KPI_DEF`: `ACTIVE_FLAG='X'` — KPI inativo não é recalculado
4. Forçar recálculo manual via Fiori: Object Page do KPI → botão "Recalcular"
   (requer role `Z_EWM_C360_SUPPORT`)

### Forçar recálculo via ABAP (uso emergencial)

```abap
DATA(lo_engine) = NEW zcl_ewm_c360_kpi_engine(
  io_auth = NEW zcl_ewm_c360_auth( )
  io_log  = NEW zcl_ewm_c360_log( )
).

lo_engine->calculate( VALUE zif_ewm_c360_kpi_engine=>ty_kpi_input(
  lgnum        = 'WH01'
  kpi_id       = 'INBOUND_ACCURACY'
  period_date  = sy-datum
  granularity  = 'DAY'
) ).
```

Executar via SE38 com programa de manutenção técnica (não exposto ao usuário final).

---

## Prevenção

- `ACTIVE_FLAG` deve ser revisado mensalmente em `ZTEWM_C360_KPI_DEF`
- Mudanças em `FORMULA` ou `TARGET_VALUE` devem ser documentadas como ADR ou nota de release
- Alertas automáticos: configurar tile dinâmico para notificar quando KPIs RED > threshold

---

## Escalada

| Situação | Escalada para |
|----------|--------------|
| CALC_CLASS com bug | Desenvolvedor ABAP |
| DATA_SOURCE incorreta (tabela EWM standard) | Consultor funcional SAP EWM |
| Job não executa | Basis (SM37, SM50) |
