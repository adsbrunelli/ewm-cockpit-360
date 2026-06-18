# ZTEWM_C360_INTEG_CFG

## Finalidade

Configuração e monitoramento lógico de integrações.

## Camada

DDIC

## Status

Planejado

## Status

Especificado

## Campos

| Campo | Data Element | Tipo | Compr. | K | Obrig. | Descrição |
|---|---|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | X | X | Mandante |
| INTEG_ID | ZDEWM_C360_E_RULE_ID | CHAR | 20 | X | X | ID da Integração |
| LGNUM | ZDEWM_C360_E_LGNUM | CHAR | 4 | X | X | Warehouse (ou '*' para todos) |
| INTEG_TYPE | CHAR | CHAR | 20 | | X | Tipo: RFC, IDOC, BAPI, REST, ODATA |
| INTEG_NAME | CHAR | CHAR | 60 | | X | Nome funcional da integração |
| ENDPOINT | CHAR | CHAR | 100 | | | Destino RFC ou URL (sem credenciais) |
| ACTIVE_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Integração Ativa |
| MONITOR_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | | Monitorada pelo cockpit |
| LAST_STATUS | ZDEWM_C360_E_STATUS | CHAR | 4 | | | Último Status Verificado |
| LAST_CHECK_AT | TIMESTAMP | DEC | 15 | | | Última Verificação (UTC) |
| ERROR_COUNT | ZDEWM_C360_E_COUNTER | INT4 | 4 | | | Contagem de Erros Consecutivos |
| ERROR_THRESHOLD | ZDEWM_C360_E_COUNTER | INT4 | 4 | | | Limite de Erros para Alerta |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + INTEG_ID + LGNUM`

## Índices secundários

| Índice | Campos | Justificativa |
|---|---|---|
| Z01 | LGNUM + MONITOR_FLAG + LAST_STATUS | Monitoramento de integrações com erro |

## Regra de segurança

ENDPOINT não deve conter senhas, tokens ou chaves de API. Credenciais ficam em SM59 (RFC destinations) ou SCP Destinations — apenas o nome do destino é armazenado aqui.

## Dependências

- Classes: ZCL_EWM_C360_READER_* (leem via RFC/BAPI)
- Manutenção: SM30 para administradores
- Diagnóstico: exibido no Diagnostic Cockpit

## Critérios de aceite

- Tabela ativa.
- Nenhum campo contém credenciais.
- Integração com MONITOR_FLAG = 'X' é exibida no Diagnostic Cockpit.
- ERROR_COUNT incrementado automaticamente por job de health-check.
- Sequência de transporte: customizing separado.
