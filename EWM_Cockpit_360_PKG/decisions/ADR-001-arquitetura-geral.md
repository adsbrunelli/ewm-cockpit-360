# ADR-001: Arquitetura Geral do Cockpit 360º

## Status

**Aceito** — 2026-06-18 · Decisor: Arquiteto técnico do projeto

## Contexto

O Cockpit 360º precisa combinar visão operacional, analítica, técnica e acionável em SAP EWM. É necessário garantir rastreabilidade, separação de responsabilidades, transporte controlado e evolução incremental por módulo.

## Decisão

Adotar arquitetura em 7 camadas com responsabilidades exclusivas:

| Camada | Responsabilidade |
|---|---|
| DDIC | Persistência, parametrização, snapshots, logs |
| CDS | Exposição semântica, associações, consumo analítico |
| ABAP OO | Cálculo, regra, ação, log, exceção, reprocessamento |
| Serviço | OData/RAP, entities, actions, autorização, mensagens |
| Fiori/FLP | Experiência de usuário, cards, navegação, ações |
| Segurança | Autorização por warehouse, processo, ação e criticidade |
| Operação | Jobs, SLG1, reprocessamento, monitoramento |

Cada camada só pode depender das camadas anteriores. Nenhuma lógica de negócio em CDS. Nenhum acesso direto ao DDIC a partir do Fiori (sempre via serviço).

## Alternativas consideradas

- Arquitetura monolítica em um único programa ABAP: rejeitada por falta de testabilidade e governança.
- RAP puro sem camada CDS separada: rejeitado por dificultar reuso de views em múltiplos serviços.

## Consequências

- Melhor rastreabilidade e auditoria por camada.
- Menor acoplamento — mudança em DDIC não quebra Fiori diretamente.
- Maior governança de transporte — sequência obrigatória por camada.
- Facilidade de evolução por módulo sem impacto cruzado.
- Custo: mais objetos e mais disciplina de desenvolvimento.

## Critérios de revisão

Revisar se nova camada for adicionada (ex: BTP Integration) ou se RAP substituir OData integralmente.
