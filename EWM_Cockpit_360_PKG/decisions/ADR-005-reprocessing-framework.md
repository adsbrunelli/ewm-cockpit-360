# ADR-005: Reprocessing Framework

## Status

**Aceito** — 2026-06-18 · Decisor: Arquiteto técnico do projeto

## Contexto

Falhas técnicas controladas (erros de integração, jobs com erro, exceções com REPROC_FLAG = 'X') precisam de reprocessamento auditável, com limite de tentativas, log de cada retry e autorização para execução.

## Decisão

**Framework de reprocessamento: ZCL_EWM_C360_REPROCESSOR**

Política de retry:
| Parâmetro | Valor | Configurável em |
|---|---|---|
| MAX_RETRY | 3 tentativas | ZTEWM_C360_CUST (PARAM_KEY = MAX_RETRY) |
| Intervalo | Exponencial: 5min, 15min, 45min | ZTEWM_C360_CUST |
| Status após esgotamento | FAILED (não elegível para retry automático) | — |

Fluxo de execução:
1. Verificar REPROC_FLAG = 'X' e RETRY_COUNT < MAX_RETRY em ZTEWM_C360_EXC.
2. Validar autorização do usuário (objeto de autorização Z_EWM_C360A, campo ACTVT = 'REPROC').
3. Executar reprocessamento via handler específico por EXC_TYPE.
4. Incrementar RETRY_COUNT e registrar resultado em ZTEWM_C360_ACTLOG.
5. Se sucesso: RESOLVED_FLAG = 'X', STATUS = 'RESOLVED'.
6. Se erro: atualizar ROOT_CAUSE e aguardar próximo ciclo.

**Execução:** via Fiori action (usuário suporte) ou job agendado (SM36) por LGNUM.

## Alternativas consideradas

- Reprocessamento manual via transação SAP: rejeitado por falta de rastreabilidade e risco de execução duplicada.
- Retry imediato sem limite: rejeitado por risco de loop infinito e sobrecarga do sistema.

## Consequências

- Menor dependência de intervenção Basis/suporte para falhas técnicas comuns.
- Controle técnico robusto com MAX_RETRY configurável sem transporte.
- Todo reprocessamento grava em ZTEWM_C360_ACTLOG — auditável.
- Custo: governança obrigatória — role Z_EWM_C360_SUPPORT necessária para ação de reprocessamento.

## Critérios de revisão

Revisar se MAX_RETRY = 3 for insuficiente para integrações com janela de disponibilidade longa.
