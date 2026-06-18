# ADR-001: Arquitetura Geral do Cockpit 360º

## Status

Proposta

## Contexto

O Cockpit 360º precisa combinar visão operacional, analítica, técnica e acionável em SAP EWM.

## Decisão

Adotar arquitetura em camadas: DDIC, CDS, ABAP OO, Serviço, Fiori, Segurança e Operação.

## Consequências

- Melhor rastreabilidade.
- Menor acoplamento.
- Maior governança de transporte.
- Facilidade de evolução por módulo.
