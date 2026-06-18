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

## Authorization Objects

| Objeto | Classe | Finalidade | Campos |
|---|---|---|---|
| Z_EWM_C360A | ZEWM_C360 | Acesso ao cockpit (leitura e ações) | LGNUM, PROCESS, ACTVT |
| Z_EWM_C360R | ZEWM_C360 | Reprocessamento de exceções | LGNUM, REPROC_T, ACTVT |
| Z_EWM_C360M | ZEWM_C360 | Administração e customizing | PARAM_GRP, ACTVT |
| Z_EWM_C360L | ZEWM_C360 | Consulta de logs e auditoria | LGNUM, LOG_TYPE, ACTVT |

Especificação completa: [objects/roles/AUTHORIZATION_OBJECTS.md](objects/roles/AUTHORIZATION_OBJECTS.md)

Matriz roles × objetos: [objects/roles/ROLES_MATRIX.md](objects/roles/ROLES_MATRIX.md)

## Regras

- Nenhuma action crítica pode executar sem validação de autorização via AUTHORITY-CHECK no backend.
- A autorização é sempre validada no backend (ZCL_EWM_C360_AUTH) — a UI apenas reflete o resultado.
- Action log deve registrar usuário, timestamp, ação, resultado e mensagem em ZTEWM_C360_ACTLOG.
- Perfis de auditoria não devem executar qualquer alteração (ACTVT = 03 apenas).
- LGNUM específico deve ser configurado na role para operadores — nunca usar `*` para INBOUND/OUTBOUND.
- Z_EWM_C360_ADMIN e Z_EWM_C360_AUDIT são mutuamente exclusivos (conflito SoD).
- Revisão de acessos: ADMIN e SUPPORT a cada 90 dias; AUDIT anualmente.

## Sequência de criação no SAP

1. Criar classe de objetos `ZEWM_C360` via SU21
2. Criar os 4 authorization objects (SU21)
3. Transportar objetos de autorização
4. Criar roles PFCG com os objetos e valores definidos
5. Transportar roles
6. Atribuir roles a usuários (configuração local por ambiente)
