# Object Catalog: EWM Cockpit 360º

## Finalidade

Este documento lista os objetos técnicos previstos para o Cockpit 360º e serve como base para a planilha `OBJECT_CATALOG.xlsx`.

## Tabelas Z

| Objeto | Tipo | Finalidade | Status |
|---|---|---|---|
| ZTEWM_C360_HDR | DDIC Table | Cabeçalho operacional dos documentos monitorados | Planejado |
| ZTEWM_C360_ITEM | DDIC Table | Itens operacionais vinculados ao cabeçalho | Planejado |
| ZTEWM_C360_EXC | DDIC Table | Registro de exceções operacionais e técnicas | Planejado |
| ZTEWM_C360_KPI | DDIC Table | Valores calculados dos KPIs | Planejado |
| ZTEWM_C360_ACTLOG | DDIC Table | Auditoria das ações executadas | Planejado |
| ZTEWM_C360_RULE | DDIC Table | Regras parametrizadas sem hardcode | Planejado |
| ZTEWM_C360_SNAP_CTL | DDIC Table | Controle de snapshots delta/full | Planejado |
| ZTEWM_C360_SEV_RULE | DDIC Table | Matriz de severidade | Planejado |
| ZTEWM_C360_KPI_DEF | DDIC Table | Definição mestre dos KPIs | Planejado |
| ZTEWM_C360_ACTION | DDIC Table | Ações, botões, handlers e autorizações | Planejado |
| ZTEWM_C360_CUST | DDIC Table | Customizing do cockpit | Planejado |
| ZTEWM_C360_DEP | DDIC Table | Dependências técnicas entre objetos | Planejado |
| ZTEWM_C360_INTEG_CFG | DDIC Table | Configuração de integrações | Planejado |
| ZTEWM_C360_UI_MAP | DDIC Table | Mapeamento técnico da UI Fiori | Planejado |

## Views CDS previstas

- `ZI_EWM_C360_HDR`
- `ZI_EWM_C360_ITEM`
- `ZI_EWM_C360_EXC`
- `ZI_EWM_C360_KPI`
- `ZI_EWM_C360_ACTLOG`
- `ZC_EWM_C360_OVERVIEW`
- `ZC_EWM_C360_INBOUND`
- `ZC_EWM_C360_OUTBOUND`
- `ZC_EWM_C360_HU`
- `ZC_EWM_C360_WT`
- `ZC_EWM_C360_EXCEPTION`
- `ZC_EWM_C360_KPI`

## Classes ABAP previstas

- `ZCL_EWM_C360_AUTH`
- `ZCL_EWM_C360_LOG`
- `ZCL_EWM_C360_KPI_ENGINE`
- `ZCL_EWM_C360_EXCEPTION_ENGINE`
- `ZCL_EWM_C360_ACTION_DISPATCHER`
- `ZCL_EWM_C360_REPROCESSOR`
- `ZCL_EWM_C360_SNAPSHOT_RUNNER`
- `ZCL_EWM_C360_DEPENDENCY_CHECK`

## Serviços previstos

- `ZUI_EWM_C360_OVERVIEW`
- `ZUI_EWM_C360_INBOUND`
- `ZUI_EWM_C360_OUTBOUND`
- `ZUI_EWM_C360_EXCEPTION`
- `ZUI_EWM_C360_KPI`
- `ZUI_EWM_C360_ACTION_LOG`

## Roles previstas

- `Z_EWM_C360_EXEC`
- `Z_EWM_C360_INBOUND`
- `Z_EWM_C360_OUTBOUND`
- `Z_EWM_C360_SUPPORT`
- `Z_EWM_C360_ADMIN`
- `Z_EWM_C360_AUDIT`
