# EWM Cockpit 360º Dashboard

## Objetivo

O EWM Cockpit 360º Dashboard é um cockpit operacional, técnico e executivo para SAP Extended Warehouse Management, desenhado para consolidar visão 360º dos processos críticos de armazém, exceções, KPIs, logs, reprocessamentos, ações Fiori, diagnósticos técnicos e dependências entre objetos SAP.

Este repositório organiza a inteligência do projeto em documentação técnica, matrizes de controle e Skills para Claude Code.

## Estrutura

```text
.claude/skills/       Skills especializadas para Claude Code
docs/                 Documentação funcional, técnica e operacional
objects/              Catálogo técnico por tipo de objeto SAP
standards/            Padrões obrigatórios do projeto
decisions/            ADRs, decisões arquiteturais
tests/                Estratégia e cenários de teste
scripts/              Scripts auxiliares revisáveis
```

## Escopo macro

- Overview operacional por warehouse
- Inbound
- Outbound
- Handling Unit Management
- Warehouse Tasks
- Exceptions
- KPIs
- Reprocessing
- Action Log
- Diagnostic Cockpit
- Integrações
- Segurança e autorização
- Logs técnicos e funcionais
- Sequência de transporte e ativação

## Princípios técnicos

1. Regras parametrizáveis sem hardcode.
2. KPIs com fórmula, origem, granularidade, tolerância e owner.
3. Exceções com tipo, severidade, SLA, impacto e causa raiz.
4. Ações Fiori com handler, autorização e log.
5. Dependências técnicas documentadas antes de transporte.
6. Separação clara entre DDIC, CDS, ABAP OO, Service, Fiori, Security e Operação.
7. Documentação orientada a execução por Claude Code.

## Como instalar as Skills no Claude Code

Copie o diretório `.claude/skills/` para a raiz do repositório do projeto ou copie cada Skill para o diretório global do usuário:

```bash
~/.claude/skills/
```

Cada Skill contém um arquivo `SKILL.md` com metadados e instruções específicas.
