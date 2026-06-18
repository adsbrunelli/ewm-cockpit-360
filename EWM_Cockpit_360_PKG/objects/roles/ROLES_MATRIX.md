# Matriz de Roles × Authorization Objects: EWM Cockpit 360º

## Legenda

| Símbolo | Significado |
|---|---|
| ✅ | Permitido com restrição de warehouse |
| ✅* | Permitido para todos os warehouses |
| ❌ | Não permitido |
| 03 | ACTVT = Exibir |
| 16 | ACTVT = Executar Ação |
| 01/02/06 | ACTVT = Criar / Alterar / Deletar |

---

## Z_EWM_C360A — Acesso ao Cockpit

| Role | LGNUM | PROCESS | ACTVT | Observação |
|---|---|---|---|---|
| Z_EWM_C360_EXEC | `*` | OVERVIEW, KPI, EXCEPTION | 03 | Visão executiva — somente leitura |
| Z_EWM_C360_INBOUND | Específico | INBOUND, EXCEPTION, OVERVIEW | 03, 16 | Leitura + ações inbound permitidas |
| Z_EWM_C360_OUTBOUND | Específico | OUTBOUND, EXCEPTION, OVERVIEW | 03, 16 | Leitura + ações outbound permitidas |
| Z_EWM_C360_SUPPORT | `*` | `*` | 03 | Diagnóstico completo — somente leitura |
| Z_EWM_C360_ADMIN | `*` | `*` | 03, 16 | Acesso total de leitura e execução |
| Z_EWM_C360_AUDIT | `*` | `*` | 03 | Somente leitura — sem ações |

---

## Z_EWM_C360R — Reprocessamento

| Role | LGNUM | REPROC_T | ACTVT | Observação |
|---|---|---|---|---|
| Z_EWM_C360_EXEC | — | — | ❌ | Sem acesso a reprocessamento |
| Z_EWM_C360_INBOUND | Específico | MANUAL | 16 | Só reprocessamento manual inbound |
| Z_EWM_C360_OUTBOUND | Específico | MANUAL | 16 | Só reprocessamento manual outbound |
| Z_EWM_C360_SUPPORT | `*` | MANUAL, AUTO | 16 | Reprocessamento manual e automático |
| Z_EWM_C360_ADMIN | `*` | `*` | 16 | Acesso total incluindo BULK |
| Z_EWM_C360_AUDIT | — | — | ❌ | Sem acesso a reprocessamento |

---

## Z_EWM_C360M — Administração e Customizing

| Role | PARAM_GRP | ACTVT | Observação |
|---|---|---|---|
| Z_EWM_C360_EXEC | — | ❌ | Sem acesso |
| Z_EWM_C360_INBOUND | — | ❌ | Sem acesso |
| Z_EWM_C360_OUTBOUND | — | ❌ | Sem acesso |
| Z_EWM_C360_SUPPORT | RULES, KPI, SEVERITY | 03 | Somente leitura de parâmetros |
| Z_EWM_C360_ADMIN | `*` | 01, 02, 03, 06 | Manutenção completa |
| Z_EWM_C360_AUDIT | `*` | 03 | Somente leitura de parâmetros |

---

## Z_EWM_C360L — Consulta de Logs e Auditoria

| Role | LGNUM | LOG_TYPE | ACTVT | Observação |
|---|---|---|---|---|
| Z_EWM_C360_EXEC | `*` | EXCEPTION | 03 | Apenas log de exceções |
| Z_EWM_C360_INBOUND | Específico | ACTION, EXCEPTION | 03 | Logs do próprio warehouse |
| Z_EWM_C360_OUTBOUND | Específico | ACTION, EXCEPTION | 03 | Logs do próprio warehouse |
| Z_EWM_C360_SUPPORT | `*` | ALL | 03 | Todos os logs para diagnóstico |
| Z_EWM_C360_ADMIN | `*` | ALL | 03 | Todos os logs |
| Z_EWM_C360_AUDIT | `*` | ALL | 03 | Todos os logs — função primária |

---

## Matriz de Segregação de Funções (SoD)

Combinações de roles **proibidas** — representam conflito de SoD:

| Combinação | Conflito | Motivo |
|---|---|---|
| ADMIN + AUDIT | ⛔ Proibido | Administrador não pode auditar a si mesmo |
| INBOUND + OUTBOUND | ⚠️ Restringir | Operador não deve ter acesso a dois processos opostos sem justificativa |
| ADMIN + INBOUND/OUTBOUND | ⚠️ Avaliar | Admin com acesso operacional deve ser exceção documentada |
| SUPPORT + ADMIN | ⚠️ Avaliar | Suporte com administração aumenta risco de alteração indevida de parâmetros |

---

## Regras de atribuição

1. Toda atribuição de role deve ser documentada com justificativa no ticket de acesso.
2. LGNUM específico deve ser configurado na role quando o usuário não tiver acesso global.
3. Role AUDIT não pode ser combinada com ADMIN no mesmo usuário.
4. Revisão periódica de acessos: trimestral para ADMIN e SUPPORT.
