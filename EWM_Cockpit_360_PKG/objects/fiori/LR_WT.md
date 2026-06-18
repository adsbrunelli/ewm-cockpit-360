# App: ZEWM_C360_WT — Tarefas de Armazém (Warehouse Tasks)

## Identificação

| Atributo | Valor |
|----------|-------|
| App ID | ZEWM_C360_WT |
| Padrão Fiori | List Report + Object Page |
| Semantic Object | ZEWM_C360_WT |
| CDS de consumo | ZC_EWM_C360_WT |
| Role mínima | Z_EWM_C360_EXEC |

---

## List Report

### Barra de filtros

| Campo | Label | Tipo | Default |
|-------|-------|------|---------|
| Lgnum | Warehouse | Value Help | Warehouse do usuário |
| StatusCode | Status | Dropdown | OPEN, OVERDUE |
| OpenDate | Data Criação | DateRange | Hoje - 3 dias |
| DueDate | Prazo | DateRange | — |
| HasException | Com Exceção | Checkbox | — |
| ResponsibleUser | Responsável | Input | — |
| Priority | Prioridade | Dropdown | — |

### Colunas da tabela

| Posição | Campo | Label | Criticality | Largura |
|---------|-------|-------|-------------|---------|
| 1 | DocId | Tarefa (WT) | — | 15rem |
| 2 | StatusCode | Status | StatusCriticality | 10rem |
| 3 | SourceRef | Referência | — | 15rem |
| 4 | OpenDate | Criação | — | 10rem |
| 5 | DueDate | Prazo | — | 10rem |
| 6 | AgingDays | Aging (dias) | StatusCriticality | 8rem |
| 7 | Priority | Prioridade | — | 8rem |
| 8 | HasException | Exceção | — | 8rem |
| 9 | ResponsibleUser | Responsável | — | 12rem |

### Toolbar

| Ação | Tipo | Condição | Role |
|------|------|----------|------|
| Exportar para Excel | Standard Fiori | Sempre | Qualquer |
| Reprocessar Selecionados | Custom Button | Seleção > 0 e ReprocFlag='X' | Z_EWM_C360_SUPPORT |

---

## Object Page — Warehouse Task

### Header

| Elemento | Campo |
|----------|-------|
| Título | DocId |
| Subtítulo | StatusCode (criticality) |
| DataPoint 1 | AgingDays — com alerta vermelho se > limite do KPI de aging |
| DataPoint 2 | DueDate |
| DataPoint 3 | Priority |

### Facets

#### Facet 1 — Dados da Tarefa

| Campo | Label |
|-------|-------|
| Lgnum | Warehouse |
| SourceRef | Documento Origem |
| ProcessType | Processo |
| OpenDate | Data Criação |
| DueDate | Prazo |
| Priority | Prioridade |
| ResponsibleUser | Responsável |

#### Facet 2 — Itens da Tarefa (ZC_EWM_C360_ITEM)

| Coluna | Label | Criticality |
|--------|-------|-------------|
| ItemNo | Item | — |
| MatDoc | Material | — |
| QtyPlanned | Qtd Planejada | — |
| QtyActual | Qtd Confirmada | — |
| QtyVariance | Variação | StatusCriticality |
| StorageBin | Bin Destino | — |
| ItemStatus | Status | StatusCriticality |

#### Facet 3 — Exceções (ZC_EWM_C360_EXCEPTION filtrado por DocId)

| Coluna | Label | Criticality |
|--------|-------|-------------|
| ExcType | Tipo | — |
| Severity | Severidade | SeverityCriticality |
| StatusCode | Status | — |
| SlaDueAt | Venc. SLA | SeverityCriticality |

### Ações do Object Page

| Ação | Label | Condição | Role |
|------|-------|----------|------|
| Reprocessar | Reprocessar WT | ReprocFlag='X' AND RetryCount < MAX_RETRY | Z_EWM_C360_SUPPORT |

---

## Critérios de aceite

- [ ] Default do filtro StatusCode pré-seleciona OPEN e OVERDUE
- [ ] AgingDays > limite de aging (configurável em ZTEWM_C360_CUST, chave `WT_AGING_WARN_DAYS`) exibe criticality = 1 (vermelho)
- [ ] Ordenação padrão: DueDate ASC (tarefas mais urgentes no topo)
- [ ] Object Page carrega itens e exceções via lazy load (não eager)
- [ ] Botão Reprocessar oculto quando RetryCount >= MAX_RETRY (lido de ZTEWM_C360_CUST)
