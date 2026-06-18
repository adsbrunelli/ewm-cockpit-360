# App: ZEWM_C360_HU — Gestão de Handling Units

## Identificação

| Atributo | Valor |
|----------|-------|
| App ID | ZEWM_C360_HU |
| Padrão Fiori | List Report + Object Page |
| Semantic Object | ZEWM_C360_HU |
| CDS de consumo | ZC_EWM_C360_HU |
| Role mínima | Z_EWM_C360_OUTBOUND |

---

## List Report

### Barra de filtros

| Campo | Label | Tipo | Default |
|-------|-------|------|---------|
| Lgnum | Warehouse | Value Help | Warehouse do usuário |
| DocId | HU / Documento | Input | — |
| StatusCode | Status | Dropdown | — |
| OpenDate | Data Entrada | DateRange | Hoje - 30 dias |
| HasException | Com Exceção | Checkbox | — |

### Colunas da tabela

| Posição | Campo | Label | Criticality | Largura |
|---------|-------|-------|-------------|---------|
| 1 | DocId | HU / Documento | — | 18rem |
| 2 | StatusCode | Status | StatusCriticality | 10rem |
| 3 | SourceRef | Referência | — | 15rem |
| 4 | OpenDate | Data Entrada | — | 10rem |
| 5 | DueDate | Prazo | — | 10rem |
| 6 | AgingDays | Aging (dias) | StatusCriticality | 8rem |
| 7 | HasException | Exceção | — | 8rem |
| 8 | ResponsibleUser | Responsável | — | 12rem |

### Toolbar

| Ação | Tipo | Condição | Role |
|------|------|----------|------|
| Exportar para Excel | Standard Fiori | Sempre | Qualquer |

---

## Object Page — Handling Unit

### Header

| Elemento | Campo |
|----------|-------|
| Título | DocId (HU ID) |
| Subtítulo | StatusCode (criticality) |
| DataPoint 1 | AgingDays |
| DataPoint 2 | DueDate |

### Facets

#### Facet 1 — Dados da HU

| Campo | Label |
|-------|-------|
| Lgnum | Warehouse |
| SourceRef | Documento Origem |
| ProcessType | Processo |
| OpenDate | Data Entrada |
| DueDate | Prazo |
| ResponsibleUser | Responsável |

#### Facet 2 — Conteúdo da HU (ZC_EWM_C360_ITEM)

| Coluna | Label | Criticality |
|--------|-------|-------------|
| ItemNo | Item | — |
| MatDoc | Material | — |
| QtyPlanned | Qtd Prevista | — |
| QtyActual | Qtd Real | — |
| QtyVariance | Variação | StatusCriticality |
| Unit | UM | — |
| StorageBin | Bin | — |
| ItemStatus | Status | StatusCriticality |

#### Facet 3 — Exceções (ZC_EWM_C360_EXCEPTION filtrado por DocId)

| Coluna | Label | Criticality |
|--------|-------|-------------|
| ExcType | Tipo | — |
| Severity | Severidade | SeverityCriticality |
| StatusCode | Status | — |
| SlaDueAt | Venc. SLA | SeverityCriticality |

---

## Critérios de aceite

- [ ] Busca por DocId (HU ID) funciona com busca parcial (LIKE)
- [ ] AgingDays calculado a partir de OpenDate até hoje (campo calculado no ZI_)
- [ ] Conteúdo da HU exibe todos os itens com variação de quantidade destacada
- [ ] Exceções vinculadas ao DocId aparecem no facet com criticality
- [ ] Usuário sem LGNUM no objeto de autorização recebe 403 ao tentar visualizar HU de outro warehouse
