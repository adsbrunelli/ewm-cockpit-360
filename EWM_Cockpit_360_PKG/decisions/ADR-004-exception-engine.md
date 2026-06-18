# ADR-004: Exception Engine e Matriz de Severidade

## Status

**Aceito** — 2026-06-18 · Decisor: Arquiteto técnico do projeto

## Contexto

Exceções operacionais (divergência de HU, WT bloqueada, KPI fora de tolerância) e técnicas (erro de job, falha de integração) precisam ser classificadas de forma consistente por impacto, SLA e severidade — sem critério subjetivo ou hardcoded por processo.

## Decisão

**Matriz de severidade parametrizada em ZTEWM_C360_SEV_RULE:**
- Chave: EXC_TYPE + PROCESS_TYPE + LGNUM.
- Fallback: LGNUM = '*' para regras globais.
- Define: SEVERITY, SLA_HOURS, ESCALATION_H e ESCALATION_TO.

**Registro de exceções em ZTEWM_C360_EXC:**
- Cada exceção tem: EXC_TYPE, SEVERITY calculado, STATUS (OPEN/IN_PROCESS/RESOLVED), SLA_DUE_AT, ROOT_CAUSE, owner e rastreabilidade ao documento/item origem.
- Exceções resolvidas mantêm histórico (RESOLVED_FLAG = 'X', registro nunca deletado).

**Engine: ZCL_EWM_C360_EXCEPTION_ENGINE**
- Recebe contexto (LGNUM, PROCESS_TYPE, EXC_TYPE).
- Resolve severidade via ZTEWM_C360_SEV_RULE (específico → global).
- Calcula SLA_DUE_AT = CREATED_AT + SLA_HOURS.
- Persiste em ZTEWM_C360_EXC.
- Verifica elegibilidade para reprocessamento (REPROC_FLAG).

## Alternativas consideradas

- Severidade hardcoded por tipo de exceção: rejeitado por impossibilidade de ajuste sem transporte.
- Classificação manual por usuário operacional: rejeitado por inconsistência e falta de rastreabilidade.

## Consequências

- Cálculo reproduzível e auditável por matriz.
- Priorização operacional consistente entre warehouses.
- Base para escalonamento automático configurável.
- Custo: toda nova exceção precisa de regra em ZTEWM_C360_SEV_RULE.

## Critérios de revisão

Revisar se escalonamento automático precisar de integração com sistema externo (email, Teams, ServiceNow).
