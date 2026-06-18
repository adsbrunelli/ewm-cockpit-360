# Dependency Matrix: EWM Cockpit 360º

## Finalidade

Controlar a sequência técnica de criação, ativação, transporte e deploy dos objetos do Cockpit 360º.

## Ordem macro recomendada

| Sequência | Camada | Objeto | Depende de |
|---:|---|---|---|
| 10 | DDIC | Domínios e Data Elements | Nenhuma |
| 20 | DDIC | Tabelas ZTEWM_C360_* | Domínios e Data Elements |
| 30 | DDIC | Search Helps | Tabelas |
| 40 | CDS | Interface Views ZI_* | Tabelas |
| 50 | CDS | Consumption Views ZC_* | Interface Views |
| 60 | ABAP OO | Classes utilitárias | DDIC |
| 70 | ABAP OO | Engines e Handlers | DDIC, CDS, classes utilitárias |
| 80 | Serviço | OData/RAP | CDS, Classes |
| 90 | Fiori | App, cards, actions | Serviços |
| 100 | Segurança | Roles PFCG | Serviços, ações, objetos de autorização |
| 110 | Jobs | Snapshot e reprocessing | Classes, DDIC |
| 120 | Testes | Unit, integração e aceite | Todos os objetos |
| 130 | Transporte | Sequência final | Matriz validada |

## Regra obrigatória

Não transportar CDS antes de DDIC. Não transportar Fiori antes dos serviços. Não transportar roles antes da definição final das actions e authorization objects.
