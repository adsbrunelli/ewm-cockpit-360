# Project Charter: EWM Cockpit 360º Dashboard

## Versão

- Data: 2026-06-18
- Status: Base inicial
- Responsável funcional: Supply Chain / SAP EWM
- Responsável técnico: Arquitetura SAP ABAP, CDS, Fiori e EWM

## Objetivo

Criar um cockpit Fiori/ABAP para SAP EWM capaz de centralizar indicadores, exceções, documentos, ações, logs e diagnósticos técnicos em uma visão 360º por warehouse, processo e criticidade operacional.

## Problema de negócio

Operações SAP EWM normalmente exigem navegação em múltiplas transações, monitores, filas, logs e relatórios para entender a situação real do armazém. Isso aumenta o tempo de diagnóstico, reduz a rastreabilidade e dificulta gestão operacional orientada por exceções.

## Resultado esperado

Um dashboard operacional e técnico que permita:

- Detectar gargalos e exceções.
- Medir KPIs por warehouse e processo.
- Executar ações controladas via Fiori.
- Registrar auditoria de ações sensíveis.
- Reprocessar erros técnicos com rastreabilidade.
- Centralizar diagnóstico para suporte, key users e líderes de operação.

## Escopo funcional

- Overview
- Inbound
- Outbound
- Handling Units
- Warehouse Tasks
- Exceptions
- KPI Engine
- Severity Engine
- Reprocessing Framework
- Action Log
- Diagnostic Cockpit

## Escopo técnico

- Tabelas ZTEWM_C360_*
- Views CDS ZI_EWM_C360_* e ZC_EWM_C360_*
- Classes ABAP OO ZCL_EWM_C360_*
- Serviços OData/RAP
- Fiori Elements ou Fiori freestyle, conforme decisão de arquitetura
- PFCG roles
- SLG1 object/subobject
- Jobs de snapshot delta/full
- Matriz de transporte

## Fora de escopo inicial

- Substituir o /SCWM/MON standard.
- Alterar processos core SAP EWM standard sem justificativa.
- Criar ações em massa sem autorização e log.
- Integrar sistemas externos sem desenho técnico aprovado.

## Premissas

- O sistema SAP possui EWM ativo.
- Os processos inbound, outbound, HU, WT e monitoramento técnico estão disponíveis.
- A arquitetura deverá respeitar autorização por warehouse.
- O cockpit deverá permitir evolução incremental por módulo.

## Critérios macro de aceite

- Todos os objetos técnicos estão documentados.
- A matriz de dependência permite transporte controlado.
- Toda ação sensível possui autorização e log.
- KPIs possuem origem e fórmula documentadas.
- Exceções possuem severidade e SLA.
- A documentação permite manutenção futura por equipe SAP e Claude Code.
