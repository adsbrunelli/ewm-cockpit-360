# ADR-008: Fiori Elements vs Freestyle UI

## Status

**Aceito** — 2026-06-18 · Decisor: Arquiteto técnico do projeto

## Contexto

O cockpit combina telas de consulta (overview, listas, filtros), telas de detalhe (object pages) e ações operacionais (botões, confirmações, reprocessamento). Fiori Elements gera UI automaticamente via annotations CDS, com menos código e maior padronização. Freestyle oferece controle total do layout mas exige mais desenvolvimento e manutenção.

## Decisão

### Usar Fiori Elements quando:

| Padrão Fiori Elements | Cenário no Cockpit |
|---|---|
| Overview Page (OVP) com cards | Dashboard principal — cards de KPI, exceções, volume por processo |
| List Report + Object Page | Telas de Inbound, Outbound, HU, WT, Exceptions, Action Log |
| Analytical List Page (ALP) | Visão KPI com gráfico + lista filtrada |
| Value Help via CDS | Filtros de LGNUM, PROCESS_TYPE, SEVERITY |

**Annotations CDS são suficientes** para: filtros, colunas, navegação entre páginas, botões de ação padrão, criticality highlighting, DataPoint para KPIs.

### Usar Freestyle apenas quando:

1. **Ação em massa com lógica de seleção complexa** que annotations não suportam (ex: selecionar múltiplas exceções com critérios cruzados e confirmar em lote).
2. **Layout de cockpit com múltiplos painéis simultâneos** que OVP não comporta nativamente.
3. **Visualização gráfica custom** (ex: mapa de armazém, Gantt de tasks) sem equivalente em Fiori Elements.

### Regra de decisão

> "Se a tela pode ser descrita integralmente por annotations CDS (`@UI`, `@Search`, `@Analytics`), use Fiori Elements. Se requer comportamento de UX que annotations não expressam, use Freestyle."

## Alternativas consideradas

- **Freestyle puro:** rejeitado por custo de manutenção, falta de padronização SAP Fiori e necessidade de redesenvolvimento a cada upgrade.
- **Fiori Elements puro:** rejeitado porque ações operacionais críticas e layouts de cockpit composto exigem extensibilidade que Fiori Elements padrão não cobre.

## Consequências

- Maioria das telas (estimativa: 70-80%) entregue via Fiori Elements — menor custo de desenvolvimento.
- Annotations CDS tornam-se documentação viva da UI — alinhamento entre backend e frontend.
- Extensões freestyle limitadas a casos justificados — menor superfície de manutenção.
- Custo: decisão sobre cada nova tela deve ser documentada no objeto correspondente em ZTEWM_C360_UI_MAP.

## Critérios de revisão

Revisar se SAP introduzir novos padrões Fiori Elements que cubram cenários hoje classificados como freestyle.
