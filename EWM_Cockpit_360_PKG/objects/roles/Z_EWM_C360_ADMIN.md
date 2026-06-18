# Z_EWM_C360_ADMIN — Role Administração do Cockpit

## Público-alvo

Administrador SAP do cockpit, arquiteto técnico, responsável pelo customizing.

## Finalidade

Acesso completo ao cockpit incluindo manutenção de parâmetros, regras, KPIs, severidade, ações e integrações. Role de uso restrito — atribuição deve ser exceção documentada.

## Authorization Objects

| Objeto | Campo | Valor | ACTVT |
|---|---|---|---|
| Z_EWM_C360A | LGNUM | `*` | 03, 16 |
| Z_EWM_C360A | PROCESS | `*` | 03, 16 |
| Z_EWM_C360R | LGNUM | `*` | 16 |
| Z_EWM_C360R | REPROC_T | `*` | 16 |
| Z_EWM_C360M | PARAM_GRP | `*` | 01, 02, 03, 06 |
| Z_EWM_C360L | LGNUM | `*` | 03 |
| Z_EWM_C360L | LOG_TYPE | ALL | 03 |

## Permissões

- ✅ Visualizar e executar ações em todos os processos e warehouses
- ✅ Criar, alterar e deletar regras (ZTEWM_C360_RULE)
- ✅ Criar, alterar e deletar definições de KPI (ZTEWM_C360_KPI_DEF)
- ✅ Manter matriz de severidade (ZTEWM_C360_SEV_RULE)
- ✅ Manter tabela de ações (ZTEWM_C360_ACTION)
- ✅ Manter customizing geral (ZTEWM_C360_CUST)
- ✅ Manter configuração de integrações (ZTEWM_C360_INTEG_CFG)
- ✅ Reprocessamento BULK
- ✅ Consultar todos os logs
- ❌ Deletar Action Log (proibido por política — nenhuma role pode deletar ACTLOG)

## Fiori — Tiles e Apps permitidos

Todos os apps do cockpit incluindo apps de manutenção (SM30 equivalente Fiori).

## Critérios de aceite

- Usuário consegue criar/alterar/deletar em todas as tabelas de customizing.
- Nenhum usuário com esta role consegue deletar registros de ZTEWM_C360_ACTLOG.
- Atribuição desta role requer aprovação documentada do responsável de segurança.
- Revisão de acesso obrigatória a cada 90 dias.

## Restrições SoD

- **Proibido combinar com Z_EWM_C360_AUDIT** — conflito de SoD direto.
- Não combinar com Z_EWM_C360_INBOUND ou Z_EWM_C360_OUTBOUND em usuários operacionais.
- Máximo recomendado: 2-3 usuários com esta role por ambiente produtivo.
