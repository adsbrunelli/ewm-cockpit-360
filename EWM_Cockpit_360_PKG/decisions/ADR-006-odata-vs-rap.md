# ADR-006: Protocolo de Serviço — OData V2, OData V4 ou RAP

## Status

**Aceito** — 2026-06-18 · Decisor: Arquiteto técnico do projeto

## Contexto

O cockpit expõe dados e ações via serviços consumidos pelo Fiori. A escolha do protocolo afeta: compatibilidade com a versão do sistema SAP, suporte a Fiori Elements, capacidade de definir actions/functions e esforço de desenvolvimento. As três opções disponíveis são OData V2, OData V4 e RAP (RESTful ABAP Programming Model).

## Decisão

**Adotar OData V2 como protocolo principal**, com abertura para RAP em módulos novos se o sistema suportar ABAP 7.57+.

| Cenário | Protocolo | Motivo |
|---|---|---|
| Leitura de dados (cockpit, lists, cards) | OData V2 | Compatibilidade ampla, Fiori Elements List Report e OVP |
| Actions críticas (reprocessamento, ações operacionais) | OData V2 Function Import | Controle explícito de autorização e log no handler ABAP |
| Módulos novos em sistemas ABAP 7.57+ | RAP (OData V4) | Draft handling, EML, aproveitamento de CDS nativamente |

**Regra de convivência:** um mesmo serviço não mistura V2 e V4. Módulos V2 e RAP coexistem no FLP via diferentes semantic objects — sem dependência cruzada de protocolo.

## Alternativas consideradas

- **OData V4 puro:** rejeitado por exigir ABAP 7.57+ e RAP, que pode não estar disponível no sistema alvo.
- **RAP puro:** rejeitado pelo mesmo motivo — a versão do sistema SAP EWM não foi confirmada como ≥7.57.
- **OData V2 puro:** aceito como padrão seguro, com revisão por módulo conforme versão disponível.

## Consequências

- Desenvolvimento V2 usa SEGW + classe de DPC_EXT para handlers — padrão bem conhecido.
- Actions críticas implementadas como Function Imports com autorização e log explícitos.
- Módulos RAP podem ser introduzidos incrementalmente sem reescrever os V2 existentes.
- Custo: SEGW tem mais overhead que RAP para manutenção — aceito para garantir compatibilidade.

## Critérios de revisão

Revisar quando a versão do sistema SAP for confirmada como ABAP 7.57+. Considerar migração gradual para RAP nos módulos de maior evolução futura.
