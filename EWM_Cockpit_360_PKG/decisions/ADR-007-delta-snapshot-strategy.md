# ADR-007: Estratégia de Delta Snapshot

## Status

**Aceito** — 2026-06-18 · Decisor: Arquiteto técnico do projeto

## Contexto

ADR-002 decidiu usar snapshots para dados de alto volume. Falta definir a estratégia de delta: qual é a chave de controle, como determinar o intervalo, qual a janela de retenção e como tratar conflitos de execução concorrente. Sem isso, cada job de snapshot pode ser implementado de forma incompatível.

## Decisão

### Chave de controle delta

Registrada em ZTEWM_C360_SNAP_CTL com chave: `LGNUM + SNAP_TYPE + PROCESS_TYPE`.

- **DELTA_FROM_TS:** timestamp do último snapshot bem-sucedido (FINISHED_AT do registro anterior com STATUS = 'SUCCESS').
- **DELTA_TO_TS:** timestamp de início da execução atual (STARTED_AT).
- O job busca apenas registros SAP EWM com CHANGE_TIMESTAMP entre DELTA_FROM_TS e DELTA_TO_TS.

### Tipos de snapshot

| Tipo | Frequência recomendada | Configurável em |
|---|---|---|
| DELTA | A cada 15 minutos | ZTEWM_C360_CUST (SNAP_DELTA_MINUTES) |
| FULL | 1x por dia (madrugada) | ZTEWM_C360_CUST (SNAP_FULL_CRON) |

O FULL garante consistência e corrige eventuais gaps do delta. O DELTA mantém o cockpit atualizado durante o dia.

### Controle de concorrência

1. Job lê LOCK_FLAG na chave correspondente em ZTEWM_C360_SNAP_CTL.
2. Se LOCK_FLAG = 'X' → aborta execução e registra log de aviso em SLG1.
3. Se livre → grava LOCK_FLAG = 'X' e STATUS = 'RUNNING' antes de iniciar.
4. Ao finalizar (sucesso ou erro) → limpa LOCK_FLAG, atualiza STATUS e FINISHED_AT.

### Retenção

- Dados ativos em ZTEWM_C360_HDR/ITEM: 90 dias.
- Após 90 dias: job de arquivamento move para tabela histórica (a criar em ADR futuro).
- Registros de controle em ZTEWM_C360_SNAP_CTL: mantidos sem limite (volume pequeno).

## Alternativas consideradas

- Delta por número de documento (DOC_ID sequencial): rejeitado — DOC_IDs SAP EWM não são sequenciais garantidos entre processos.
- Delta por data de criação apenas: rejeitado — documentos podem ser atualizados sem nova criação.
- Sem delta (full a cada execução): rejeitado por custo de I/O inaceitável em warehouses de alto volume.

## Consequências

- Snapshots delta consistentes e rastreáveis por ZTEWM_C360_SNAP_CTL.
- Nenhum job concorrente para o mesmo LGNUM+PROCESS_TYPE.
- Latência máxima do cockpit: 1 ciclo de delta (15 min por padrão, configurável).
- Custo: job full diário necessário para garantir consistência.

## Critérios de revisão

Revisar se a latência de 15 minutos for crítica para algum processo. Considerar evento-driven via qRFC para exceções em tempo real.
