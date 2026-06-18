# App: ZEWM_C360_OBD — Monitor Outbound

## Identificação

| Atributo | Valor |
|----------|-------|
| App ID | ZEWM_C360_OBD |
| Padrão Fiori | List Report + Object Page |
| Semantic Object | ZEWM_C360_OBD |
| CDS de consumo | ZC_EWM_C360_OUTBOUND |
| Role mínima | Z_EWM_C360_OUTBOUND |

---

## List Report

### Barra de filtros

| Campo | Label | Tipo | Default |
|-------|-------|------|---------|
| Lgnum | Warehouse | Value Help | Warehouse do usuário |
| StatusCode | Status | Dropdown | OPEN, BLOCKED |
| OpenDate | Data Abertura | DateRange | Hoje - 7 dias |
| DueDate | Data Prevista | DateRange | — |
| HasException | Com Exceção | Checkbox | — |
| Priority | Prioridade | Dropdown | — |

### Colunas da tabela

| Posição | Campo | Label | Criticality | Largura |
|---------|-------|-------|-------------|---------|
| 1 | DocId | Documento | — | 15rem |
| 2 | StatusCode | Status | StatusCriticality | 10rem |
| 3 | SourceRef | Destino | — | 15rem |
| 4 | OpenDate | Abertura | — | 10rem |
| 5 | DueDate | Prazo | — | 10rem |
| 6 | AgingDays | Aging (dias) | StatusCriticality | 8rem |
| 7 | Priority | Prioridade | — | 8rem |
| 8 | HasException | Exceção | — | 8rem |
| 9 | ResponsibleUser | Responsável | — | 12rem |

### Toolbar — ações globais

| Ação | Tipo | Condição | Role |
|------|------|----------|------|
| Exportar para Excel | Standard Fiori | Sempre | Qualquer |
| Reprocessar Selecionados | Custom Button | Seleção > 0 e ReprocFlag='X' | Z_EWM_C360_OUTBOUND |
| Priorizar Selecionados | Custom Button | Seleção > 0 | Z_EWM_C360_SUPPORT |

---

## Object Page — Documento Outbound

### Header

| Elemento | Campo |
|----------|-------|
| Título | DocId |
| Subtítulo | StatusCode (criticality) |
| DataPoint 1 | AgingDays |
| DataPoint 2 | DueDate |
| DataPoint 3 | Priority |

### Facets

#### Facet 1 — Dados Gerais

| Campo | Label |
|-------|-------|
| Lgnum | Warehouse |
| SourceRef | Destino |
| ProcessType | Tipo de Processo |
| OpenDate | Data Abertura |
| DueDate | Prazo |
| Priority | Prioridade |
| ResponsibleUser | Responsável |

#### Facet 2 — Itens (ZC_EWM_C360_ITEM)

| Coluna | Label | Criticality |
|--------|-------|-------------|
| ItemNo | Item | — |
| MatDoc | Material | — |
| QtyPlanned | Qtd Prevista | — |
| QtyActual | Qtd Real | — |
| QtyVariance | Variação | StatusCriticality |
| Unit | UM | — |
| StorageBin | Bin Origem | — |
| ItemStatus | Status | StatusCriticality |

#### Facet 3 — Exceções (ZC_EWM_C360_EXCEPTION filtrado por DocId)

| Coluna | Label | Criticality |
|--------|-------|-------------|
| ExcType | Tipo Exceção | — |
| Severity | Severidade | SeverityCriticality |
| StatusCode | Status | — |
| SlaDueAt | Venc. SLA | SeverityCriticality |
| Owner | Owner | — |

#### Facet 4 — Log de Ações (ZC_EWM_C360_ACTLOG filtrado por DocId)

| Coluna | Label |
|--------|-------|
| ActionType | Ação |
| ActionResult | Resultado |
| ActionBy | Executado por |
| ActionAt | Data/Hora |

### Ações do Object Page

| Ação | Label | Condição | Role |
|------|-------|----------|------|
| Reprocessar | Reprocessar | ReprocFlag='X' AND RetryCount < MAX_RETRY | Z_EWM_C360_OUTBOUND |
| Encerrar | Encerrar Manualmente | StatusCode = 'BLOCKED' | Z_EWM_C360_SUPPORT |
| Priorizar | Alterar Prioridade | StatusCode = 'OPEN' | Z_EWM_C360_SUPPORT |

---

## Critérios de aceite

- [ ] Filtro de Status com default OPEN e BLOCKED pré-selecionados
- [ ] Coluna Priority visível e com ordenação habilitada
- [ ] Object Page carrega os 4 facets sem chamadas adicionais (lazy loading de associações)
- [ ] Ação Reprocessar dispara handler `ZCL_EWM_C360_ACTION_DISPATCHER` e retorna resultado
- [ ] Log de Ações exibe histórico cronológico decrescente (mais recente no topo)
- [ ] Usuário sem role Z_EWM_C360_OUTBOUND não acessa o app (tile oculto no Launchpad)
