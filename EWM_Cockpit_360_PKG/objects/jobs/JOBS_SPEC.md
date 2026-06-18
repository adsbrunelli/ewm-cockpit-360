# EWM Cockpit 360º — Especificação de Jobs Batch

## Jobs obrigatórios

### Job 1 — ZEWM_C360_SNAPSHOT_DELTA

| Atributo | Valor |
|----------|-------|
| Job Name | `ZEWM_C360_SNAPSHOT_DELTA` |
| Programa | `ZEWM_C360_SNAPSHOT_JOB` |
| Parâmetro | `SNAP_TYPE=DELTA` |
| Periodicidade | A cada **15 minutos** (configurável via `SNAP_DELTA_MINUTES`) |
| Usuário técnico | `ZEWM_C360_SVC` (usuário de sistema, não pessoal) |
| Classe de job | `C` (baixa prioridade) |

**Funcionamento**:
1. Lê `ZTEWM_C360_SNAP_CTL` para cada LGNUM ativo
2. Tenta adquirir `LOCK_FLAG='X'` atomicamente
3. Executa `ZCL_EWM_C360_SNAPSHOT_RUNNER->RUN( SNAP_TYPE='DELTA' )`
4. Lê documentos/exceções/KPIs modificados desde `DELTA_FROM_TS`
5. Atualiza tabelas `ZTEWM_C360_*`
6. Libera `LOCK_FLAG=''` e atualiza `DELTA_TO_TS`

**Alerta de falha**: configurar SM36 para enviar e-mail ao grupo `DL_EWM_C360_SUPPORT`
quando o job terminar com status `Cancelled` ou com dump.

---

### Job 2 — ZEWM_C360_SNAPSHOT_FULL

| Atributo | Valor |
|----------|-------|
| Job Name | `ZEWM_C360_SNAPSHOT_FULL` |
| Programa | `ZEWM_C360_SNAPSHOT_JOB` |
| Parâmetro | `SNAP_TYPE=FULL` |
| Periodicidade | Diário às **02:00** |
| Usuário técnico | `ZEWM_C360_SVC` |
| Classe de job | `B` (média prioridade — roda sozinho no período de menor carga) |

**Funcionamento**:
- Idêntico ao DELTA mas ignora `DELTA_FROM_TS` — lê **todos** os documentos ativos
- Garante que dados incrementais perdidos por falha do DELTA sejam recuperados
- Duração esperada: 15–30 minutos dependendo do volume

---

### Job 3 — ZEWM_C360_RETRY

| Atributo | Valor |
|----------|-------|
| Job Name | `ZEWM_C360_RETRY` |
| Programa | `ZEWM_C360_RETRY_JOB` |
| Periodicidade | A cada **30 minutos** |
| Usuário técnico | `ZEWM_C360_SVC` |
| Classe de job | `C` |

**Funcionamento**:
1. Seleciona todos os registros de `ZTEWM_C360_HDR` com:
   - `REPROC_FLAG = 'X'`
   - `RETRY_COUNT < MAX_RETRY` (lido de `ZTEWM_C360_CUST`)
   - `STATUS_CODE IN ('BLOCKED', 'FAILED')`
   - `NEXT_RETRY_AT <= SY-DATUM && SY-UZEIT` (intervalo exponencial respeitado)
2. Para cada documento, chama `ZCL_EWM_C360_REPROCESSOR->REPROCESS( TYPE='AUTO' )`
3. Grava resultado em `ZTEWM_C360_ACTLOG`

**Intervalo exponencial**:
- 1ª tentativa: 5 min após a falha
- 2ª tentativa: 15 min após a 1ª
- 3ª tentativa: 45 min após a 2ª
- Após 3 falhas: `STATUS_CODE = 'FAILED'`, não reprocessa mais

---

### Job 4 — ZEWM_C360_WATCHDOG (DDI-02)

| Atributo | Valor |
|----------|-------|
| Job Name | `ZEWM_C360_WATCHDOG` |
| Programa | `ZEWM_C360_WATCHDOG_JOB` |
| Periodicidade | A cada **5 minutos** |
| Usuário técnico | `ZEWM_C360_SVC` |
| Classe de job | `C` (baixa prioridade) |

**Problema resolvido (DDI-02)**: se o job de snapshot falhar abruptamente (dump, kill, timeout
de workprocess) sem chamar `RELEASE_LOCK`, o `LOCK_FLAG` fica em 'X' para sempre e o
processo fica bloqueado indefinidamente. Sem watchdog, o único remédio é intervenção manual
no banco de dados.

**Funcionamento**:
```abap
"-- Selecionar todos os locks que excedem o timeout configurado
SELECT * FROM ztewm_c360_snap_ctl
  INTO TABLE @DATA(lt_stale)
  WHERE lock_flag   = abap_true
    AND lock_since  < @cl_abap_tstmp=>subtract(
          tstmp = cl_abap_tstmp=>utclong2tstmp( utc_long_current_utclong )
          secs  = lv_timeout_secs ).

"-- Para cada lock abandonado:
LOOP AT lt_stale INTO DATA(ls_stale).
  "-- Registrar alerta em ZTEWM_C360_ACTLOG
  "-- Limpar lock
  UPDATE ztewm_c360_snap_ctl
    SET lock_flag  = abap_false
        lock_by    = ''
        lock_since = '00000000000000'
        status_code = 'ERROR'
        error_msg  = |Watchdog: lock abandonado por { ls_stale-lock_by } limpo em { sy-datum }|
    WHERE lgnum        = ls_stale-lgnum
      AND snap_type    = ls_stale-snap_type
      AND process_type = ls_stale-process_type.
  COMMIT WORK.
ENDLOOP.
```

**Parâmetros configuráveis** (em `ZTEWM_C360_CUST`):

| PARAM_KEY | Valor padrão | Descrição |
|-----------|-------------|-----------|
| `WATCHDOG_TIMEOUT_MIN` | `30` | Minutos sem `RELEASE_LOCK` antes de limpar o lock |
| `WATCHDOG_ALERT_EMAIL` | `DL_EWM_C360_SUPPORT` | Grupo de e-mail para alertas |

**Critérios de aceite**:
- Lock com `LOCK_SINCE` > 30 min é limpo automaticamente
- Alerta registrado em `ZTEWM_C360_ACTLOG` com `ACTION_ID = 'WATCHDOG_CLEAN'`
- E-mail enviado ao grupo configurado quando lock for limpo
- Watchdog **não** limpa locks com `STATUS_CODE = 'RUNNING'` e `LOCK_SINCE` recente

---

## Configuração via SM36 (passo a passo)

### Criar job SNAPSHOT_DELTA

```
1. SM36 → Definir Job
2. Nome do job: ZEWM_C360_SNAPSHOT_DELTA
3. Classe do job: C
4. Passo do job:
   - Programa: ZEWM_C360_SNAPSHOT_JOB
   - Usuário: ZEWM_C360_SVC
   - Variante: DELTA (criar via SE38 → Ir para → Variantes)
5. Condições de início:
   - Imediatamente → depois repetir
   - Intervalo: 15 minutos
6. Salvar
```

### Criar variante DELTA para o programa

```
SE38 → ZEWM_C360_SNAPSHOT_JOB → Ir para → Variantes → Criar
  Nome da variante: DELTA
  SNAP_TYPE: DELTA
  Salvar como variante de background
```

---

## Monitoramento (SM37)

| Campo | Filtro recomendado |
|-------|-------------------|
| Job Name | `ZEWM_C360_*` |
| Status | Released, Active, Finished, Cancelled |
| Data | Hoje |
| Usuário | `ZEWM_C360_SVC` |

**Alertas operacionais**:
- `SNAPSHOT_DELTA` em `Released` há > 5 minutos → verificar workprocess (SM50)
- `SNAPSHOT_DELTA` com status `Cancelled` → executar `RUNBOOK_SNAPSHOT.md`
- `RETRY` sem execução nas últimas 2 horas → reagendar

---

## Usuário técnico de sistema (ZEWM_C360_SVC)

O usuário que executa os jobs **não deve ser pessoal**. Criar usuário técnico com:

| Atributo | Valor |
|----------|-------|
| Tipo | Sistema (tipo B) |
| Role | `Z_EWM_C360_SUPPORT` (leitura + reprocessamento) |
| Validade | Sem expiração |
| Senha | Gerenciada por SAP GRC / cofre de senhas |
| Login interativo | Bloqueado (`SU01 → Logon Data → No logon`) |
