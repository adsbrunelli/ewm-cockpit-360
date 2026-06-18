# EWM Cockpit 360º — Modelo de Navegação Cross-App

## Mapa de navegação

```
[Fiori Launchpad]
        │
        ├─► ZEWM_C360_OVP  (Overview Page — ponto de entrada)
        │         │
        │         ├─► ZEWM_C360_IBD  (Monitor Inbound)
        │         │         └─► Object Page: Documento Inbound
        │         │                   └─► ZEWM_C360_EXC (exceções do documento)
        │         │
        │         ├─► ZEWM_C360_OBD  (Monitor Outbound)
        │         │         └─► Object Page: Documento Outbound
        │         │                   └─► ZEWM_C360_EXC (exceções do documento)
        │         │
        │         ├─► ZEWM_C360_HU   (Gestão de HU)
        │         │         └─► Object Page: Handling Unit
        │         │
        │         ├─► ZEWM_C360_WT   (Tarefas de Armazém)
        │         │         └─► Object Page: Warehouse Task
        │         │                   └─► ZEWM_C360_EXC (exceções da tarefa)
        │         │
        │         ├─► ZEWM_C360_EXC  (Painel de Exceções)
        │         │         └─► Object Page: Exceção
        │         │                   └─► ZEWM_C360_IBD / OBD / WT (documento origem)
        │         │
        │         └─► ZEWM_C360_KPI  (Dashboard de KPIs)
        │                   └─► Object Page: KPI
        │
        └─► (acesso direto a qualquer app pelo tile)
```

---

## Semantic Objects e Actions

| App | Semantic Object | Action | Parâmetros de entrada |
|-----|----------------|--------|----------------------|
| OVP | ZEWM_C360_HDR | display | Lgnum |
| Inbound LR | ZEWM_C360_IBD | display | Lgnum, ProcessType='INBOUND' |
| Outbound LR | ZEWM_C360_OBD | display | Lgnum, ProcessType='OUTBOUND' |
| HU LR | ZEWM_C360_HU | display | Lgnum |
| WT LR | ZEWM_C360_WT | display | Lgnum |
| Exceções LR | ZEWM_C360_EXC | display | Lgnum, DocId (opcional) |
| KPI LR | ZEWM_C360_KPI | display | Lgnum, ProcessType (opcional) |
| Inbound OP | ZEWM_C360_IBD | manage | Lgnum, DocId |
| Outbound OP | ZEWM_C360_OBD | manage | Lgnum, DocId |
| HU OP | ZEWM_C360_HU | manage | Lgnum, DocId |
| WT OP | ZEWM_C360_WT | manage | Lgnum, DocId |
| Exceção OP | ZEWM_C360_EXC | manage | Lgnum, ExcId |
| KPI OP | ZEWM_C360_KPI | manage | Lgnum, KpiId, PeriodDate |

---

## Configuração no manifest.json (padrão)

```json
"crossNavigation": {
  "outbounds": {
    "toExceptions": {
      "semanticObject": "ZEWM_C360_EXC",
      "action": "display",
      "parameters": {
        "Lgnum": { "value": { "value": "Lgnum", "format": "binding" } },
        "DocId": { "value": { "value": "DocId",  "format": "binding" } }
      }
    },
    "toInbound": {
      "semanticObject": "ZEWM_C360_IBD",
      "action": "display",
      "parameters": {
        "Lgnum": { "value": { "value": "Lgnum", "format": "binding" } }
      }
    }
  }
}
```

---

## Passagem de contexto (context propagation)

- O filtro `Lgnum` é sempre propagado entre apps via parâmetro de navegação
- Ao navegar do OVP card de Inbound → List Report Inbound, o `Lgnum` selecionado no OVP
  pré-preenche o filtro da barra de filtros do List Report
- Ao navegar de uma linha de documento → Painel de Exceções, o `DocId` é passado como
  filtro inicial, restringindo a lista àquele documento

---

## Configuração de Tiles no Fiori Launchpad Designer

| Tile | Catalog | Grupo sugerido | Tile Type |
|------|---------|----------------|-----------|
| EWM Cockpit 360º | ZEWM_C360_CAT | EWM Operacional | Dynamic (contador exceções) |
| Monitor Inbound | ZEWM_C360_CAT | EWM Operacional | Static |
| Monitor Outbound | ZEWM_C360_CAT | EWM Operacional | Static |
| Gestão de HU | ZEWM_C360_CAT | EWM Operacional | Static |
| Tarefas de Armazém | ZEWM_C360_CAT | EWM Operacional | Static |
| Painel de Exceções | ZEWM_C360_CAT | EWM Operacional | Dynamic (contador CRITICAL+HIGH) |
| Dashboard de KPIs | ZEWM_C360_CAT | EWM Operacional | Dynamic (contador KPIs RED) |

### Tile dinâmico — configuração do contador

```
Service URL : /sap/opu/odata/sap/ZEWM_C360_SRV/ZC_EWM_C360_EXCEPTION/$count
             ?$filter=StatusCode ne 'RESOLVED' and Severity eq 'CRITICAL'
Refresh     : 300 segundos (5 min)
Cor         : Vermelha se > 0, Verde se = 0
```

---

## Critérios de aceite

- [ ] Navegação OVP card → List Report preserva Lgnum no filtro destino
- [ ] Navegação List Report linha → Object Page exibe dados do registro correto
- [ ] Navegação Object Page → Painel Exceções passa DocId e exibe somente exceções daquele doc
- [ ] Tile dinâmico atualiza contador de exceções a cada 5 minutos
- [ ] Tile oculto automaticamente para roles que não têm o catalog atribuído
- [ ] Back button em qualquer Object Page retorna para o List Report com filtros intactos
