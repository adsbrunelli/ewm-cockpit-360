# Exception Standard

## Campos mínimos

- `EXC_TYPE`
- `SEVERITY`
- `STATUS_CODE`
- `ROOT_CAUSE`
- `MESSAGE_ID`
- `MESSAGE_NO`
- `SLA_DUE_AT`
- `RESOLVED_FLAG`

## Severidades

- LOW
- MEDIUM
- HIGH
- CRITICAL

## Regras

- Severidade deve ser calculável e parametrizada.
- Toda exceção crítica deve ter SLA e owner.
- Toda exceção resolvida deve manter histórico.
