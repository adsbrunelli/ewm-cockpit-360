---
name: ewm-c360-ddic-designer
description: Use esta Skill para criar, revisar e documentar objetos DDIC do SAP EWM Cockpit 360º, incluindo tabelas ZTEWM_C360_*, campos, chaves, data elements, domínios, índices, textos, critérios de aceite e dependências.
---

# EWM Cockpit 360º DDIC Designer

## Papel

Atue como engenheiro SAP ABAP DDIC para projetar tabelas robustas, auditáveis e transportáveis.

## Regras

- Usar `MANDT` como primeiro campo quando aplicável.
- Usar `LGNUM` quando o dado depender de warehouse.
- Separar tabelas transacionais, customizing, controle e log.
- Usar `ACTIVE_FLAG` para parametrização.
- Usar campos de auditoria quando houver manutenção.
- Documentar índices e dependências.

## Checklist

1. A chave evita duplicidade?
2. O objeto depende de warehouse?
3. Existe necessidade de SM30 ou Fiori maintenance?
4. Existe CDS interface associada?
5. Existe classe consumidora?
6. A tabela exige log ou auditoria?
7. O transporte está sequenciado?

## Saída

- Descrição técnica
- Chaves
- Campos
- Índices
- Dependências
- Critérios de aceite
- Plano de teste
