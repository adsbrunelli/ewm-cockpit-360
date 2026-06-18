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

## Artefatos de teste

### Testes Unitários (ABAP Unit — RISK LEVEL HARMLESS)

| Classe de Teste | Classe Testada | Cenários |
|-----------------|----------------|----------|
| `tests/unit/LTCL_AUTH_CHECKER.abap` | `ZCL_EWM_C360_AUTH` | Autorização concedida, negada por LGNUM, negada por ACTVT, LGNUM vazio |
| `tests/unit/LTCL_KPI_ENGINE.abap` | `ZCL_EWM_C360_KPI_ENGINE` | Dentro/fora/no limite da tolerância, KPI sem definição, zero sem DUMP, log |
| `tests/unit/LTCL_EXCEPTION_ENGINE.abap` | `ZCL_EWM_C360_EXCEPTION_ENGINE` | Match CRITICAL, fallback MEDIUM, wildcard LGNUM, SLA, resolve, não autorizado |
| `tests/unit/LTCL_REPROCESSOR.abap` | `ZCL_EWM_C360_REPROCESSOR` | Elegibilidade, max retry, intervalo exponencial, sucesso, falha |
| `tests/unit/LTCL_SNAPSHOT_RUNNER.abap` | `ZCL_EWM_C360_SNAPSHOT_RUNNER` | Lock, concorrência, release no erro, delta timestamp, FULL ignora delta |

### Testes de Integração (RISK LEVEL DANGEROUS — rodar em DEV/QAS)

| Classe de Teste | O que valida |
|-----------------|-------------|
| `tests/integration/LTCL_CDS_VIEWS.abap` | Dados reais nas ZI_ views, campos calculados, access control |
| `tests/integration/LTCL_ODATA_SERVICE.abap` | Registro do serviço, entity sets, filtros, action 'resolve' |

### Testes E2E

| Arquivo | Cenários cobertos |
|---------|-----------------|
| `tests/e2e/E2E_SCENARIOS.md` | 8 cenários: OVP, Inbound, Outbound, KPI, Segurança, WT, Snapshot, Auditoria |

### Aceite com Key Users

| Arquivo | Conteúdo |
|---------|----------|
| `tests/acceptance/ACCEPTANCE_CHECKLIST.md` | 7 blocos, 35 critérios, assinaturas, critérios de bloqueio para GO-LIVE |

## Como executar os testes unitários

```abap
"-- No ADT (Eclipse): botão direito na classe → Run As → ABAP Unit Test
"-- No SAP GUI: SE80 → selecionar classe → menu Executar → ABAP Unit Test
"-- Cobertura: SE24 → menu Ambiente → Cobertura de código ABAP
```

## Padrão de mock (Dependency Injection)

```abap
"-- Injetar mocks pelo CONSTRUCTOR — nunca usar NEW direto nos métodos
DATA(lo_cut) = NEW zcl_ewm_c360_kpi_engine(
  io_auth = NEW ltd_auth_mock( )   "-- mock de autorização
  io_log  = NEW ltd_log_mock( )    "-- mock de log
).
```
