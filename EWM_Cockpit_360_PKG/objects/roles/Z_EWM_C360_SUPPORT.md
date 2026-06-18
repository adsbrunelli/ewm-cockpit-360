# Z_EWM_C360_SUPPORT — Role Suporte Técnico

## Público-alvo

Analistas SAP, consultores de suporte, key users técnicos.

## Finalidade

Acesso completo de leitura ao cockpit para diagnóstico técnico. Reprocessamento manual e automático permitidos em todos os warehouses. Sem acesso a administração de parâmetros.

## Authorization Objects

| Objeto | Campo | Valor | ACTVT |
|---|---|---|---|
| Z_EWM_C360A | LGNUM | `*` | 03 |
| Z_EWM_C360A | PROCESS | `*` | 03 |
| Z_EWM_C360R | LGNUM | `*` | 16 |
| Z_EWM_C360R | REPROC_T | MANUAL, AUTO | 16 |
| Z_EWM_C360M | PARAM_GRP | RULES, KPI, SEVERITY | 03 |
| Z_EWM_C360L | LGNUM | `*` | 03 |
| Z_EWM_C360L | LOG_TYPE | ALL | 03 |

## Permissões

- ✅ Visualizar todos os processos em todos os warehouses
- ✅ Consultar todos os logs (Action Log, exceções, reprocessamento)
- ✅ Reprocessar manualmente e via job automático
- ✅ Visualizar (sem alterar) regras, KPIs e severidade
- ✅ Acesso ao Diagnostic Cockpit completo
- ❌ Executar ações operacionais (modificar documentos EWM)
- ❌ Reprocessamento BULK
- ❌ Criar ou alterar parâmetros de customizing

## Fiori — Tiles e Apps permitidos

- EWM C360 Overview (todos os warehouses)
- EWM C360 Diagnostic Cockpit
- EWM C360 Exceptions (todos os processos)
- EWM C360 Action Log (completo)
- EWM C360 Reprocessing Monitor
- EWM C360 Integration Monitor

## Critérios de aceite

- Usuário vê dados de todos os warehouses sem filtro.
- Reprocessamento BULK bloqueado por AUTHORITY-CHECK (REPROC_T = BULK → SY-SUBRC <> 0).
- Parâmetros visíveis mas campos de edição desabilitados.
- Acesso ao Diagnostic Cockpit liberado (integrações, jobs, SLG1).

## Restrições SoD

Não combinar com Z_EWM_C360_ADMIN sem justificativa documentada e aprovada.
