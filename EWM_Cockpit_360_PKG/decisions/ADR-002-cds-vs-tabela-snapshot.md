# ADR-002: CDS Online versus Tabela Snapshot

## Status

Proposta

## Contexto

Alguns dados podem ser lidos online via CDS. Outros exigem persistência por performance, histórico ou reprocessamento.

## Decisão

Usar leitura online para dados voláteis e de detalhe. Usar snapshots para KPIs, aging, agregações, histórico e diagnósticos de alto custo.

## Consequências

- Redução de carga em consultas pesadas.
- Maior rastreabilidade histórica.
- Necessidade de jobs e controle de delta.
