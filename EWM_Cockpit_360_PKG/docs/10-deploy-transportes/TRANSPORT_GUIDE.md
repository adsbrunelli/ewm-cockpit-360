# Guia de Transporte — EWM Cockpit 360º

## Visão geral

O projeto é transportado em **15 waves** sequenciais. Cada wave depende da anterior
estar **importada e ativada** antes de prosseguir. Nunca agrupar waves diferentes em
um único request quando houver dependência de ativação entre elas.

---

## Waves de transporte

### Wave 1 — Domínios e Data Elements

**Pré-condição**: nenhuma  
**Objetos**:
- Domínios: `ZDEWM_C360_*` (21 domínios)
- Data elements: `ZDEWM_C360_E_*` (21 data elements)

**Validação pós-import**:
```
SE11 → ZDEWM_C360_LGNUM → Status: Ativo
SE11 → ZDEWM_C360_E_DOC_ID → Status: Ativo
```

---

### Wave 2 — Tabelas DDIC

**Pré-condição**: Wave 1 importada e ativada  
**Objetos** (ordem de import não importa dentro da wave):
- `ZTEWM_C360_HDR`, `ZTEWM_C360_ITEM`, `ZTEWM_C360_EXC`, `ZTEWM_C360_KPI`
- `ZTEWM_C360_ACTLOG`, `ZTEWM_C360_RULE`, `ZTEWM_C360_SNAP_CTL`
- `ZTEWM_C360_SEV_RULE`, `ZTEWM_C360_KPI_DEF`, `ZTEWM_C360_ACTION`
- `ZTEWM_C360_CUST`, `ZTEWM_C360_DEP`, `ZTEWM_C360_INTEG_CFG`, `ZTEWM_C360_UI_MAP`

**Validação pós-import**:
```
SE16 → ZTEWM_C360_HDR → estrutura criada (0 registros esperado)
SM30 → ZTEWM_C360_CUST → manutenção abre sem erro
```

**Atenção**: Se tabela já existir em PRD com dados, verificar se novos campos têm `DEFAULT`
definido. Jamais transportar `ALTER TABLE` que possa travar linhas.

---

### Wave 3 — Objetos de Autorização

**Pré-condição**: Wave 2 importada  
**Objetos**:
- `Z_EWM_C360A` — Acesso ao cockpit por processo e LGNUM
- `Z_EWM_C360P` — Manutenção de parâmetros
- `Z_EWM_C360R` — Reprocessamento
- `Z_EWM_C360L` — Consulta de logs

**Criação**: Authorization objects são criados via **SU21** (não via request de transporte
padrão). Transportar via request do tipo `Workbench` gerada pelo SU21.

**Validação pós-import**:
```
SU21 → Z_EWM_C360A → campos LGNUM, PROCESS, ACTVT visíveis
```

---

### Wave 4 — Classe de Exceção Base e Interfaces ABAP

**Pré-condição**: Waves 1–3 importadas  
**Objetos**:
- `ZCX_EWM_C360_BASE` e subclasses (6 total)
- `ZIF_EWM_C360_AUTH_CHECKER`
- `ZIF_EWM_C360_LOG_WRITER`
- `ZIF_EWM_C360_KPI_ENGINE`
- `ZIF_EWM_C360_EXCEPTION_ENGINE`
- `ZIF_EWM_C360_ACTION_HANDLER`
- `ZIF_EWM_C360_REPROCESSOR`
- `ZIF_EWM_C360_SNAPSHOT_RUNNER`

**Validação pós-import**:
```
SE24 → ZIF_EWM_C360_AUTH_CHECKER → Status: Ativo
SE24 → ZCX_EWM_C360_BASE → herança de CX_STATIC_CHECK visível
```

---

### Wave 5 — Classes de Implementação (utilitárias)

**Pré-condição**: Wave 4 importada  
**Objetos**:
- `ZCL_EWM_C360_AUTH`
- `ZCL_EWM_C360_LOG`

**Validação pós-import**:
```
SE24 → ZCL_EWM_C360_AUTH → implementa ZIF_EWM_C360_AUTH_CHECKER: Sim
SE24 → ZCL_EWM_C360_LOG → implementa ZIF_EWM_C360_LOG_WRITER: Sim
```

---

### Wave 6 — Classes de Negócio (engines)

**Pré-condição**: Wave 5 importada  
**Objetos**:
- `ZCL_EWM_C360_FACTORY` — factory de componentes (instanciar antes das engines)
- `ZCL_EWM_C360_KPI_ENGINE`
- `ZCL_EWM_C360_EXCEPTION_ENGINE`
- `ZCL_EWM_C360_REPROCESSOR`
- `ZCL_EWM_C360_SNAPSHOT_RUNNER`
- `ZCL_EWM_C360_ACTION_DISPATCHER`
- `ZCL_EWM_C360_DEPENDENCY_CHECK` — validação de pré-requisitos de deploy (DEP-01)
- `ZEWM_C360_WATCHDOG_JOB` — programa do job de watchdog de lock (DDI-02)

**Validação pós-import**:
```
SE24 → ZCL_EWM_C360_FACTORY → sintaxe OK, métodos GET_* visíveis
SE24 → ZCL_EWM_C360_KPI_ENGINE → sintaxe OK (ativar e verificar)
SE38 → ZEWM_C360_WATCHDOG_JOB → sintaxe OK
```

**Passo obrigatório pós-import** (DEP-01):
```
SE38 → ZEWM_C360_VALIDATE_DEPS → Executar
  Resultado esperado: "Todas as dependências validadas — OK para prosseguir"
  Se erros: NÃO importar Wave 7 — resolver dependências pendentes primeiro
```

---

### Wave 7 — CDS Interface Views (ZI_)

**Pré-condição**: Waves 2 e 6 importadas (tabelas ativas, classes ativas)  
**Objetos** (ordem dentro da wave):
1. `ZI_EWM_C360_VH_LGNUM`, `ZI_EWM_C360_VH_PROCESS`, `ZI_EWM_C360_VH_SEVERITY`
2. `ZI_EWM_C360_HDR`, `ZI_EWM_C360_ITEM`
3. `ZI_EWM_C360_EXC`, `ZI_EWM_C360_KPI`, `ZI_EWM_C360_ACTLOG`

**Validação pós-import**:
```
SE11 → ZI_EWM_C360_HDR → Status: Ativo
ADT → Preview de dados → retorna linhas sem DUMP
```

---

### Wave 8 — CDS Access Control (DCL)

**Pré-condição**: Wave 7 (ZI_ views) e Wave 3 (authorization objects Z_EWM_C360*) ativos  
**Objetos** — ZI_ views (interface):
- `ZI_EWM_C360_HDR` (role: ZI_EWM_C360_HDR)
- `ZI_EWM_C360_ITEM` (role: ZI_EWM_C360_ITEM)
- `ZI_EWM_C360_EXC` (role: ZI_EWM_C360_EXC)
- `ZI_EWM_C360_KPI` (role: ZI_EWM_C360_KPI)
- `ZI_EWM_C360_ACTLOG` (role: ZI_EWM_C360_ACTLOG — usa Z_EWM_C360L)

**Objetos** — ZC_ views (consumption), importar após ZC_ views (Wave 9):
- `ZC_EWM_C360_INBOUND` (role: ZC_EWM_C360_INBOUND — PROCESS='INBOUND')
- `ZC_EWM_C360_OUTBOUND` (role: ZC_EWM_C360_OUTBOUND — PROCESS='OUTBOUND')
- `ZC_EWM_C360_HU` (role: ZC_EWM_C360_HU — PROCESS='HU')
- `ZC_EWM_C360_WT` (role: ZC_EWM_C360_WT — PROCESS='WT')

**Validação pós-import**:
```
ADT → ZI_EWM_C360_HDR com usuário sem role → 0 registros retornados
ADT → ZI_EWM_C360_HDR com usuário com Z_EWM_C360_EXEC → retorna dados do LGNUM autorizado
```

---

### Wave 9 — CDS Consumption Views (ZC_)

**Pré-condição**: Waves 7 e 8 importadas  
**Objetos**:
- `ZC_EWM_C360_OVERVIEW`, `ZC_EWM_C360_INBOUND`, `ZC_EWM_C360_OUTBOUND`
- `ZC_EWM_C360_HU`, `ZC_EWM_C360_WT`, `ZC_EWM_C360_EXCEPTION`, `ZC_EWM_C360_KPI`

**Validação pós-import**:
```
SE11 → ZC_EWM_C360_EXCEPTION → Status: Ativo
SE11 → ZC_EWM_C360_KPI → associação com ZC_EWM_C360_KPI_DEF visível
```

---

### Wave 10 — OData Service (SEGW)

**Pré-condição**: Wave 9 importada  
**Objetos**:
- Projeto SEGW: `ZEWM_C360_SRV`
- Todos os entity types, entity sets e function imports

**Passos adicionais pós-import**:
```
1. /IWFND/MAINT_SERVICE → Adicionar serviço → ZEWM_C360_SRV
2. Verificar status: Ativo (verde)
3. Testar: /sap/opu/odata/sap/ZEWM_C360_SRV/$metadata → HTTP 200
```

**Validação pós-import**:
```
/IWFND/ERROR_LOG → sem erros relacionados a ZEWM_C360_SRV
```

---

### Wave 11 — Aplicações Fiori (BSP)

**Pré-condição**: Wave 10 importada e serviço publicado  
**Objetos**:
- BSP Applications: `ZEWM_C360_OVP`, `ZEWM_C360_IBD`, `ZEWM_C360_OBD`
- BSP Applications: `ZEWM_C360_HU`, `ZEWM_C360_WT`, `ZEWM_C360_EXC`, `ZEWM_C360_KPI`

**Passos adicionais pós-import**:
```
1. /UI5/APP_INDEX_CALCULATE → recalcular índice de apps (obrigatório)
2. Acessar cada app via URL direta e verificar carregamento
```

---

### Wave 12 — Fiori Launchpad (tiles e catalogs)

**Pré-condição**: Wave 11 importada  
**Objetos**:
- Catalog: `ZEWM_C360_CAT`
- Tiles: 7 tiles (um por app)
- Grupos FLP

**Passos adicionais**:
```
/UI2/FLPD_CONF → verificar catalog ZEWM_C360_CAT com 7 tiles
```

---

### Wave 13 — Roles PFCG

**Pré-condição**: Waves 3 e 12 importadas (auth objects e tiles ativos)  
**Objetos**:
- `Z_EWM_C360_EXEC`, `Z_EWM_C360_INBOUND`, `Z_EWM_C360_OUTBOUND`
- `Z_EWM_C360_SUPPORT`, `Z_EWM_C360_ADMIN`, `Z_EWM_C360_AUDIT`

**Validação pós-import**:
```
PFCG → Z_EWM_C360_EXEC → perfil gerado (ícone verde, não amarelo)
SU01 → usuário piloto → atribuir role → login no Launchpad → tile visível
```

---

### Wave 14 — Jobs Batch

**Pré-condição**: Wave 6 importada (classes ativas)  
**Objetos**:
- Report `ZEWM_C360_SNAPSHOT_JOB`
- Report `ZEWM_C360_RETRY_JOB`

**Configuração pós-import** (SM36):
```
Job 1: ZEWM_C360_SNAPSHOT_DELTA
  Programa : ZEWM_C360_SNAPSHOT_JOB
  Parâmetro: SNAP_TYPE=DELTA
  Periodicidade: a cada 15 minutos

Job 2: ZEWM_C360_SNAPSHOT_FULL
  Programa : ZEWM_C360_SNAPSHOT_JOB
  Parâmetro: SNAP_TYPE=FULL
  Periodicidade: diário às 02:00

Job 3: ZEWM_C360_RETRY
  Programa : ZEWM_C360_RETRY_JOB
  Periodicidade: a cada 30 minutos
```

---

### Wave 15 — Customizing Inicial

**Pré-condição**: Waves 2 e 13 importadas  
**Conteúdo** (transportado via request de Customizing — tipo `C`):

| Tabela | Registros mínimos |
|--------|-----------------|
| `ZTEWM_C360_CUST` | `SNAP_DELTA_MINUTES=15`, `MAX_RETRY=3`, `WT_AGING_WARN_DAYS=2`, `KPI_HISTORY_POINTS=30` |
| `ZTEWM_C360_KPI_DEF` | Definições dos KPIs por processo (mínimo 1 por processo ativo) |
| `ZTEWM_C360_SEV_RULE` | Regras de severidade para pelo menos `LGNUM='*'` (fallback global) |

**Validação pós-import**:
```
SM30 → ZTEWM_C360_CUST → visualizar 4 entradas mínimas
SM30 → ZTEWM_C360_SEV_RULE → regra LGNUM='*' presente
```

---

## Checklist pré-transporte para PRD

Execute antes de liberar qualquer wave para produção:

- [ ] Request importada e testada em QAS sem erros no SM21
- [ ] Testes E2E-001 a E2E-008 executados com sucesso em QAS
- [ ] `ZTEWM_C360_DEP`: todos os registros `IS_HARD_DEP='X'` com `VALIDATED_FLAG='X'`
- [ ] Backup de PRD confirmado (coordenar com Basis)
- [ ] Janela de manutenção acordada com operação
- [ ] Usuário piloto testado em PRD após cada wave crítica (Waves 10, 12, 13)
- [ ] Rollback documentado (ver seção abaixo)

---

## Rollback

| Situação | Ação |
|----------|------|
| Erro na Wave 2 (tabelas) | Deletar tabelas via SE11 em QAS; em PRD consultar Basis para restaurar backup |
| Erro na Wave 10 (OData) | `/IWFND/MAINT_SERVICE` → desativar serviço; reverter request via STMS |
| Erro na Wave 11 (Fiori) | Deletar BSP Application via SE80; tiles ficam inacessíveis mas sem impacto operacional |
| Erro na Wave 13 (Roles) | Remover atribuição de roles dos usuários; reverter request |
| Dados inconsistentes pós-Wave 15 | SM30 → corrigir manualmente; não reverter request de Customizing |

---

## Contatos para dúvidas de transporte

| Papel | Responsabilidade |
|-------|-----------------|
| Basis | Import/export de requests, logs STMS, backup PRD |
| Líder Técnico SAP EWM | Validação funcional pós-import |
| Security (SAP GRC) | Validação de roles e autorização em PRD |
