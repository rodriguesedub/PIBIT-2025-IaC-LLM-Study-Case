Geração de Políticas de Segurança em IaC usando LLM

Este repositório contém os artefatos, códigos e evidências do Estudo de Caso desenvolvido para o projeto de Iniciação Tecnológica (PIBIT/PUCPR), focado na automação de governança em Nuvem via Inteligência Artificial Generativa.

Aluno: Eduardo Rodrigues

Orientador: Altair Olivo Santin

Instituição: Pontifícia Universidade Católica do Paraná (PUCPR)

Vigência: 2025-2026

🎯 Objetivo do Estudo de Caso

Investigar a "lacuna de implantabilidade" (deployability gap) na geração de código de segurança por LLMs. O estudo avalia a eficácia do ChatGPT-4o na geração automática de políticas Open Policy Agent (OPA) para validar infraestruturas Terraform, comparando duas estratégias de Engenharia de Prompt:

Zero-Shot: Geração direta sem exemplos ou refinamento.

RCI (Recursive Criticism and Improvement): Geração iterativa com ciclo de autocrítica.

🛠️ Tecnologias e Versões

A reprodutibilidade deste experimento depende estritamente das versões abaixo, devido a mudanças de sintaxe na linguagem Rego (OPA v1.0+).

Sistema Operacional: Ubuntu 24.04 LTS

Terraform: v1.14.2

LocalStack: Simulador de AWS (Docker)

Tflocal: Wrapper python para integração Terraform-LocalStack

Open Policy Agent (OPA): v1.11.0 (Requer sintaxe Rego v1 com palavras-chave if e contains)

LLM: GPT-4o (OpenAI - via Web Interface)

📂 Estrutura do Projeto
```text
.
├── infra/                     # Código Terraform (Cenário Vulnerável)
│   └── main.tf                # Definição de S3 Bucket sem bloqueio de acesso público
│
├── policies/                  # Políticas geradas pelo LLM
│   ├── s3_policy_Zero-Shot.rego  # Falha (erro de sintaxe/versão)
│   └── s3_policy_RCI.rego        # Sucesso (sintaxe corrigida e validação robusta)
│
├── evidence/                  # Logs, PDFs das conversas e screenshots
│
├── logs/                      # Arquivos de saída técnica
│   └── tfplan.json            # Plano Terraform convertido para JSON (input do OPA)
│
├── prompts/                   # Documentação dos prompts utilizados
│   └── prompts.md
│
├── install.sh                 # Script de configuração do ambiente
└── README.md                  # Documentação do projeto
```

🚀 Como Executar o Experimento

1. Preparação do Ambiente

Execute o script de instalação para configurar o tflocal, opa e dependências:

```text
chmod +x install.sh
./install.sh
```


2. Gerando o Plano de Infraestrutura (Cenário Vulnerável)

Utilizamos o LocalStack para simular a criação de recursos sem custos.

# Iniciar LocalStack (caso não esteja rodando via Docker Desktop)
```text
docker run -d \
  --name localstack_main \
  -p 4566:4566 \
  -e SERVICES=s3,iam,sts \
  localstack/localstack
```


# Inicializar e planejar a infraestrutura
```text
cd infra
tflocal init
tflocal plan -out tfplan.binary
```

# Converter o plano para JSON (Formato exigido pelo OPA)
# O arquivo será salvo na pasta logs/ para auditoria
```text
tflocal show -json tfplan.binary > ../logs/tfplan.json
cd ..
```


3. Executando a Validação de Segurança (OPA)

Cenário A: Abordagem Zero-Shot (Falha Esperada)
O código gerado diretamente pelo LLM utiliza sintaxe depreciada (Rego v0), incompatível com o binário moderno do OPA.

```text
opa eval --format pretty --input logs/tfplan.json --data policies/s3_policy_Zero-Shot.rego "data.terraform.deny"
```

Resultado: Erro de parsing (rego_parse_error: if keyword is required before rule body).

Cenário B: Abordagem RCI (Sucesso)
O código refinado pelo próprio LLM corrige a sintaxe e trata valores nulos em resource_changes.

```text
opa eval --format pretty --input logs/tfplan.json --data policies/s3_policy_RCI.rego "data.terraform.deny"
```

Resultado: Sucesso. O output JSON deve conter a mensagem de negação, indicando que a política detectou corretamente a vulnerabilidade.

📊 Principais Resultados

Incompatibilidade de Versão: O GPT-4o, em modo Zero-Shot, tende a gerar código Rego antigo, falhando em ambientes OPA atualizados (v1.11.0+).

Eficácia do RCI: A técnica de Crítica Recursiva permitiu que o modelo "se atualizasse", corrigindo a sintaxe para Rego v1 e adicionando verificações de segurança contra valores nulos (null safety), tornando o artefato implantável.

Projeto desenvolvido para o Programa de Iniciação Científica e Tecnológica da PUCPR.
