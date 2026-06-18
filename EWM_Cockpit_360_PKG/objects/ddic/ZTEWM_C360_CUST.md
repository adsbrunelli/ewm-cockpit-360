# ZTEWM_C360_CUST

## Finalidade

Customizing do cockpit.

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
| PARAM_KEY | CHAR | CHAR | 30 | X | X | Chave do Parâmetro de Customizing |
| LGNUM | ZDEWM_C360_E_LGNUM | CHAR | 4 | X | X | Warehouse (ou '*' para todos) |
| PARAM_VALUE | CHAR | CHAR | 100 | | X | Valor do Parâmetro |
| PARAM_TYPE | CHAR | CHAR | 10 | | X | Tipo: STRING, NUMBER, FLAG, DATE |
| DESCRIPTION | CHAR | CHAR | 80 | | X | Descrição do Parâmetro |
| ACTIVE_FLAG | ZDEWM_C360_E_FLAG | CHAR | 1 | | X | Parâmetro Ativo |
| CREATED_BY | UNAME | CHAR | 12 | | X | Criado por |
| CREATED_AT | TIMESTAMP | DEC | 15 | | X | Criado em (UTC) |
| CHANGED_BY | UNAME | CHAR | 12 | | | Alterado por |
| CHANGED_AT | TIMESTAMP | DEC | 15 | | | Alterado em (UTC) |

## Chave primária

`MANDT + PARAM_KEY + LGNUM`

## Exemplos de parâmetros iniciais

| PARAM_KEY | Descrição | Exemplo |
|---|---|---|
| SNAP_DELTA_MINUTES | Intervalo delta snapshot em minutos | 15 |
| KPI_REFRESH_MINUTES | Frequência de recálculo de KPI | 60 |
| ACTLOG_RETENTION_DAYS | Retenção do action log em dias | 365 |
| DEFAULT_SLA_HOURS | SLA padrão quando regra não encontrada | 4 |
| COCKPIT_ACTIVE | Cockpit habilitado para o warehouse | X |

## Dependências

- Classes: ZCL_EWM_C360_KPI_ENGINE, ZCL_EWM_C360_SNAPSHOT_RUNNER (leem desta tabela)
- Manutenção: SM30 para administradores
- Transporte: request de customizing separado

## Critérios de aceite

- Tabela ativa com SM30 configurado.
- Resolução LGNUM específico → LGNUM='*' implementada nas classes.
- Parâmetros iniciais transportados via request de customizing.
- Sequência de transporte: após DDIC, antes dos jobs.
