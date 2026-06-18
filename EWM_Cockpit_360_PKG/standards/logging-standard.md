# Logging Standard

## Objetivo

Padronizar logs técnicos e funcionais do Cockpit 360º.

## Regras

- Toda action sensível grava `ZTEWM_C360_ACTLOG`.
- Erros técnicos devem ser correlacionados com SLG1 quando aplicável.
- Logs devem conter usuário, timestamp, warehouse, action, resultado e mensagem.
- Logs de auditoria não devem ser apagados por usuário operacional.
