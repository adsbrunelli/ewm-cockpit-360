# CDS Guidelines

## Padrões

- Interface views começam com `ZI_`.
- Consumption views começam com `ZC_`.
- Views analíticas devem declarar semântica de medida e unidade.
- Campos de autorização devem estar disponíveis na view.
- Associações devem ser explícitas e justificadas.
- Evitar lógica pesada em CDS se prejudicar performance.

## Annotations

- UI annotations apenas quando agregarem navegação ou layout.
- Search annotations em campos relevantes.
- Value helps para campos de domínio funcional.
- Authorization check quando aplicável.
