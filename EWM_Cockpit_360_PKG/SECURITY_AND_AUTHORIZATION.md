# Security and Authorization: EWM Cockpit 360º

## Objetivo

Definir o modelo de segurança do Cockpit 360º, controlando visibilidade, ações, administração, auditoria e execução por warehouse.

## Perfis previstos

| Role | Público | Permissões |
|---|---|---|
| Z_EWM_C360_EXEC | Liderança e gestão | Visão executiva e KPIs |
| Z_EWM_C360_INBOUND | Operação inbound | Consulta e ações inbound permitidas |
| Z_EWM_C360_OUTBOUND | Operação outbound | Consulta e ações outbound permitidas |
| Z_EWM_C360_SUPPORT | Suporte técnico | Diagnóstico, logs e reprocessamento controlado |
| Z_EWM_C360_ADMIN | Administrador | Customizing, regras, KPIs, severidade |
| Z_EWM_C360_AUDIT | Auditoria | Consulta a logs e histórico |

## Autorizações mínimas

- Warehouse number (`LGNUM`)
- Processo
- Tipo de ação
- Nível de severidade
- Administração de parâmetros
- Consulta de logs
- Reprocessamento

## Regras

- Nenhuma action crítica pode executar sem validação de autorização.
- A autorização deve ser validada no backend, não apenas na UI.
- Action log deve registrar usuário, timestamp, ação, resultado e mensagem.
- Perfis de auditoria não devem executar alteração.
