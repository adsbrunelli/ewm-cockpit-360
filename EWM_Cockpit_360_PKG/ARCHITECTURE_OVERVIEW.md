# Architecture Overview: EWM Cockpit 360º Dashboard

## Visão arquitetural

O Cockpit 360º deve ser estruturado em camadas para preservar governança, rastreabilidade, performance e evolução incremental.

## Camadas

### 1. DDIC

Responsável por persistência, parametrização, snapshots, logs, matriz de severidade, definição de KPIs, mapeamento UI e dependências técnicas.

Objetos principais:

- `ZTEWM_C360_HDR`
- `ZTEWM_C360_ITEM`
- `ZTEWM_C360_EXC`
- `ZTEWM_C360_KPI`
- `ZTEWM_C360_ACTLOG`
- `ZTEWM_C360_RULE`
- `ZTEWM_C360_SNAP_CTL`
- `ZTEWM_C360_SEV_RULE`
- `ZTEWM_C360_KPI_DEF`
- `ZTEWM_C360_ACTION`
- `ZTEWM_C360_CUST`
- `ZTEWM_C360_DEP`
- `ZTEWM_C360_INTEG_CFG`
- `ZTEWM_C360_UI_MAP`

### 2. CDS

Responsável por exposição semântica dos dados, associações, consumo analítico e integração com Fiori.

Padrão:

- Interface views: `ZI_EWM_C360_*`
- Consumption views: `ZC_EWM_C360_*`
- Value helps: `ZI_EWM_C360_VH_*`
- Analytical views: `ZC_EWM_C360_ANA_*`

### 3. ABAP OO

Responsável por cálculo, regra, leitura, ação, log, exceção e reprocessamento.

Padrão:

- `ZCL_EWM_C360_READER_*`
- `ZCL_EWM_C360_KPI_*`
- `ZCL_EWM_C360_EXC_*`
- `ZCL_EWM_C360_ACTION_*`
- `ZCL_EWM_C360_LOG_*`
- `ZCL_EWM_C360_REPROC_*`
- `ZCL_EWM_C360_AUTH_*`

### 4. Serviço

Responsável por exposição via OData V2/V4 ou RAP.

Componentes:

- Entidades de leitura
- Actions
- Value helps
- Mensagens padronizadas
- Controle de autorização
- Logging técnico

### 5. Fiori/FLP

Responsável pela experiência de usuário.

Componentes:

- Overview Page
- Cards analíticos
- List Reports
- Object Pages
- Botões de ação
- Navegação por semantic object/action
- Extensões UI quando necessário

### 6. Segurança

Responsável por autorização por warehouse, processo, ação e criticidade.

Padrão:

- Role executiva
- Role operação inbound
- Role operação outbound
- Role suporte técnico
- Role administração do cockpit
- Role auditoria

### 7. Operação

Responsável por execução, monitoramento e suporte.

Componentes:

- Jobs de snapshot
- SLG1
- Reprocessing
- qRFC/SMQ2, quando aplicável
- Monitoramento de integrações
- Métricas de erro e tempo de processamento

## Fluxo lógico

1. Dados operacionais são lidos de fontes SAP EWM standard.
2. Dados críticos ou agregados podem ser persistidos em snapshots.
3. Regras parametrizadas classificam exceções e severidade.
4. KPIs são calculados com fórmula e tolerância.
5. CDS expõe dados semânticos para Fiori.
6. Fiori apresenta cockpit e ações.
7. Actions chamam handlers ABAP.
8. Handlers validam autorização, executam ação e gravam log.
9. Jobs e framework de reprocessamento tratam falhas controladas.

## Decisão inicial recomendada

Usar CDS + Fiori Elements para leitura, filtros e object pages sempre que possível. Usar extensões Fiori ou freestyle somente quando ações, layout ou interação exigirem comportamento não atendido por annotations CDS.
