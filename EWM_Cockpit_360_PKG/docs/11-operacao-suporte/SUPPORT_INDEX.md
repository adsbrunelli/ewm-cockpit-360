# EWM Cockpit 360º — Índice de Runbooks e Suporte

## Runbooks disponíveis

| Runbook | Quando usar |
|---------|-------------|
| [RUNBOOK_SNAPSHOT.md](./RUNBOOK_SNAPSHOT.md) | Job de snapshot travado, lock não liberado, dados desatualizados |
| [RUNBOOK_EXCEPTION_STUCK.md](./RUNBOOK_EXCEPTION_STUCK.md) | Exceção não resolve, botão desabilitado, RETRY esgotado |
| [RUNBOOK_KPI_DEVIATION.md](./RUNBOOK_KPI_DEVIATION.md) | KPI zerado, valor incorreto, não atualiza |
| [RUNBOOK_FIORI_ERROR.md](./RUNBOOK_FIORI_ERROR.md) | Tela branca, service unavailable, ação com erro |

## Níveis de suporte

| Nível | Quem | O que resolve |
|-------|------|---------------|
| N1 | Supervisor / Operação | Verificar filtros, limpar lock via SM30, atribuir owner |
| N2 | Analista SAP / Suporte TI | Verificar autorização, reagendar job, forçar recálculo |
| N3 | Desenvolvedor ABAP | Investigar dump, corrigir bug em classe, reimportar request |
| N4 | Basis | Problemas de workprocess, certificado, conectividade |

## Monitoramento diário (checklist N1)

```
[ ] SM37 → jobs ZEWM_C360_SNAPSHOT* → nenhum em "Released" há mais de 5 min
[ ] SM37 → job ZEWM_C360_RETRY → executou na última hora sem erro
[ ] SE16 → ZTEWM_C360_SNAP_CTL → LOCK_FLAG='' para todos os warehouses
[ ] Overview Page → tile dinâmico atualizado (data/hora recente)
[ ] Painel de Exceções → nenhuma exceção CRITICAL com SLA vencido há mais de 1 turno
```

## Janelas de manutenção recomendadas

| Atividade | Quando | Duração |
|-----------|--------|---------|
| Import de request WorkBench | Fora do horário de pico (preferencialmente madrugada) | 30-60 min |
| Import de request Customizing | Qualquer hora (sem restart) | 5-15 min |
| Recálculo de índice Fiori | Fora do horário de pico | 5-10 min |
| Snapshot FULL diário | 02:00 (configurado no job) | 15-30 min |
| Limpeza de ACTLOG (retenção 12 meses) | Mensal, madrugada | 60+ min |

## Parâmetros operacionais (ZTEWM_C360_CUST)

| Chave | Valor padrão | O que controla |
|-------|-------------|----------------|
| `SNAP_DELTA_MINUTES` | 15 | Frequência do snapshot delta |
| `MAX_RETRY` | 3 | Máximo de tentativas de reprocessamento |
| `WT_AGING_WARN_DAYS` | 2 | Dias de aging para alertar WT em atraso |
| `KPI_HISTORY_POINTS` | 30 | Pontos no gráfico histórico de KPI |

Para alterar: `SM30 → ZTEWM_C360_CUST → editar valor → salvar`  
Alterações entram em vigor no próximo ciclo do job (sem restart necessário).
