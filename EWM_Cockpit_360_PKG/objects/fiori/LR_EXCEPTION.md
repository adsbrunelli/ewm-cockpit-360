# App: ZEWM_C360_EXC — Painel de Exceções

## Identificação

| Atributo | Valor |
|----------|-------|
| App ID | ZEWM_C360_EXC |
| Padrão Fiori | List Report + Object Page |
| Semantic Object | ZEWM_C360_EXC |
| CDS de consumo | ZC_EWM_C360_EXCEPTION |
| Role mínima | Z_EWM_C360_EXEC |

---

## List Report

### Barra de filtros

| Campo | Label | Tipo | Default |
|-------|-------|------|---------|
| Lgnum | Warehouse | Value Help | Warehouse do usuário |
| Severity | Severidade | Value Help (ZI_EWM_C360_VH_SEVERITY) | CRITICAL, HIGH |
| StatusCode | Status | Dropdown | Excluir RESOLVED |
| ProcessType | Processo | Value Help | — |
| SlaDueAt | Venc. SLA | DateRange | — |
| Owner | Owner | Input | — |

### Colunas da tabela

| Posição | Campo | Label | Criticality | Largura |
|---------|-------|-------|-------------|---------|
| 1 | ExcId | Exceção | — | 15rem |
| 2 | ExcType | Tipo | — | 15rem |
| 3 | Severity | Severidade | SeverityCriticality | 10rem |
| 4 | StatusCode | Status | — | 10rem |
| 5 | ProcessType | Processo | — | 10rem |
| 6 | DocId | Documento | — | 15rem |
| 7 | SlaDueAt | Venc. SLA | SeverityCriticality | 12rem |
| 8 | Owner | Owner | — | 12rem |
| 9 | RetryCount | Tentativas | — | 8rem |

### Ordenação padrão

`SeverityCriticality ASC, SlaDueAt ASC` — exceções críticas com SLA mais próximo do vencimento aparecem primeiro.

### Toolbar

| Ação | Tipo | Condição | Role |
|------|------|----------|------|
| Exportar para Excel | Standard Fiori | Sempre | Qualquer |
| Resolver Selecionadas | Custom Button | Seleção > 0 e StatusCode != RESOLVED | Z_EWM_C360_INBOUND ou OUTBOUND (ACTVT=16) |
| Reprocessar Selecionadas | Custom Button | Seleção > 0 e ReprocFlag='X' | Z_EWM_C360_SUPPORT |

---

## Object Page — Exceção

### Header

| Elemento | Campo |
|----------|-------|
| Título | ExcId |
| Subtítulo | ExcType |
| DataPoint 1 | Severity (com SeverityCriticality) |
| DataPoint 2 | SlaDueAt — exibe "VENCIDO" em vermelho se SlaExpired = true |
| DataPoint 3 | StatusCode |

### Facets

#### Facet 1 — Detalhes da Exceção

| Campo | Label |
|-------|-------|
| Lgnum | Warehouse |
| ProcessType | Processo |
| DocId | Documento Origem |
| ItemNo | Item |
| ExcType | Tipo de Exceção |
| Severity | Severidade |
| StatusCode | Status |
| RootCause | Causa Raiz |
| Owner | Owner |
| SlaDueAt | Vencimento SLA |
| RetryCount | Tentativas de Reprocessamento |
| ReprocFlag | Elegível para Reprocessamento |

#### Facet 2 — Histórico de Ações (ZC_EWM_C360_ACTLOG filtrado por ExcId)

| Coluna | Label |
|--------|-------|
| ActionType | Ação |
| ActionResult | Resultado |
| ActionBy | Executado por |
| ActionAt | Data/Hora |
| ErrorMsg | Mensagem de Erro |

### Ações do Object Page

| Ação | Label | Condição | Role |
|------|-------|----------|------|
| Resolver | Resolver Exceção | StatusCode != 'RESOLVED' | ACTVT=16 no Z_EWM_C360A |
| Reprocessar | Reprocessar | ReprocFlag='X' AND RetryCount < MAX_RETRY | Z_EWM_C360_SUPPORT |
| Atribuir Owner | Atribuir Responsável | StatusCode = 'OPEN' | Z_EWM_C360_SUPPORT |

### Comportamento do botão Resolver

```
1. Dialog de confirmação: "Confirma resolução de {ExcId} — {ExcType}?"
2. Campo obrigatório: Motivo da Resolução (texto livre, max 255 chars)
3. POST para action OData 'resolve' → ZCL_EWM_C360_ACTION_DISPATCHER
4. Backend: valida AUTHORITY-CHECK Z_EWM_C360A ACTVT=16
5. Backend: atualiza ZTEWM_C360_EXC STATUS_CODE = 'RESOLVED', RESOLVED_FLAG = 'X'
6. Backend: grava ZTEWM_C360_ACTLOG com ACTION_TYPE = 'RESOLVE'
7. UI: recarrega Object Page e exibe toast "Exceção resolvida com sucesso"
```

---

## Critérios de aceite

- [ ] Filtro default exclui status RESOLVED (exceções já encerradas não aparecem por padrão)
- [ ] Filtro de Severidade default pré-seleciona CRITICAL e HIGH
- [ ] Ordenação por criticality + SLA garante exceções mais urgentes no topo
- [ ] DataPoint SlaDueAt exibe "VENCIDO" em vermelho quando SlaExpired = true
- [ ] Dialog de resolução exige campo Motivo antes de confirmar
- [ ] Após resolver, linha some da lista (pois StatusCode = RESOLVED está filtrado)
- [ ] Log de Ações exibe entrada de RESOLVE com timestamp e usuário corretos
- [ ] Usuário sem ACTVT=16 vê botão Resolver desabilitado (não oculto — UX de transparência)
