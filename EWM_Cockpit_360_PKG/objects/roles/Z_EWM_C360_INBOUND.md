# Z_EWM_C360_INBOUND — Role Operação Inbound

## Público-alvo

Operadores e supervisores de recebimento, conferência e putaway.

## Finalidade

Acesso ao cockpit restrito ao processo Inbound no(s) warehouse(s) atribuído(s). Permite visualização e execução de ações operacionais inbound. Reprocessamento somente manual.

## Authorization Objects

| Objeto | Campo | Valor | ACTVT |
|---|---|---|---|
| Z_EWM_C360A | LGNUM | Específico (configurar na role) | 03, 16 |
| Z_EWM_C360A | PROCESS | INBOUND, EXCEPTION, OVERVIEW | 03, 16 |
| Z_EWM_C360R | LGNUM | Específico (configurar na role) | 16 |
| Z_EWM_C360R | REPROC_T | MANUAL | 16 |
| Z_EWM_C360L | LGNUM | Específico (configurar na role) | 03 |
| Z_EWM_C360L | LOG_TYPE | ACTION, EXCEPTION | 03 |

## Permissões

- ✅ Visualizar Overview do warehouse atribuído
- ✅ Visualizar e filtrar documentos Inbound
- ✅ Visualizar exceções do processo Inbound
- ✅ Executar ações operacionais Inbound (confirmadas em ZTEWM_C360_ACTION)
- ✅ Reprocessar exceções manualmente (REPROC_T = MANUAL)
- ✅ Consultar Action Log e exceções do próprio warehouse
- ❌ Acessar processos Outbound, HU, WT independentes
- ❌ Reprocessamento automático ou em bulk
- ❌ Administrar parâmetros

## Fiori — Tiles e Apps permitidos

- EWM C360 Overview (read-only)
- EWM C360 Inbound Monitor
- EWM C360 Exceptions (filtrado por INBOUND)
- EWM C360 Action Log (filtrado por warehouse)

## Configuração na role PFCG

Campo LGNUM deve ser preenchido com o(s) warehouse(s) específico(s) do operador. Nunca usar `*` para esta role.

## Critérios de aceite

- Usuário não vê documentos de outro warehouse.
- Botões de ação Outbound não aparecem ou estão desabilitados.
- Reprocessamento BULK bloqueado por AUTHORITY-CHECK.
- Action Log visível apenas para o warehouse configurado.
