# EWM Cockpit 360º — Catálogo de Apps Fiori

## Visão geral

| App ID | Nome | Padrão Fiori | CDS de consumo | Role mínima |
|--------|------|--------------|----------------|-------------|
| ZEWM_C360_OVP | EWM Cockpit — Overview | OVP (Overview Page) | ZC_EWM_C360_OVERVIEW + ZC_EWM_C360_KPI + ZC_EWM_C360_EXCEPTION | Z_EWM_C360_EXEC |
| ZEWM_C360_IBD | Monitor Inbound | List Report + Object Page | ZC_EWM_C360_INBOUND | Z_EWM_C360_INBOUND |
| ZEWM_C360_OBD | Monitor Outbound | List Report + Object Page | ZC_EWM_C360_OUTBOUND | Z_EWM_C360_OUTBOUND |
| ZEWM_C360_HU  | Gestão de HU | List Report + Object Page | ZC_EWM_C360_HU | Z_EWM_C360_OUTBOUND |
| ZEWM_C360_WT  | Tarefas de Armazém | List Report + Object Page | ZC_EWM_C360_WT | Z_EWM_C360_EXEC |
| ZEWM_C360_EXC | Painel de Exceções | List Report + Object Page | ZC_EWM_C360_EXCEPTION | Z_EWM_C360_EXEC |
| ZEWM_C360_KPI | Dashboard de KPIs | List Report + Object Page | ZC_EWM_C360_KPI | Z_EWM_C360_EXEC |

## Padrões de design

- **OVP** — cards analíticos para visão 360° por warehouse; ponto de entrada do cockpit
- **List Report** — tabela filtrável com barra de filtros e toolbar; linhas com criticality colorida
- **Object Page** — detalhe do documento com facets, groups e ações inline
- Todos os apps usam **Fiori Elements** (ADR-008); nenhum app freestyle
- Navegação entre apps via **cross-app navigation** (semantic object `ZEWM_C360_*`)

## Sequência de criação no SAP

```
1. Criar OData Service (SEGW ou annotation-driven) por CDS view
2. Ativar e publicar service (transaction /IWFND/MAINT_SERVICE)
3. Criar app Fiori Elements no BAS (Business Application Studio)
4. Configurar manifest.json (dataSource, routing, targets)
5. Deploy para ABAP (BSP application ZEWM_C360_*)
6. Criar Fiori Tile na Fiori Launchpad Designer
7. Atribuir tile ao catalog e catalog ao role PFCG
```

## Arquivos de especificação

- [OVP — Overview Page](./OVP_OVERVIEW.md)
- [List Report — Inbound](./LR_INBOUND.md)
- [List Report — Outbound](./LR_OUTBOUND.md)
- [List Report — HU](./LR_HU.md)
- [List Report — WT](./LR_WT.md)
- [List Report — Exceções](./LR_EXCEPTION.md)
- [List Report — KPI](./LR_KPI.md)
- [Object Page — Documento HDR](./OP_HDR.md)
- [Object Page — Exceção](./OP_EXCEPTION.md)
- [Object Page — KPI](./OP_KPI.md)
