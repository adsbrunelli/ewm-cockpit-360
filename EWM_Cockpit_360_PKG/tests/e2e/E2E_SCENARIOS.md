# EWM Cockpit 360º — Cenários de Teste E2E

## Convenções

- **Ambiente**: QAS com dados de teste carregados via script `scripts/load_test_data.abap`
- **Usuário base**: `TESTUSER_C360` com role `Z_EWM_C360_EXEC` para LGNUM `WH01`
- **Formato**: Dado / Quando / Então (BDD)
- **Execução**: Manual via Fiori Launchpad ou automática via OData API calls

---

## E2E-001 — Overview Page carrega com dados reais

**Contexto**: usuário operacional acessa o cockpit pela primeira vez no turno.

**Pré-condições**:
- Dados de teste: 10 documentos Inbound OPEN, 3 exceções CRITICAL, 2 KPIs RED no WH01
- Usuário: `TESTUSER_C360` (Z_EWM_C360_EXEC, LGNUM=WH01)

**Passos**:
1. Acessar Fiori Launchpad → tile "EWM Cockpit 360º"
2. OVP abre com filtro Lgnum = WH01 pré-preenchido
3. Aguardar carregamento dos 6 cards

**Verificações**:
- [ ] Card "KPIs do Armazém" exibe os 2 KPIs RED com valor em vermelho
- [ ] Card "Exceções Pendentes" exibe as 3 exceções CRITICAL (no máximo 5 linhas)
- [ ] Card "Inbound Abertos" exibe contador = 10
- [ ] Card "Aging Médio" exibe valor > 0
- [ ] Nenhum erro no console do browser (F12)
- [ ] Tempo de carregamento < 3 segundos (Network tab)

---

## E2E-002 — Inbound com exceção de recebimento → resolução

**Contexto**: recebimento de mercadoria com divergência de quantidade.

**Pré-condições**:
- Documento `IBD-TEST-001` em WH01 com STATUS=BLOCKED, HasException=X
- Exceção `EXC-TEST-001` do tipo `GOODS_RECEIPT_DIFF`, Severity=CRITICAL, Status=OPEN
- Usuário: `TESTUSER_IBD` (Z_EWM_C360_INBOUND, LGNUM=WH01)

**Passos**:
1. Navegar para app "Monitor Inbound"
2. Filtrar por StatusCode = BLOCKED
3. Localizar e clicar em `IBD-TEST-001`
4. Na Object Page, acessar facet "Exceções"
5. Clicar no link da exceção `EXC-TEST-001`
6. Na Object Page de Exceção, clicar em "Resolver"
7. Preencher campo "Motivo": "Divergência confirmada, ajuste realizado no WM"
8. Confirmar

**Verificações**:
- [ ] Documento `IBD-TEST-001` aparece na lista com linha vermelha (criticality)
- [ ] Facet "Exceções" exibe `EXC-TEST-001` com Severity=CRITICAL em vermelho e SLA visível
- [ ] Dialog de resolução exige Motivo (confirmação bloqueada se campo vazio)
- [ ] Após confirmar: toast "Exceção resolvida com sucesso"
- [ ] Exceção `EXC-TEST-001` some da lista (StatusCode=RESOLVED filtrado)
- [ ] Log de Ações exibe entrada RESOLVE com usuário e timestamp corretos
- [ ] ZTEWM_C360_EXC: RESOLVED_FLAG='X', STATUS_CODE='RESOLVED' (verificar via SE16)

---

## E2E-003 — Outbound com picking pendente → reprocessamento

**Contexto**: ordem de saída bloqueada por erro de picking, elegível para reprocessamento.

**Pré-condições**:
- Documento `OBD-TEST-001` em WH01 com STATUS=BLOCKED, REPROC_FLAG='X', RETRY_COUNT=0
- ZTEWM_C360_CUST: MAX_RETRY=3
- Usuário: `TESTUSER_OBD` (Z_EWM_C360_OUTBOUND, LGNUM=WH01)

**Passos**:
1. Navegar para "Monitor Outbound"
2. Selecionar linha `OBD-TEST-001`
3. Clicar em "Reprocessar Selecionados" na toolbar
4. Confirmar na dialog de confirmação

**Verificações**:
- [ ] Botão "Reprocessar" habilitado somente quando REPROC_FLAG='X'
- [ ] Dialog exibe: "Confirma reprocessamento de 1 documento(s)?"
- [ ] Após reprocessamento bem-sucedido: Status muda para OPEN ou COMPLETED
- [ ] ZTEWM_C360_HDR: RETRY_COUNT incrementado para 1
- [ ] ZTEWM_C360_ACTLOG: nova entrada com ACTION_TYPE='REPROCESS', ACTION_RESULT='SUCCESS'
- [ ] Toast: "Reprocessamento concluído com sucesso"

**Cenário alternativo — falha no reprocessamento**:
- Configurar mock para falha (ajustar dado de teste para simular erro de integração)
- RETRY_COUNT deve ser incrementado para 1
- STATUS_CODE permanece BLOCKED
- Log registra ACTION_RESULT='ERROR' com ErrorMsg preenchido
- Após 3 falhas: STATUS_CODE muda para FAILED, botão Reprocessar desabilitado

---

## E2E-004 — KPI fora da tolerância → recálculo manual

**Contexto**: KPI de acurácia de inbound abaixo da meta, supervisor solicita recálculo.

**Pré-condições**:
- KPI `INBOUND_ACCURACY` em WH01: ActualValue=78, TargetValue=95, TolerancePct=10 → RED
- Usuário: `TESTUSER_SUP` (Z_EWM_C360_SUPPORT, LGNUM=WH01)

**Passos**:
1. Navegar para "Dashboard de KPIs"
2. Filtro StatusCode = RED já pré-selecionado
3. Localizar `INBOUND_ACCURACY` na lista (linha vermelha)
4. Clicar para abrir Object Page
5. Verificar micro chart histórico (últimos 30 dias)
6. Clicar em "Recalcular KPI"

**Verificações**:
- [ ] KPI aparece na lista com DeviationPct em vermelho (StatusCriticality=1)
- [ ] Object Page exibe Formula e DataSource preenchidos
- [ ] Micro chart exibe série temporal com linha de referência (meta)
- [ ] Botão "Recalcular" visível para usuário com Z_EWM_C360_SUPPORT
- [ ] Após recálculo: DataPoints e micro chart atualizam sem refresh manual
- [ ] Log de Ações: entrada com ACTION_TYPE='RECALCULATE'

---

## E2E-005 — Segurança: acesso negado por role

**Contexto**: usuário sem role tenta acessar dados de outro warehouse.

**Pré-condições**:
- Usuário `TESTUSER_NOACCESS` sem nenhuma role Z_EWM_C360_*
- Usuário `TESTUSER_IBD_WH01` com Z_EWM_C360_INBOUND apenas para LGNUM=WH01

**Cenário A — sem role**:
1. `TESTUSER_NOACCESS` acessa Fiori Launchpad
2. Tiles do cockpit não aparecem (catalog não atribuído)
3. Tentativa direta via URL do app → HTTP 403

**Cenário B — role correta mas LGNUM errado**:
1. `TESTUSER_IBD_WH01` abre Monitor Inbound
2. Altera filtro Lgnum para WH02 (warehouse não autorizado)
3. Aplicar filtro

**Verificações B**:
- [ ] Lista retorna vazia (0 registros) — access control da CDS filtra no backend
- [ ] Nenhuma mensagem de erro técnico exposta ao usuário
- [ ] Se tentar via OData direto com Lgnum=WH02: 0 registros retornados (não 403 — por design do CDS access control)
- [ ] ZTEWM_C360_ACTLOG: tentativa registrada como DENIED se ação foi tentada

---

## E2E-006 — WT em atraso com aging crítico

**Contexto**: tarefa de armazém aberta há mais de 2 dias (acima do limite configurado).

**Pré-condições**:
- WT `WT-TEST-001` em WH01: STATUS=OPEN, OpenDate = hoje - 3 dias
- ZTEWM_C360_CUST: `WT_AGING_WARN_DAYS`=2
- Usuário: `TESTUSER_C360` (Z_EWM_C360_EXEC)

**Passos**:
1. Navegar para "Tarefas de Armazém"
2. Filtro default: StatusCode = OPEN, OVERDUE

**Verificações**:
- [ ] `WT-TEST-001` aparece no topo da lista (ordenação por DueDate ASC)
- [ ] Coluna AgingDays = 3, exibida em vermelho (criticality = 1, pois > WT_AGING_WARN_DAYS)
- [ ] DataPoint AgingDays na Object Page também em vermelho
- [ ] Outros WTs com aging <= 2 dias exibem criticality = 0 (sem cor)

---

## E2E-007 — Snapshot delta executa sem concorrência

**Contexto**: job de snapshot delta disparado manualmente pelo suporte.

**Pré-condições**:
- ZTEWM_C360_SNAP_CTL para WH01/DELTA com LOCK_FLAG=''
- Usuário técnico com autorização de execução de job

**Passos**:
1. Executar job `ZEWM_C360_SNAPSHOT_JOB` manualmente (SE38 ou SM36)
2. Durante execução, tentar disparar segundo job para o mesmo LGNUM

**Verificações**:
- [ ] Primeiro job: LOCK_FLAG='X' em ZTEWM_C360_SNAP_CTL durante execução
- [ ] Segundo job: detecta LOCK_FLAG='X' e termina com mensagem "Snapshot em execução"
- [ ] Após conclusão do primeiro: LOCK_FLAG='' e DELTA_TO_TS atualizado
- [ ] ZTEWM_C360_ACTLOG: entradas com ACTION_TYPE='SNAPSHOT_START' e 'SNAPSHOT_END'
- [ ] Em caso de ABAP dump durante snapshot: LOCK_FLAG limpo pelo CLEANUP handler

---

## E2E-008 — Consulta de log de auditoria

**Contexto**: auditor consulta histórico de ações operacionais.

**Pré-condições**:
- Usuário `TESTUSER_AUDIT` com Z_EWM_C360_AUDIT (somente ACTVT=03)
- Dados: log com entradas RESOLVE, REPROCESS, RECALCULATE dos cenários anteriores

**Verificações**:
- [ ] Usuário AUDIT consegue visualizar todos os logs via OData (GET ZC_EWM_C360_ACTLOG)
- [ ] Usuário AUDIT não consegue executar ações (POST/PATCH retornam 403)
- [ ] Log exibe: ActionType, ActionResult, ActionBy, ActionAt, ErrorMsg
- [ ] Registros de RESOLVE incluem o campo Motivo da resolução
- [ ] Nenhum dado de credencial ou senha aparece nos logs

---

## Matriz de cobertura E2E × Componente

| Cenário | Auth | KPI Engine | Exc. Engine | Reprocessor | Snapshot | OData | Fiori UI |
|---------|------|-----------|-------------|-------------|----------|-------|----------|
| E2E-001 | X | X | X | — | — | X | X |
| E2E-002 | X | — | X | — | — | X | X |
| E2E-003 | X | — | — | X | — | X | X |
| E2E-004 | X | X | — | — | — | X | X |
| E2E-005 | X | — | — | — | — | X | X |
| E2E-006 | X | — | — | — | — | X | X |
| E2E-007 | — | — | — | — | X | — | — |
| E2E-008 | X | — | — | — | — | X | — |
