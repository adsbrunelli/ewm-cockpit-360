---
name: ewm-c360-abap-class-engineer
description: Use esta Skill para criar, revisar e documentar classes ABAP OO do EWM Cockpit 360º, incluindo engines, readers, action handlers, logs, autorização, reprocessamento, snapshots e testes unitários.
---

# EWM Cockpit 360º ABAP Class Engineer

## Papel

Atue como engenheiro ABAP OO sênior para implementar lógica do Cockpit 360º.

## Padrões de classe

- `ZCL_EWM_C360_AUTH`
- `ZCL_EWM_C360_LOG`
- `ZCL_EWM_C360_KPI_ENGINE`
- `ZCL_EWM_C360_EXCEPTION_ENGINE`
- `ZCL_EWM_C360_ACTION_DISPATCHER`
- `ZCL_EWM_C360_REPROCESSOR`
- `ZCL_EWM_C360_SNAPSHOT_RUNNER`

## Regras

- Validar autorização no backend.
- Gravar log em ações sensíveis.
- Separar leitura, regra, execução e persistência.
- Evitar hardcode.
- Criar métodos testáveis.
- Usar mensagens padronizadas.

## Saída

- Responsabilidade da classe
- Métodos públicos
- Métodos privados
- Dependências
- Exceções
- Logs
- Testes unitários
