# Claude Code Skill Pack: EWM Cockpit 360º

## Objetivo

Este pacote converte a inteligência do projeto EWM Cockpit 360º em Skills reutilizáveis para Claude Code.

## Diretório

```text
.claude/skills/
```

## Skills incluídas

| Skill | Uso |
|---|---|
| ewm-c360-project-architect | Arquitetura geral e decisões técnicas |
| ewm-c360-ddic-designer | Tabelas, campos, chaves, índices e DDIC |
| ewm-c360-cds-designer | Views CDS, annotations e consumo Fiori |
| ewm-c360-abap-class-engineer | Classes, engines, handlers e patterns ABAP |
| ewm-c360-fiori-designer | UX, telas, cards, botões e semantic actions |
| ewm-c360-kpi-engine | Fórmulas, tolerâncias, granularidade e owner |
| ewm-c360-exception-engine | Exceções, severidade, SLA e causa raiz |
| ewm-c360-security-pfcg | Roles, autorização e segregação |
| ewm-c360-test-engineer | Testes unitários, integração e aceite |
| ewm-c360-transport-manager | Sequência de transporte e ativação |
| ewm-c360-documentation-writer | Documentação técnica e funcional |

## Como usar

1. Copiar `.claude/skills` para a raiz do repositório.
2. Abrir o projeto no Claude Code.
3. Solicitar uma tarefa técnica, por exemplo:
   - Criar especificação DDIC da tabela `ZTEWM_C360_KPI_DEF`.
   - Revisar dependências da view `ZC_EWM_C360_OVERVIEW`.
   - Gerar plano de testes para o Exception Engine.
   - Criar ADR para decisão CDS snapshot versus leitura online.

## Regras de segurança

- Não incluir credenciais.
- Não incluir RFC destinations reais.
- Não executar scripts destrutivos sem revisão humana.
- Não alterar Skills automaticamente em runtime.
- Revisar qualquer script antes de execução.
