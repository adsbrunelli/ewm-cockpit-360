# ADR-004: Exception Engine e Matriz de Severidade

## Status

Proposta

## Contexto

Exceções operacionais e técnicas precisam ser classificadas por impacto, SLA e severidade.

## Decisão

Criar matriz parametrizada em `ZTEWM_C360_SEV_RULE` e persistir eventos em `ZTEWM_C360_EXC`.

## Consequências

- Cálculo reproduzível.
- Priorização operacional.
- Base para escalonamento.
