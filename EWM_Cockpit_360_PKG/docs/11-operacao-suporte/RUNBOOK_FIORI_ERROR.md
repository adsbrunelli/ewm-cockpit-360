# Runbook — Erro na Interface Fiori / App Não Carrega

## Identificação do problema

**Sintoma A** — Tela branca (blank page) ao abrir o app:
- URL do app carrega mas nada é exibido
- Console do browser mostra erros JavaScript

**Sintoma B** — Mensagem "Service not available" ou HTTP 503:
- OData service offline ou não publicado

**Sintoma C** — Dados não carregam (spinner infinito):
- Filtros são aplicados mas a tabela nunca preenche
- Network tab mostra chamada OData em `Pending`

**Sintoma D** — Ação (Resolver, Reprocessar) retorna erro genérico:
- Toast vermelho sem mensagem clara
- Operação não persistida

---

## Diagnóstico rápido por camada

```
Usuário reporta erro
       │
       ├─ Abrir F12 (DevTools) → aba Network
       │        │
       │        ├─ $metadata retornou erro? → PROBLEMA NO SERVIÇO ODATA (Caso B)
       │        ├─ EntitySet retornou 0 registros? → PROBLEMA DE AUTORIZAÇÃO OU DADOS (Caso C)
       │        └─ Chamada de Action retornou 4xx/5xx? → PROBLEMA NA AÇÃO (Caso D)
       │
       └─ Sem chamadas no Network? → PROBLEMA DE JAVASCRIPT/CACHE (Caso A)
```

---

## Resolução

### Caso A — Tela branca (JavaScript)

**Passo 1**: Limpar cache do browser
```
Chrome: Ctrl+Shift+Delete → Imagens e arquivos em cache → Limpar
```

**Passo 2**: Recalcular índice de apps Fiori
```
Transação: /UI5/APP_INDEX_CALCULATE
Selecionar: todos os apps ZEWM_C360_*
Executar
Aguardar conclusão (pode levar 2-5 minutos)
```

**Passo 3**: Verificar BSP Application ativa
```
SE80 → BSP Applications → ZEWM_C360_OVP → Status: Ativo (verde)
```

### Caso B — Service not available (OData)

**Passo 1**: Verificar serviço no Gateway
```
/IWFND/MAINT_SERVICE → filtrar por ZEWM_C360_SRV
Status deve ser: Ativo (verde)
Se inativo: selecionar → Ativar
```

**Passo 2**: Testar $metadata diretamente
```
URL: /sap/opu/odata/sap/ZEWM_C360_SRV/$metadata
Esperado: HTTP 200 com XML de metadados
```

**Passo 3**: Verificar erros do Gateway
```
/IWFND/ERROR_LOG → filtrar por serviço ZEWM_C360_SRV → últimas ocorrências
Erros comuns:
  "Message class not found" → importar message class ZEWM_C360_MSG
  "Entity type not found"   → reimportar Wave 9 (CDS Consumption Views)
```

### Caso C — Dados não carregam (autorização ou dados)

**Passo 1**: Testar com usuário técnico admin para isolar autorização
```
SU01 → usuário de teste com Z_EWM_C360_ADMIN → testar no app
Se admin vê dados: problema de autorização do usuário original
Se admin não vê: problema nos dados ou na CDS
```

**Passo 2**: Testar query OData direto (Postman ou browser)
```
/sap/opu/odata/sap/ZEWM_C360_SRV/ZC_EWM_C360_EXCEPTION?$filter=Lgnum eq 'WH01'&$top=10
```

**Passo 3**: Verificar autorização do usuário
```
SU53 → executar como usuário com problema → ver objeto faltante
PFCG → adicionar objeto de autorização faltante ao perfil
```

### Caso D — Ação retorna erro

**Passo 1**: Verificar `/IWFND/ERROR_LOG` imediatamente após o erro
```
/IWFND/ERROR_LOG → ordenar por data DESC → abrir ocorrência mais recente
Verificar: ABAP Error, Message, Stack trace
```

**Passo 2**: Reproduzir com SM50 aberto (monitorar workprocess)
```
SM50 → filtrar por usuário que reportou erro
Executar ação no Fiori
SM50 → capturar workprocess em ABAP wait → ver programa e linha
```

**Passo 3**: Verificar ACTLOG para a ação com erro
```
SE16 → ZTEWM_C360_ACTLOG
Filtro: ACTION_BY = <usuário>, ACTION_TYPE = 'RESOLVE' (ou REPROCESS)
Verificar: ACTION_RESULT = 'ERROR', ERROR_MSG
```

---

## Comandos de diagnóstico rápido (copiar e colar)

| Transação | Para que serve |
|-----------|---------------|
| `/IWFND/MAINT_SERVICE` | Status e ativação do OData service |
| `/IWFND/ERROR_LOG` | Log de erros do Gateway |
| `/UI5/APP_INDEX_CALCULATE` | Recalcular índice de apps Fiori |
| `SM21` | System log (erros ABAP em tempo real) |
| `SU53` | Capturar objeto de autorização faltante |
| `SE80 → BSP` | Verificar status das BSP applications |

---

## Quando escalar

| Situação | Escalar para |
|----------|-------------|
| $metadata retorna 500 após reimport | Desenvolvedor ABAP |
| Erro em workprocess (SM50 mostra dump) | Desenvolvedor ABAP + SM21 |
| Problemas de autorização em PRD | Security / SAP GRC |
| App carrega em DEV mas não em PRD | Basis (diferença de configuração de sistema) |
| Problema em componente Fiori UI5 | Desenvolvedor Fiori / SAP Note |
