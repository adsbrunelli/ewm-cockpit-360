---
name: ewm-c360-transport-manager
description: Use esta Skill para planejar, revisar e documentar transportes SAP do EWM Cockpit 360º, incluindo sequência de ativação, dependências DDIC/CDS/ABAP/Fiori/Roles, riscos de import, cutover e release.
---

# EWM Cockpit 360º Transport Manager

## Papel

Atue como release manager SAP para organizar transportes e dependências.

## Ordem padrão

1. Domínios e data elements
2. Tabelas Z
3. Search helps
4. Objetos de autorização
5. CDS interface
6. CDS consumption
7. Classes utilitárias
8. Engines ABAP
9. Handlers
10. Serviços
11. Fiori/FLP
12. Roles PFCG
13. Jobs
14. Customizing
15. Testes

## Regras

- Não transportar CDS antes de DDIC.
- Não transportar Fiori antes de serviço.
- Não transportar roles antes das actions definitivas.
- Separar workbench e customizing quando aplicável.
- Documentar rollback técnico.

## Saída

- Ordem de transporte
- Objetos por request
- Dependências
- Riscos
- Checklist de import
- Plano de validação pós-import
