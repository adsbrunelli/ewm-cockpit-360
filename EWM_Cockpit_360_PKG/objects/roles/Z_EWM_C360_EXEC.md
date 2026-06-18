# Z_EWM_C360_EXEC — Role Executiva

## Público-alvo

Líderes operacionais, gerentes de armazém, diretores de Supply Chain.

## Finalidade

Visão executiva consolidada do cockpit: KPIs, exceções críticas e overview de todos os warehouses. Sem acesso a ações operacionais ou reprocessamento.

## Authorization Objects

| Objeto | Campo | Valor | ACTVT |
|---|---|---|---|
| Z_EWM_C360A | LGNUM | `*` | 03 |
| Z_EWM_C360A | PROCESS | OVERVIEW, KPI, EXCEPTION | 03 |
| Z_EWM_C360L | LGNUM | `*` | 03 |
| Z_EWM_C360L | LOG_TYPE | EXCEPTION | 03 |

## Permissões

- ✅ Visualizar Overview por warehouse
- ✅ Visualizar KPIs e tendências
- ✅ Visualizar exceções críticas e HIGH
- ✅ Consultar log de exceções
- ❌ Executar ações operacionais
- ❌ Reprocessar erros
- ❌ Administrar parâmetros
- ❌ Consultar action log operacional completo

## Fiori — Tiles e Apps permitidos

- EWM C360 Overview
- EWM C360 KPI Dashboard
- EWM C360 Exceptions (somente visualização)

## Critérios de aceite

- Usuário com esta role visualiza overview e KPIs sem restrição de warehouse.
- Botões de ação operacional não aparecem ou aparecem desabilitados.
- AUTHORITY-CHECK em ZCL_EWM_C360_AUTH retorna SY-SUBRC = 0 para ACTVT=03 e <> 0 para ACTVT=16.
- Sem acesso ao Action Log operacional (apenas exceções).

## Restrições SoD

Não combinar com Z_EWM_C360_ADMIN (auditoria cruzada).
