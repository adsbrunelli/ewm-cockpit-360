# Transport and Release Strategy: EWM Cockpit 360º

## Objetivo

Controlar a sequência de transporte dos objetos SAP para evitar erros de ativação e inconsistências entre ambientes.

## Ordem recomendada

1. Domínios e data elements.
2. Tabelas Z.
3. Search helps.
4. Objetos de autorização.
5. CDS interface.
6. CDS consumption.
7. Classes utilitárias.
8. Engines ABAP.
9. Handlers de actions.
10. Serviços OData/RAP.
11. Fiori app e FLP.
12. Roles PFCG.
13. Jobs.
14. Customizing inicial.
15. Testes e documentação.

## Regras

- A matriz de dependência deve ser validada antes do release.
- CDS não deve ser importada antes das tabelas.
- Fiori não deve ser importado antes do serviço publicado.
- Roles devem ser validadas com actions definitivas.
- Customizing inicial deve ser transportado separado de objetos workbench quando possível.
