# Z_EWM_C360_OUTBOUND — Role Operação Outbound

## Público-alvo

Operadores e supervisores de separação, embalagem, carregamento e expedição.

## Finalidade

Acesso ao cockpit restrito ao processo Outbound no(s) warehouse(s) atribuído(s). Permite visualização e execução de ações operacionais outbound. Reprocessamento somente manual.

## Authorization Objects

| Objeto | Campo | Valor | ACTVT |
|---|---|---|---|
| Z_EWM_C360A | LGNUM | Específico (configurar na role) | 03, 16 |
| Z_EWM_C360A | PROCESS | OUTBOUND, HU, WT, EXCEPTION, OVERVIEW | 03, 16 |
| Z_EWM_C360R | LGNUM | Específico (configurar na role) | 16 |
| Z_EWM_C360R | REPROC_T | MANUAL | 16 |
| Z_EWM_C360L | LGNUM | Específico (configurar na role) | 03 |
| Z_EWM_C360L | LOG_TYPE | ACTION, EXCEPTION | 03 |

## Permissões

- ✅ Visualizar Overview do warehouse atribuído
- ✅ Visualizar e filtrar documentos Outbound, HU e WT
- ✅ Visualizar exceções do processo Outbound
- ✅ Executar ações operacionais Outbound (confirmadas em ZTEWM_C360_ACTION)
- ✅ Reprocessar exceções manualmente (REPROC_T = MANUAL)
- ✅ Consultar Action Log e exceções do próprio warehouse
- ❌ Acessar processo Inbound
- ❌ Reprocessamento automático ou em bulk
- ❌ Administrar parâmetros

## Fiori — Tiles e Apps permitidos

- EWM C360 Overview (read-only)
- EWM C360 Outbound Monitor
- EWM C360 HU Management
- EWM C360 Warehouse Tasks
- EWM C360 Exceptions (filtrado por OUTBOUND/HU/WT)
- EWM C360 Action Log (filtrado por warehouse)

## Configuração na role PFCG

Campo LGNUM deve ser preenchido com o(s) warehouse(s) específico(s). Nunca usar `*`.

## Critérios de aceite

- Usuário não vê documentos Inbound.
- Reprocessamento BULK bloqueado.
- Action Log restrito ao warehouse configurado.
- Ações Outbound executam com log automático em ZTEWM_C360_ACTLOG.
