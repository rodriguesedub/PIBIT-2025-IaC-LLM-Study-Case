# Geração de Políticas de Segurança em IaC usando LLM

Este repositório contém os artefatos, códigos e evidências do Estudo de Caso desenvolvido para o projeto de Iniciação Tecnológica (PIBIT/PUCPR), focado na automação de governança em Nuvem via Inteligência Artificial.

**Aluno:** Eduardo Rodrigues  
**Orientador:** Altair Olivo Santin  
**Período:** 2025-2026

## 🎯 Objetivo do Estudo de Caso
Demonstrar e avaliar a eficácia de Large Language Models (LLMs) na geração automática de políticas de segurança **Open Policy Agent (OPA)** para validar infraestruturas **Terraform**. O estudo compara duas abordagens de Engenharia de Prompt:
1.  **Zero-Shot:** Geração direta.
2.  **RCI (Recursive Criticism and Improvement):** Geração com ciclo de autocrítica.

## 🛠️ Tecnologias e Versões
Para garantir a reprodutibilidade dos experimentos, este ambiente utiliza versões específicas que impactam a sintaxe do código (especialmente OPA Rego v1).

* **SO:** Ubuntu 24.04 LTS
* **Terraform:** v1.14.2
* **LocalStack:** Simulador de AWS local (via Docker)
* **Tflocal:** Wrapper para facilitar o uso do LocalStack
* **Open Policy Agent (OPA):** v1.11.0 (Requer sintaxe Rego v1)
* **LLM:** GPT-4o (OpenAI)

## 📂 Estrutura do Projeto

```text
.
├── infra/                  # Código Terraform (Cenário Vulnerável)
│   └── main.tf             # Criação de S3 Bucket sem bloqueio de acesso público
├── policies/               # Políticas geradas pelo LLM
│   ├── s3_policy_Zero_Shot.rego  # Falha (Erro de sintaxe/versão)
│   └── s3_policy_RCI.rego        # Sucesso (Sintaxe corrigida e validação robusta)
├── evidence/               # Logs e evidências de execução
│   ├── tfplan.json         # Plano de execução convertido para JSON
│   └── logs_opa.txt        # Saída da validação
├── install.sh              # Script de configuração do ambiente
└── README.md
🚀 Como Executar
1. Preparação do Ambiente
Execute o script de instalação para configurar o tflocal, opa e dependências:

Bash

chmod +x install.sh
./install.sh
2. Subindo a Infraestrutura (Simulada)
Inicie o LocalStack e gere o plano do Terraform:

Bash

# Iniciar LocalStack (se via docker-compose ou desktop)
docker start localstack_main

# Inicializar e planejar a infraestrutura
cd infra
tflocal init
tflocal plan -out tfplan.binary

# Converter o plano para JSON (Formato lido pelo OPA)
tflocal show -json tfplan.binary > ../evidence/tfplan.json
3. Executando a Validação de Segurança (OPA)
Teste 1: Abordagem Zero-Shot (Falha Esperada) O código gerado sem refinamento utiliza sintaxe depreciada incompatível com OPA v1.

Bash

opa eval --format pretty --input evidence/tfplan.json --data policies/s3_policy_Zero_Shot.rego "data.terraform.deny"
# Resultado esperado: rego_parse_error (if keyword is required)
Teste 2: Abordagem RCI (Sucesso) O código refinado corrige a sintaxe e trata valores nulos.

Bash

opa eval --format pretty --input evidence/tfplan.json --data policies/s3_policy_RCI.rego "data.terraform.deny"
# Resultado esperado: Mensagem de bloqueio de criação do bucket inseguro.
📊 Principais Resultados
A abordagem Zero-Shot falhou ao gerar código compatível com a versão moderna do OPA (1.11.0+), ignorando palavras-chave obrigatórias como if.

A abordagem RCI foi capaz de corrigir as alucinações de sintaxe e adicionar robustez lógica (verificação de nulidade em resource_changes), resultando em uma política funcional que detectou corretamente a vulnerabilidade de S3 Público.