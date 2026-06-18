# Runbook — Snapshot Job com Falha ou Travado

## Identificação do problema

**Sintoma A** — Dados do cockpit desatualizados (último snapshot há mais de 30 min):
- Overview Page mostra dados antigos
- `ZTEWM_C360_SNAP_CTL`: coluna `LAST_SUCCESS_TS` antiga

**Sintoma B** — Job de snapshot não inicia:
- SM37: job `ZEWM_C360_SNAPSHOT_DELTA` com status `Released` mas nunca `Active`

**Sintoma C** — Lock travado (job anterior abortou sem limpar LOCK_FLAG):
- `ZTEWM_C360_SNAP_CTL`: `LOCK_FLAG = 'X'` mas nenhum job em execução no SM37

---

## Diagnóstico

### Passo 1 — Verificar status dos jobs (SM37)

```
Transação : SM37
Usuário   : *
Job Name  : ZEWM_C360_SNAPSHOT*
Status    : Todos
Período   : Hoje
```

| Status do job | Significado | Ação |
|--------------|-------------|------|
| `Active` | Executando normalmente | Aguardar conclusão |
| `Released` há > 20 min | Fila de background cheia | Verificar workprocess (SM50) |
| `Finished` com erro | Job falhou | Verificar log (passo 2) |
| `Cancelled` | Abortado manualmente ou por timeout | Limpar lock (passo 4) |
| Ausente | Job não agendado | Reagendar (passo 5) |

### Passo 2 — Verificar log do job (SM37 → Log do job)

Erros comuns e causas:

| Mensagem de erro | Causa provável |
|-----------------|----------------|
| `Lock já ativo para LGNUM=WH01` | Lock travado de execução anterior |
| `AUTHORITY_CHECK failed for Z_EWM_C360L` | Usuário técnico do job sem autorização |
| `ZTEWM_C360_SNAP_CTL: entry not found` | Registro de controle não inicializado |
| `RFC/integration error` | Destino SM59 indisponível |
| `DUMP: DBIF_RSQL_TABLE_UNKNOWN` | Tabela não ativada — Wave 2 incompleta |

### Passo 3 — Verificar lock no SNAP_CTL

```
SE16 → ZTEWM_C360_SNAP_CTL
Filtro: LGNUM = <warehouse>, SNAP_TYPE = DELTA
Verificar: LOCK_FLAG, LAST_SUCCESS_TS, DELTA_FROM_TS
```

### Passo 4 — Limpar lock travado

**Usar somente quando confirmado que nenhum job está ativo para o LGNUM.**

```abap
"-- Executar via SE38 com relatório de manutenção (apenas suporte técnico)
UPDATE ztewm_c360_snap_ctl
  SET lock_flag     = ''
      changed_by    = sy-uname
      changed_at    = sy-uzeit
  WHERE lgnum     = 'WH01'
    AND snap_type = 'DELTA'.
COMMIT WORK.
```

Ou via SM30 (manutenção de tabela), se a view de manutenção estiver configurada.

**Registrar a intervenção em `ZTEWM_C360_ACTLOG`** com `ACTION_TYPE = 'LOCK_CLEARED'`.

### Passo 5 — Reagendar job ausente

```
SM36 → Definir job → ZEWM_C360_SNAPSHOT_DELTA
  Programa  : ZEWM_C360_SNAPSHOT_JOB
  Parâmetro : SNAP_TYPE=DELTA, LGNUM=* (todos os warehouses)
  Passo     : Usuário técnico ZEWM_C360_SVC
  Periodicidade: a cada 15 minutos
  Início    : imediato
```

---

## Escalada

| Situação | Escalada para |
|----------|--------------|
| DUMP durante execução (SM21) | Desenvolvedor ABAP |
| Workprocesses saturados (SM50) | Basis |
| Destino RFC indisponível | Administrador de integração |
| Dados corrompidos em SNAP_CTL | Líder Técnico SAP EWM |

---

## Prevenção

- O `CLEANUP` handler da classe `ZCL_EWM_C360_SNAPSHOT_RUNNER` limpa o lock automaticamente em caso de exceção.
- Se o ABAP dump ocorrer **antes** do `CLEANUP` (raro), o lock precisa de limpeza manual.
- Monitorar SM37 diariamente: nenhum job deve ficar em `Released` por mais de 5 minutos.
