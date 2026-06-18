# Acceptance Criteria: EWM Cockpit 360º

## Critérios gerais

- O cockpit apresenta dados por warehouse.
- Filtros principais funcionam com performance aceitável.
- KPIs possuem origem, fórmula, owner e tolerância.
- Exceções possuem severidade, SLA e status.
- Ações executadas via UI gravam log técnico e funcional.
- Acesso é controlado por role e autorização.
- Jobs de snapshot possuem controle de execução, lock e erro.
- Reprocessamento possui rastreabilidade.
- Dependências técnicas estão documentadas.
- Transportes respeitam sequência validada.

## Critérios técnicos

- Tabelas ativas no DDIC.
- CDS ativadas sem erro.
- Serviços publicados e testáveis.
- Classes com responsabilidade única.
- Logs consultáveis via SLG1 ou tabela de action log.
- Sem hardcode de regras operacionais.
- Testes unitários para engines críticas.
- Testes integrados para cenários inbound, outbound, HU, WT, exceptions e KPI.

## Critérios de segurança

- Botões críticos exigem autorização.
- Acesso restrito por warehouse quando aplicável.
- Ações administrativas separadas de ações operacionais.
- Auditoria não pode ser alterada por usuário operacional.

## Validação final

Todos os critérios acima devem ser verificados e aprovados antes de qualquer transporte para produção. A validação é de responsabilidade conjunta do arquiteto técnico e do líder funcional do projeto.
