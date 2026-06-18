# ABAP Guidelines

## Princípios

- Responsabilidade única por classe.
- Sem hardcode de regras operacionais.
- Mensagens padronizadas.
- Logs obrigatórios em ações sensíveis.
- Autorização validada no backend.
- Métodos pequenos, testáveis e com contratos claros.

## Padrão de classe

- `CONSTRUCTOR`
- `VALIDATE_INPUT`
- `CHECK_AUTHORIZATION`
- `EXECUTE`
- `WRITE_LOG`
- `RETURN_RESULT`

## Tratamento de erro

- Usar exceções tipadas quando aplicável.
- Retornar mensagem técnica e funcional.
- Registrar contexto de execução.
