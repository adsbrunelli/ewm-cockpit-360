# EZEWM_C360_SNAP — SAP Lock Object

## Finalidade

Lock Object SAP (ENQUEUE/DEQUEUE) para proteção de acesso concorrente à tabela `ZTEWM_C360_SNAP_CTL`.
Alternativa complementar ao UPDATE condicional quando for necessário bloquear durante uma transação
mais longa (ex.: leitura + processamento + escrita em sequência sem COMMIT intermediário).

## Tipo

`E` — Shared/Exclusive lock (padrão SE11)

## Tabela base

`ZTEWM_C360_SNAP_CTL`

## Campos de lock (argumentos de lock)

| Parâmetro | Campo tabela | Tipo | Descr. |
|---|---|---|---|
| `IV_LGNUM` | LGNUM | CHAR 4 | Warehouse |
| `IV_SNAP_TYPE` | SNAP_TYPE | CHAR 10 | Tipo FULL/DELTA |
| `IV_PROCESS_TYPE` | PROCESS_TYPE | CHAR 20 | Processo alvo |

> Chave composta = chave primária da tabela excluindo MANDT (o ENQUEUE inclui MANDT automaticamente).

## Funções geradas pelo sistema

O SAP gera automaticamente:
- `ENQUEUE_EZEWM_C360_SNAP` — adquirir lock
- `DEQUEUE_EZEWM_C360_SNAP` — liberar lock

## Uso em ABAP

```abap
" ----- ACQUIRE -----
CALL FUNCTION 'ENQUEUE_EZEWM_C360_SNAP'
  EXPORTING
    mode_ztewm_c360_snap_ctl = 'E'   " Exclusive
    mandt                    = sy-mandt
    lgnum                    = iv_lgnum
    snap_type                = iv_snap_type
    process_type             = iv_process_type
    _scope                   = '1'   " lock válido só na sessão atual
    _wait                    = abap_false
  EXCEPTIONS
    foreign_lock             = 1
    system_failure           = 2
    OTHERS                   = 3.

IF sy-subrc = 1.
  " já bloqueado por outra sessão — não executar
  rv_acquired = abap_false.
  RETURN.
ELSEIF sy-subrc > 1.
  RAISE EXCEPTION TYPE zcx_ewm_c360_snapshot
    EXPORTING textid = zcx_ewm_c360_snapshot=>lock_system_error.
ENDIF.
rv_acquired = abap_true.

" ----- RELEASE -----
CALL FUNCTION 'DEQUEUE_EZEWM_C360_SNAP'
  EXPORTING
    mode_ztewm_c360_snap_ctl = 'E'
    mandt                    = sy-mandt
    lgnum                    = iv_lgnum
    snap_type                = iv_snap_type
    process_type             = iv_process_type.
```

## Comparação: UPDATE condicional vs ENQUEUE

| Critério | UPDATE condicional | ENQUEUE/DEQUEUE |
|---|---|---|
| Atomicidade | Garantida pelo DB | Garantida pelo servidor de lock SAP |
| Escopo | Apenas escritas na tabela | Qualquer código no escopo do lock |
| Persistência após COMMIT | Lock removido com a transação | Controlado por `_scope` |
| Visibilidade (SM12) | Não aparece | Aparece — pode ser monitorado |
| Limpeza automática | Precisa de watchdog job | Liberado automaticamente ao encerrar sessão |
| Recomendado para | Locks curtos dentro de LUW único | Locks que atravessam múltiplas LUWs |

## Decisão de projeto

A implementação padrão do `ZCL_EWM_C360_SNAPSHOT_RUNNER~ACQUIRE_LOCK` usa **UPDATE condicional**
(padrão DDI-01) pois o lock é curto e contido dentro de uma única LUW do job.
O ENQUEUE é documentado aqui para casos futuros onde o snapshot precisar de lock entre LUWs.

## Sequência de transporte

Wave 2 — DDIC (junto com as tabelas Z). Lock Object deve ser transportado antes das classes consumidoras.

## Critérios de aceite

- Lock Object ativo em SE11 sem erros de ativação.
- Teste: chamar ENQUEUE duas vezes com mesmos parâmetros; segundo retorna `foreign_lock = 1`.
- Teste: chamar DEQUEUE após ENQUEUE; terceiro ENQUEUE deve ter `sy-subrc = 0`.
- Lock visível em SM12 enquanto ativo.
