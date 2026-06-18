# Test Strategy: EWM Cockpit 360º

## Objetivo

Definir a estratégia de testes do Cockpit 360º cobrindo unidade, integração, regressão, performance e aceite funcional.

## Tipos de teste

| Tipo | Objetivo |
|---|---|
| Unitário | Validar classes, engines, regras e cálculos |
| Integração | Validar DDIC, CDS, classes, serviços e Fiori |
| E2E | Validar processos completos inbound, outbound, HU, WT e exceptions |
| Segurança | Validar roles, warehouses e actions |
| Performance | Validar filtros, consultas e snapshots |
| Aceite | Validar critérios funcionais com operação e key users |

## Cenários obrigatórios

- Dashboard overview por warehouse.
- Inbound com exceção de recebimento.
- Outbound com picking pendente.
- HU com divergência.
- WT aberta com aging crítico.
- KPI fora da tolerância.
- Reprocessamento com erro e retry.
- Action Fiori com autorização válida.
- Action Fiori com autorização negada.
- Consulta de action log.
