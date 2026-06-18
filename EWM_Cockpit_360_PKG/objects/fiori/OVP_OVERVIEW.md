# App: ZEWM_C360_OVP — EWM Cockpit 360º Overview Page

## Identificação

| Atributo | Valor |
|----------|-------|
| App ID | ZEWM_C360_OVP |
| Padrão Fiori | Overview Page (OVP) |
| Semantic Object | ZEWM_C360_HDR |
| Semantic Action | display |
| BSP Application | ZEWM_C360_OVP |
| OData Service | ZEWM_C360_SRV |
| Role mínima | Z_EWM_C360_EXEC |
| Tile | Cockpit EWM 360º |

---

## Objetivo

Ponto de entrada único do cockpit. Exibe cards analíticos consolidados por warehouse,
permitindo ao usuário perceber rapidamente desvios de KPIs, acúmulo de exceções e
volumes de documentos abertos — sem precisar navegar para cada app específico.

---

## Cards do Overview Page

### Card 1 — KPIs do Warehouse
```
Tipo       : Analytical Card
Título     : KPIs do Armazém
CDS        : ZC_EWM_C360_KPI
Medida     : ActualValue
Dimensão   : KpiName
Criticality: StatusCriticality
Linha de referência: TargetValue
Navegação  : → ZEWM_C360_KPI (List Report KPI)
```

### Card 2 — Exceções Abertas
```
Tipo       : Table Card
Título     : Exceções Pendentes
CDS        : ZC_EWM_C360_EXCEPTION
Filtro     : StatusCode != 'RESOLVED'
Colunas    : ExcType | Severity | SlaDueAt | Owner
Criticality: SeverityCriticality (por linha)
Máximo     : 5 linhas (top 5 mais críticas)
Navegação  : → ZEWM_C360_EXC (List Report Exceções)
```

### Card 3 — Documentos Inbound Abertos
```
Tipo       : KPI Card
Título     : Inbound Abertos
CDS        : ZC_EWM_C360_OVERVIEW (ProcessType = 'INBOUND', StatusCode = 'OPEN')
Medida     : TotalDocs
Trend      : DocsWithException (subtítulo: "N com exceção")
Criticality: StatusCriticality
Navegação  : → ZEWM_C360_IBD (List Report Inbound)
```

### Card 4 — Documentos Outbound Abertos
```
Tipo       : KPI Card
Título     : Outbound Abertos
CDS        : ZC_EWM_C360_OVERVIEW (ProcessType = 'OUTBOUND', StatusCode = 'OPEN')
Medida     : TotalDocs
Trend      : DocsWithException
Criticality: StatusCriticality
Navegação  : → ZEWM_C360_OBD (List Report Outbound)
```

### Card 5 — Tarefas de Armazém (WT) em Atraso
```
Tipo       : KPI Card
Título     : WTs em Atraso
CDS        : ZC_EWM_C360_OVERVIEW (ProcessType = 'WT', StatusCode = 'OVERDUE')
Medida     : TotalDocs
Criticality: fixo = 1 (vermelho quando > 0)
Navegação  : → ZEWM_C360_WT (List Report WT)
```

### Card 6 — Aging Médio por Processo
```
Tipo       : Analytical Card (Bar)
Título     : Aging Médio (dias)
CDS        : ZC_EWM_C360_OVERVIEW
Medida     : AvgAgingDays
Dimensão   : ProcessType
Criticality: StatusCriticality
Navegação  : sem navegação (informativo)
```

---

## Filtro Global (Smart Filter Bar)

| Campo | Label | Tipo | Obrigatório |
|-------|-------|------|-------------|
| Lgnum | Warehouse | Value Help (ZI_EWM_C360_VH_LGNUM) | Sim |
| OpenDate | Data Abertura | DateRange | Não |
| ProcessType | Processo | Value Help (ZI_EWM_C360_VH_PROCESS) | Não |

O filtro `Lgnum` é pré-preenchido com o warehouse padrão do usuário (configurado em
`ZTEWM_C360_CUST`, chave `DEFAULT_LGNUM_{USER}`). Se não configurado, exibe todos.

---

## manifest.json — estrutura relevante

```json
{
  "sap.app": {
    "id": "zewm.c360.ovp",
    "type": "application",
    "title": "EWM Cockpit 360º"
  },
  "sap.ovp": {
    "globalFilterModel": "ZEWM_C360_SRV",
    "globalFilterEntityType": "ZC_EWM_C360_OVERVIEWType",
    "enableLiveFilter": true,
    "cards": {
      "card00_kpi": {
        "model": "ZEWM_C360_SRV",
        "template": "sap.ovp.cards.analytical",
        "settings": { "entitySet": "ZC_EWM_C360_KPI", "title": "KPIs do Armazém" }
      },
      "card01_exc": {
        "model": "ZEWM_C360_SRV",
        "template": "sap.ovp.cards.table",
        "settings": { "entitySet": "ZC_EWM_C360_EXCEPTION", "title": "Exceções Pendentes", "tableType": "ResponsiveTable" }
      },
      "card02_inbound": {
        "model": "ZEWM_C360_SRV",
        "template": "sap.ovp.cards.v4.AnalyticalCard",
        "settings": { "entitySet": "ZC_EWM_C360_OVERVIEW", "title": "Inbound Abertos" }
      },
      "card03_outbound": {
        "model": "ZEWM_C360_SRV",
        "template": "sap.ovp.cards.v4.AnalyticalCard",
        "settings": { "entitySet": "ZC_EWM_C360_OVERVIEW", "title": "Outbound Abertos" }
      },
      "card04_wt": {
        "model": "ZEWM_C360_SRV",
        "template": "sap.ovp.cards.v4.AnalyticalCard",
        "settings": { "entitySet": "ZC_EWM_C360_OVERVIEW", "title": "WTs em Atraso" }
      },
      "card05_aging": {
        "model": "ZEWM_C360_SRV",
        "template": "sap.ovp.cards.analytical",
        "settings": { "entitySet": "ZC_EWM_C360_OVERVIEW", "title": "Aging Médio (dias)" }
      }
    }
  }
}
```

---

## Tile na Fiori Launchpad

| Atributo | Valor |
|----------|-------|
| Tipo | Dynamic Tile |
| Título | EWM Cockpit 360º |
| Subtítulo | Visão operacional do armazém |
| Ícone | sap-icon://warehouse |
| Número dinâmico | Total de exceções abertas (CRITICAL+HIGH) |
| Cor dinâmica | Vermelho se > 0, Verde se = 0 |

---

## Critérios de aceite

- [ ] OVP abre com 6 cards visíveis sem erro no console
- [ ] Filtro por Lgnum aplica-se a todos os cards simultaneamente
- [ ] Card de Exceções exibe no máximo 5 linhas com criticality colorida
- [ ] Clique em cada card navega para o List Report correspondente passando o Lgnum no contexto
- [ ] Tile dinâmico exibe contagem de exceções críticas e muda cor corretamente
- [ ] Sem chamadas OData desnecessárias (verificar Network tab): cada card faz 1 request
- [ ] Usuário com Z_EWM_C360_EXEC vê o app; usuário sem role recebe 403
