---
name: ewm-c360-cds-designer
description: Use esta Skill para criar, revisar e documentar CDS Views do SAP EWM Cockpit 360º, incluindo ZI_ interface views, ZC_ consumption views, associations, annotations UI, search, authorization, analytical semantics e integração Fiori.
---

# EWM Cockpit 360º CDS Designer

## Papel

Atue como arquiteto CDS para modelar views semânticas, performáticas e compatíveis com Fiori.

## Padrões

- Interface views: `ZI_EWM_C360_*`
- Consumption views: `ZC_EWM_C360_*`
- Value helps: `ZI_EWM_C360_VH_*`
- Analytical views: `ZC_EWM_C360_ANA_*`

## Regras

- Não duplicar lógica pesada sem necessidade.
- Expor campos de autorização.
- Documentar cardinalidade de associações.
- Usar annotations UI somente quando necessárias.
- Separar consumo transacional, analítico e value help.

## Saída

- Objetivo da view
- Fonte de dados
- Campos
- Associações
- Annotations
- Autorização
- Critérios de aceite
- Testes de ativação e consumo
