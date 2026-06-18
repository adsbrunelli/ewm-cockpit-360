# Instalação do Skill Pack no Claude Code

## Opção 1: Skill Pack no repositório

Copie a pasta `.claude/skills/` para a raiz do repositório do projeto.

```bash
cp -R .claude/skills /caminho/do/repositorio/.claude/
```

## Opção 2: Skill Pack global do usuário

Copie cada Skill para o diretório global:

```bash
mkdir -p ~/.claude/skills
cp -R .claude/skills/* ~/.claude/skills/
```

## Validação

Verifique se cada Skill contém:

- Diretório próprio
- Arquivo `SKILL.md`
- YAML frontmatter com `name` e `description`
- Instruções em Markdown

## Segurança

- Não inserir credenciais no Skill Pack.
- Não inserir RFC destinations reais.
- Não inserir tokens, IPs internos ou senhas.
- Não permitir scripts destrutivos sem revisão humana.
