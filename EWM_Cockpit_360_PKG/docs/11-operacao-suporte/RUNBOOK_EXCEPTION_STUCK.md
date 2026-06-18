# Runbook — Exceção Travada / Não Resolve

## Identificação do problema

**Sintoma A** — Exceção permanece `OPEN` após resolução via Fiori:
- Usuário clicou em "Resolver" e recebeu mensagem de sucesso
- Mas exceção ainda aparece na lista (status não mudou)

**Sintoma B** — Botão "Resolver" desabilitado para usuário que deveria ter permissão:
- Usuário com role `Z_EWM_C360_INBOUND` não consegue resolver exceção

**Sintoma C** — Exceção com SLA vencido sem owner atribuído:
- `OWNER` em branco, `SLA_DUE_AT` no passado, status `OPEN`

**Sintoma D** — Exceção em loop de reprocessamento (`RETRY_COUNT` chegou ao máximo):
- `STATUS_CODE = 'FAILED'`, `RETRY_COUNT = MAX_RETRY`

---

## Diagnóstico

### Passo 1 — Verificar dados da exceção (SE16)

```
SE16 → ZTEWM_C360_EXC
Filtro: EXC_ID = <id da exceção>
Campos a verificar:
  STATUS_CODE   — deve ser OPEN para exceções pendentes
  RESOLVED_FLAG — deve ser '' (em branco) para não resolvidas
  RETRY_COUNT   — comparar com MAX_RETRY em ZTEWM_C360_CUST
  OWNER         — em branco indica exceção sem responsável
  SLA_DUE_AT    — comparar com data/hora atual
  REPROC_FLAG   — 'X' indica elegível para reprocessamento
```

### Passo 2 — Verificar log de ações (SE16)

```
SE16 → ZTEWM_C360_ACTLOG
Filtro: DOC_ID = <exc_id>, ACTION_TYPE = 'RESOLVE'
Verificar: ACTION_RESULT (SUCCESS ou ERROR), ERROR_MSG
```

### Passo 3 — Verificar autorização do usuário (SU53)

Após tentativa negada, o usuário executa SU53 para capturar o objeto de autorização faltante.
O suporte compara com a matriz de roles (`objects/roles/ROLES_MATRIX.md`).

---

## Resolução

### Caso A — Exceção não resolvida após clique (race condition ou erro silencioso)

1. Verificar `ZTEWM_C360_ACTLOG` para ACTION_TYPE='RESOLVE' com ACTION_RESULT='ERROR'
2. Se ERROR_MSG contém `LOCK_OBJECT`: outra sessão atualizou o registro simultaneamente — pedir ao usuário tentar novamente
3. Se ERROR_MSG contém `AUTHORITY_CHECK`: revisar autorização (passo 3)
4. Se não há entrada no ACTLOG: o POST OData não chegou ao backend — verificar `/IWFND/ERROR_LOG`

### Caso B — Botão desabilitado incorretamente

Verificar via ABAP:
```abap
AUTHORITY-CHECK OBJECT 'Z_EWM_C360A'
  ID 'LGNUM'   FIELD 'WH01'
  ID 'PROCESS' FIELD 'EXCEPTION'
  ID 'ACTVT'   FIELD '16'.     "-- 16 = Modificar/Executar ação
WRITE: / 'SY-SUBRC:', sy-subrc.
"-- 0 = autorizado, 4 = negado
```

Se `sy-subrc = 4`: adicionar ACTVT=16 para PROCESS=EXCEPTION no perfil PFCG do usuário.

### Caso C — Exceção sem owner com SLA vencido

Atribuição manual de responsável via SM30:
```
SM30 → ZTEWM_C360_EXC → localizar registro → editar OWNER
```

Ou via Fiori (se usuário de suporte tiver role `Z_EWM_C360_SUPPORT`):
→ Object Page da exceção → ação "Atribuir Responsável"

Após atribuição, enviar notificação manual ao owner (e-mail ou Teams) — o sistema
não envia notificações automáticas (fora do escopo do MVP).

### Caso D — RETRY_COUNT esgotado (STATUS=FAILED)

O sistema não permite novo reprocessamento automático quando `RETRY_COUNT >= MAX_RETRY`.
Para reabilitar:

```
SM30 → ZTEWM_C360_HDR (ou ZTEWM_C360_EXC)
  → Localizar registro
  → Zerar RETRY_COUNT para 0
  → Salvar
```

**Registrar a intervenção** em `ZTEWM_C360_ACTLOG` com ACTION_TYPE='MANUAL_RESET'.

Após reset, o botão "Reprocessar" volta a ser habilitado no Fiori.

---

## Prevenção

- Configurar SLA_HOURS adequado em `ZTEWM_C360_SEV_RULE` para evitar SLAs impossíveis
- Atribuir owner padrão por tipo de exceção via `ZTEWM_C360_RULE` (campo DEFAULT_OWNER)
- MAX_RETRY configurado em `ZTEWM_C360_CUST` — valor recomendado: 3

---

## Escalada

| Situação | Escalada para |
|----------|--------------|
| Exceção não resolve após intervenção | Desenvolvedor ABAP (verificar ZCL_EWM_C360_EXCEPTION_ENGINE) |
| Problemas de autorização em PRD | Security (SAP GRC) |
| ACTLOG sem entradas (OData não chegou) | Basis (verificar /IWFND/ERROR_LOG) |
