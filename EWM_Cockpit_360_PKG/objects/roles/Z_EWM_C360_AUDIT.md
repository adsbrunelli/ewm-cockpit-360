# Z_EWM_C360_AUDIT — Role Auditoria

## Público-alvo

Auditores internos, compliance, controladoria, gestão de qualidade.

## Finalidade

Acesso somente leitura a todos os logs, histórico de ações, exceções resolvidas e parâmetros de configuração. Nenhuma ação operacional ou administrativa permitida.

## Authorization Objects

| Objeto | Campo | Valor | ACTVT |
|---|---|---|---|
| Z_EWM_C360A | LGNUM | `*` | 03 |
| Z_EWM_C360A | PROCESS | `*` | 03 |
| Z_EWM_C360M | PARAM_GRP | `*` | 03 |
| Z_EWM_C360L | LGNUM | `*` | 03 |
| Z_EWM_C360L | LOG_TYPE | ALL | 03 |

## Permissões

- ✅ Visualizar Overview e dados de todos os processos e warehouses
- ✅ Consultar Action Log completo (todos os warehouses, todos os tipos)
- ✅ Consultar histórico de exceções (incluindo resolvidas)
- ✅ Visualizar parâmetros, regras e KPI definitions (sem alterar)
- ✅ Exportar dados para análise (conforme configuração Fiori)
- ❌ Executar qualquer ação operacional (ACTVT=16 bloqueado)
- ❌ Reprocessar erros
- ❌ Criar ou alterar qualquer parâmetro
- ❌ Acessar dados de credenciais ou RFC destinations

## Fiori — Tiles e Apps permitidos

- EWM C360 Overview (read-only)
- EWM C360 Action Log (completo, read-only)
- EWM C360 Exceptions History (read-only)
- EWM C360 KPI History (read-only)
- EWM C360 Parameter Viewer (read-only)

## Critérios de aceite

- Nenhum botão de ação visível ou habilitado.
- AUTHORITY-CHECK com ACTVT=16 retorna SY-SUBRC <> 0 para esta role.
- Acesso ao Action Log inclui registros históricos além dos 90 dias ativos.
- Esta role nunca pode ser combinada com Z_EWM_C360_ADMIN.

## Restrições SoD

- **Proibido combinar com Z_EWM_C360_ADMIN** — auditoria não pode administrar o que audita.
- Proibido combinar com qualquer role operacional (INBOUND/OUTBOUND) para o mesmo processo auditado.
- Revisão de acesso: anual ou quando houver mudança de função do usuário.
