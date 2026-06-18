# EWM Cockpit 360º — Checklist de Aceite com Key Users

## Objetivo

Validação funcional com operação real em ambiente QAS antes da promoção para PRD.
Executar com participação de: Supervisor de Armazém, Analista de Logística, Auditor.

---

## Bloco 1 — Visão Geral (OVP)

| # | Critério | Executado por | Status | Observação |
|---|----------|---------------|--------|------------|
| 1.1 | Ao abrir o cockpit, vejo cards com dados do meu warehouse sem precisar configurar nada | Supervisor | ☐ | |
| 1.2 | Consigo identificar de imediato quantas exceções críticas estão abertas | Supervisor | ☐ | |
| 1.3 | Os KPIs exibem cores vermelha/amarela/verde de acordo com a meta configurada | Supervisor | ☐ | |
| 1.4 | Ao clicar em um card, sou direcionado para o app detalhado correspondente | Supervisor | ☐ | |
| 1.5 | O tile no Launchpad mostra o número de exceções críticas e muda de cor | Supervisor | ☐ | |

---

## Bloco 2 — Monitor Inbound

| # | Critério | Executado por | Status | Observação |
|---|----------|---------------|--------|------------|
| 2.1 | Consigo filtrar documentos inbound por status e data de abertura | Analista | ☐ | |
| 2.2 | Documentos com exceção aparecem destacados (cor diferenciada) | Analista | ☐ | |
| 2.3 | Ao clicar num documento, vejo itens, exceções e histórico de ações | Analista | ☐ | |
| 2.4 | A coluna "Aging" mostra quantos dias o documento está aberto | Analista | ☐ | |
| 2.5 | Consigo exportar a lista para Excel com todos os filtros aplicados | Analista | ☐ | |

---

## Bloco 3 — Painel de Exceções

| # | Critério | Executado por | Status | Observação |
|---|----------|---------------|--------|------------|
| 3.1 | As exceções aparecem ordenadas: mais críticas e com SLA mais próximo do vencimento primeiro | Supervisor | ☐ | |
| 3.2 | Consigo filtrar por severidade (CRITICAL, HIGH, MEDIUM, LOW) | Supervisor | ☐ | |
| 3.3 | Exceções com SLA vencido aparecem com indicador vermelho "VENCIDO" | Supervisor | ☐ | |
| 3.4 | Consigo resolver uma exceção preenchendo o motivo e confirmando | Analista | ☐ | |
| 3.5 | Após resolver, a exceção some da lista automaticamente | Analista | ☐ | |
| 3.6 | O histórico de ações mostra quem resolveu e quando | Analista | ☐ | |
| 3.7 | Usuário sem permissão vê o botão "Resolver" desabilitado (não oculto) | Supervisor | ☐ | |

---

## Bloco 4 — Dashboard de KPIs

| # | Critério | Executado por | Status | Observação |
|---|----------|---------------|--------|------------|
| 4.1 | Consigo ver KPIs por processo (Inbound, Outbound, etc.) | Supervisor | ☐ | |
| 4.2 | KPIs abaixo da meta aparecem em vermelho com o percentual de desvio | Supervisor | ☐ | |
| 4.3 | Ao abrir um KPI, vejo o histórico em gráfico com a linha de meta | Analista | ☐ | |
| 4.4 | Consigo selecionar granularidade (dia, semana, mês) e a lista atualiza | Analista | ☐ | |
| 4.5 | A fórmula de cálculo do KPI está documentada e visível na tela | Analista | ☐ | |

---

## Bloco 5 — Reprocessamento

| # | Critério | Executado por | Status | Observação |
|---|----------|---------------|--------|------------|
| 5.1 | Documentos elegíveis para reprocessamento têm o botão "Reprocessar" habilitado | Analista | ☐ | |
| 5.2 | Documentos com 3 tentativas esgotadas têm o botão desabilitado | Analista | ☐ | |
| 5.3 | Após reprocessamento, o resultado aparece no Log de Ações | Analista | ☐ | |
| 5.4 | Em caso de falha, a mensagem de erro é clara e não técnica | Supervisor | ☐ | |

---

## Bloco 6 — Segurança e Auditoria

| # | Critério | Executado por | Status | Observação |
|---|----------|---------------|--------|------------|
| 6.1 | Usuário de inbound não consegue ver dados de outbound | Auditor | ☐ | |
| 6.2 | Usuário de WH01 não consegue ver dados de WH02 | Auditor | ☐ | |
| 6.3 | Toda ação (resolução, reprocessamento, recálculo) gera entrada no log de auditoria | Auditor | ☐ | |
| 6.4 | O log de auditoria não pode ser deletado pelo usuário operacional | Auditor | ☐ | |
| 6.5 | Auditor consegue consultar o log completo sem poder executar ações | Auditor | ☐ | |

---

## Bloco 7 — Performance

| # | Critério | Executado por | Status | Observação |
|---|----------|---------------|--------|------------|
| 7.1 | Overview Page carrega em menos de 3 segundos | Supervisor | ☐ | Medir via Network tab |
| 7.2 | List Report com 1.000 registros carrega em menos de 5 segundos | Analista | ☐ | |
| 7.3 | Troca de filtro Lgnum não causa reload lento (> 10 segundos) | Supervisor | ☐ | |
| 7.4 | Snapshot delta (15 min) conclui em menos de 2 minutos | Analista TI | ☐ | Verificar SM37 |

---

## Assinaturas de aceite

| Papel | Nome | Data | Assinatura |
|-------|------|------|------------|
| Supervisor de Armazém | | | |
| Analista de Logística | | | |
| Auditor | | | |
| Líder Técnico SAP | | | |
| Gerente de Projeto | | | |

---

## Critérios de bloqueio para GO-LIVE

Os itens abaixo impedem a promoção para PRD se não estiverem verdes:

- **3.4** — Resolução de exceções funcionando
- **5.1** — Reprocessamento habilitado para documentos elegíveis
- **6.1 a 6.4** — Todos os critérios de segurança
- **7.1** — OVP carregando em < 3 segundos
- **Todos os critérios do Bloco 6** — Auditoria completa
