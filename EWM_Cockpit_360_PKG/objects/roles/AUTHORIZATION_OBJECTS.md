# Authorization Objects: EWM Cockpit 360º

## Visão geral

O cockpit utiliza 4 authorization objects customizados. Cada objeto controla um domínio funcional independente, permitindo combinação granular nas roles PFCG.

---

## Z_EWM_C360A — Acesso ao Cockpit (objeto principal)

**Finalidade:** Controla acesso de leitura e execução de ações operacionais no cockpit.

| Campo | Tipo | Comprimento | Valores possíveis | Descrição |
|---|---|---|---|---|
| LGNUM | CHAR | 4 | Valores de warehouse específicos ou `*` | Número do Warehouse |
| PROCESS | CHAR | 20 | INBOUND, OUTBOUND, HU, WT, EXCEPTION, KPI, OVERVIEW, `*` | Tipo de Processo |
| ACTVT | CHAR | 2 | 03 = Exibir, 16 = Executar Ação | Atividade |

**Código ABAP padrão:**
```abap
" Verificar acesso de exibição a um processo/warehouse
AUTHORITY-CHECK OBJECT 'Z_EWM_C360A'
  ID 'LGNUM'   FIELD iv_lgnum
  ID 'PROCESS' FIELD iv_process
  ID 'ACTVT'   FIELD '03'.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE zcx_ewm_c360_auth
    EXPORTING
      textid  = zcx_ewm_c360_auth=>not_authorized
      lgnum   = iv_lgnum
      process = iv_process.
ENDIF.

" Verificar execução de ação
AUTHORITY-CHECK OBJECT 'Z_EWM_C360A'
  ID 'LGNUM'   FIELD iv_lgnum
  ID 'PROCESS' FIELD iv_process
  ID 'ACTVT'   FIELD '16'.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE zcx_ewm_c360_auth
    EXPORTING
      textid  = zcx_ewm_c360_auth=>action_not_authorized
      lgnum   = iv_lgnum
      process = iv_process.
ENDIF.
```

---

## Z_EWM_C360R — Reprocessamento

**Finalidade:** Controla execução de reprocessamento de exceções (ação de alto impacto operacional).

| Campo | Tipo | Comprimento | Valores possíveis | Descrição |
|---|---|---|---|---|
| LGNUM | CHAR | 4 | Valores específicos ou `*` | Número do Warehouse |
| REPROC_T | CHAR | 20 | AUTO, MANUAL, BULK, `*` | Tipo de Reprocessamento |
| ACTVT | CHAR | 2 | 16 = Executar | Atividade |

**Código ABAP padrão:**
```abap
AUTHORITY-CHECK OBJECT 'Z_EWM_C360R'
  ID 'LGNUM'   FIELD iv_lgnum
  ID 'REPROC_T' FIELD iv_reproc_type
  ID 'ACTVT'   FIELD '16'.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE zcx_ewm_c360_auth
    EXPORTING
      textid    = zcx_ewm_c360_auth=>reproc_not_authorized
      lgnum     = iv_lgnum
      reproc_tp = iv_reproc_type.
ENDIF.
```

---

## Z_EWM_C360M — Administração e Customizing

**Finalidade:** Controla manutenção de parâmetros, regras, KPI definitions, severity rules e ações do cockpit.

| Campo | Tipo | Comprimento | Valores possíveis | Descrição |
|---|---|---|---|---|
| PARAM_GRP | CHAR | 20 | RULES, KPI, SEVERITY, ACTIONS, CUST, INTEG, `*` | Grupo de Parâmetros |
| ACTVT | CHAR | 2 | 01 = Criar, 02 = Alterar, 03 = Exibir, 06 = Deletar | Atividade |

**Código ABAP padrão:**
```abap
AUTHORITY-CHECK OBJECT 'Z_EWM_C360M'
  ID 'PARAM_GRP' FIELD iv_param_group
  ID 'ACTVT'     FIELD iv_actvt.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE zcx_ewm_c360_auth
    EXPORTING
      textid     = zcx_ewm_c360_auth=>admin_not_authorized
      param_grp  = iv_param_group.
ENDIF.
```

---

## Z_EWM_C360L — Consulta de Logs e Auditoria

**Finalidade:** Controla acesso de leitura ao action log e histórico de exceções. Auditoria tem apenas ACTVT=03.

| Campo | Tipo | Comprimento | Valores possíveis | Descrição |
|---|---|---|---|---|
| LGNUM | CHAR | 4 | Valores específicos ou `*` | Número do Warehouse |
| LOG_TYPE | CHAR | 10 | ACTION, EXCEPTION, REPROC, ALL | Tipo de Log |
| ACTVT | CHAR | 2 | 03 = Exibir | Atividade (somente leitura) |

**Código ABAP padrão:**
```abap
AUTHORITY-CHECK OBJECT 'Z_EWM_C360L'
  ID 'LGNUM'    FIELD iv_lgnum
  ID 'LOG_TYPE' FIELD iv_log_type
  ID 'ACTVT'    FIELD '03'.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE zcx_ewm_c360_auth
    EXPORTING
      textid   = zcx_ewm_c360_auth=>log_not_authorized
      lgnum    = iv_lgnum
      log_type = iv_log_type.
ENDIF.
```

---

## Sequência de criação no SAP (SE11/SU21)

1. Criar classe de objeto de autorização: `ZEWM_C360` (via SU21 → Classe de objetos)
2. Criar authorization objects na ordem:
   - `Z_EWM_C360A` (depende apenas de LGNUM standard)
   - `Z_EWM_C360R` (depende de Z_EWM_C360A estar criado)
   - `Z_EWM_C360M` (independente)
   - `Z_EWM_C360L` (independente)
3. Transportar os objetos antes de criar as roles PFCG

## Sequência de transporte

Authorization Objects → Roles PFCG → Customizing inicial (atribuição de roles a usuários)
