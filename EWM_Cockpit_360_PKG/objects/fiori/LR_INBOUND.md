# App: ZEWM_C360_IBD — Monitor Inbound

## Identificação

| Atributo | Valor |
|----------|-------|
| App ID | ZEWM_C360_IBD |
| Padrão Fiori | List Report + Object Page |
| Semantic Object | ZEWM_C360_IBD |
| Semantic Action | display |
| CDS de consumo | ZC_EWM_C360_INBOUND |
| OData Entity Set | ZC_EWM_C360_INBOUND |
| Role mínima | Z_EWM_C360_INBOUND |

---

## List Report

### Barra de filtros (Smart Filter Bar)

| Campo | Label | Tipo | Default |
|-------|-------|------|---------|
| Lgnum | Warehouse | Value Help | Warehouse do usuário |
| StatusCode | Status | Dropdown | — |
| OpenDate | Data Abertura | DateRange | Hoje - 7 dias |
| DueDate | Data Prevista | DateRange | — |
| HasException | Com Exceção | Checkbox | — |

### Colunas da tabela

| Posição | Campo | Label | Criticality | Largura |
|---------|-------|-------|-------------|---------|
| 1 | DocId | Documento | — | 15rem |
| 2 | StatusCode | Status | StatusCriticality | 10rem |
| 3 | SourceRef | Origem | — | 15rem |
| 4 | OpenDate | Abertura | — | 10rem |
| 5 | DueDate | Prazo | — | 10rem |
| 6 | AgingDays | Aging (dias) | StatusCriticality | 8rem |
| 7 | HasException | Exceção | — | 8rem |
| 8 | ResponsibleUser | Responsável | — | 12rem |

### Toolbar — ações globais

| Ação | Tipo | Condição | Role |
|------|------|----------|------|
| Exportar para Excel | Standard Fiori | Sempre | Qualquer |
| Reprocessar Selecionados | Custom Button | Seleção > 0 e ReprocFlag = 'X' | Z_EWM_C360_INBOUND (REPROC) |

### Navegação para Object Page

Clique em qualquer linha → Object Page `ZEWM_C360_IBD_OP` passando `Lgnum + DocId`.

---

## Object Page — Documento Inbound

### Header

| Elemento | Campo |
|----------|-------|
| Título | DocId |
| Subtítulo | StatusCode (com criticality) |
| DataPoint 1 | AgingDays (dias em aberto) |
| DataPoint 2 | DueDate (prazo previsto) |

### Facets

#### Facet 1 — Dados Gerais (Identification)

| Campo | Label |
|-------|-------|
| Lgnum | Warehouse |
| SourceRef | Documento Origem |
| ProcessType | Tipo de Processo |
| OpenDate | Data Abertura |
| DueDate | Data Prevista |
| ResponsibleUser | Responsável |
| Priority | Prioridade |

#### Facet 2 — Itens (Line Item Reference → ZC_EWM_C360_ITEM)

| Coluna | Label | Criticality |
|--------|-------|-------------|
| ItemNo | Item | — |
| MatDoc | Material | — |
| QtyPlanned | Qtd Prevista | — |
| QtyActual | Qtd Real | — |
| QtyVariance | Variação | StatusCriticality |
| Unit | UM | — |
| StorageBin | Bin | — |
| ItemStatus | Status Item | StatusCriticality |

#### Facet 3 — Exceções (Line Item Reference → ZC_EWM_C360_EXCEPTION, filtrado por DocId)

| Coluna | Label | Criticality |
|--------|-------|-------------|
| ExcId | Exceção | — |
| ExcType | Tipo | — |
| Severity | Severidade | SeverityCriticality |
| StatusCode | Status | — |
| SlaDueAt | Venc. SLA | SeverityCriticality |

#### Facet 4 — Log de Ações (Line Item Reference → ZC_EWM_C360_ACTLOG, filtrado por DocId)

| Coluna | Label |
|--------|-------|
| ActionType | Ação |
| ActionResult | Resultado |
| ActionBy | Executado por |
| ActionAt | Data/Hora |

### Ações do Object Page

| Ação | Label | Condição | Role |
|------|-------|----------|------|
| Reprocessar | Reprocessar Documento | ReprocFlag='X' AND RetryCount < MAX_RETRY | Z_EWM_C360_INBOUND |
| Encerrar | Encerrar Manualmente | StatusCode = 'BLOCKED' | Z_EWM_C360_SUPPORT |

---

## Critérios de aceite

- [ ] Filter bar abre com Lgnum pré-preenchido; ao mudar Lgnum a lista recarrega
- [ ] Linha com HasException='X' exibe ícone de alerta na coluna Exceção
- [ ] Coluna Status colorida conforme StatusCriticality (verde/amarelo/vermelho)
- [ ] Clique na linha abre Object Page com todos os 4 facets carregados
- [ ] Facet de Itens exibe QtyVariance negativa em vermelho (criticality = 1)
- [ ] Botão Reprocessar visível somente quando ReprocFlag='X' e role permite
- [ ] Usuário com Z_EWM_C360_INBOUND sem LGNUM específico vê erro de autorização
