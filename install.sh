#!/usr/bin/env bash
set -e

echo "Iniciando instalação do ambiente DevSecOps (ARM / AMD64)"
echo "OPA fixado na versão 1.11.0"
echo "-----------------------------------------------"

############################
# FUNÇÃO UTILITÁRIA
############################
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

############################
# DETECÇÃO DE ARQUITETURA
############################
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
  SYSTEM_ARCH="amd64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
  SYSTEM_ARCH="arm64"
else
  echo "Arquitetura não suportada: $ARCH"
  exit 1
fi

echo "Arquitetura detectada: $SYSTEM_ARCH"

############################
# ATUALIZAÇÃO DO SISTEMA
############################
echo "Atualizando pacotes do sistema..."
sudo apt update && sudo apt upgrade -y

############################
# DEPENDÊNCIAS BÁSICAS
############################
sudo apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  unzip \
  software-properties-common

############################
# PYTHON
############################
if command_exists python3; then
  echo "Python já instalado: $(python3 --version)"
else
  echo "Instalando Python3..."
  sudo apt install -y python3 python3-pip python3-venv
fi

############################
# PIPX
############################
if command_exists pipx; then
  echo "pipx já instalado"
else
  echo "Instalando pipx..."
  sudo apt install -y pipx
  pipx ensurepath
fi

############################
# DOCKER
############################
if command_exists docker; then
  echo "Docker já instalado: $(docker --version)"
else
  echo "Instalando Docker..."
  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL \
    https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update
  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  sudo usermod -aG docker "$USER"
  echo "Docker instalado. Reinicie o terminal para usar sem sudo."
fi

############################
# TERRAFORM
############################
if command_exists terraform; then
  echo "Terraform já instalado: $(terraform version | head -n 1)"
else
  echo "Instalando Terraform..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg

  echo \
    "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list

  sudo apt update
  sudo apt install -y terraform
fi

############################
# ANSIBLE
############################
if command_exists ansible; then
  echo "Ansible já instalado"
else
  echo "Instalando Ansible..."
  sudo apt install -y ansible
fi

############################
# AWS CLI v2
############################
if command_exists aws; then
  echo "AWS CLI já instalada: $(aws --version)"
else
  echo "Instalando AWS CLI v2..."
  curl \
    "https://awscli.amazonaws.com/awscli-exe-linux-${SYSTEM_ARCH}.zip" \
    -o "/tmp/awscliv2.zip"

  unzip -o /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
  rm -rf /tmp/awscliv2.zip /tmp/aws
fi

############################
# LOCALSTACK CLI
############################
if command_exists localstack; then
  echo "LocalStack CLI já instalada"
else
  echo "Instalando LocalStack CLI..."
  LOCALSTACK_VERSION="4.12.0"

  curl -L \
    "https://github.com/localstack/localstack-cli/releases/download/v${LOCALSTACK_VERSION}/localstack-cli-${LOCALSTACK_VERSION}-linux-${SYSTEM_ARCH}-onefile.tar.gz" \
    -o /tmp/localstack-cli.tar.gz

  sudo tar -xzf /tmp/localstack-cli.tar.gz -C /usr/local/bin localstack
  sudo chmod +x /usr/local/bin/localstack
  rm -f /tmp/localstack-cli.tar.gz
fi

############################
# TFLOCAL (terraform-local)
############################
if command_exists tflocal; then
  echo "tflocal já instalado"
else
  echo "Instalando tflocal via pipx..."
  pipx install terraform-local
fi

############################
# OPA (VERSÃO FIXA 1.11.0)
############################
OPA_VERSION="1.11.0"

if command_exists opa; then
  echo "OPA já instalado: $(opa version | head -n 1)"
else
  echo "Instalando OPA v${OPA_VERSION}..."
  if [[ "$SYSTEM_ARCH" == "amd64" ]]; then
    OPA_BIN="opa_linux_amd64"
  else
    OPA_BIN="opa_linux_arm64"
  fi

  curl -Lo /tmp/opa \
    "https://openpolicyagent.org/downloads/v${OPA_VERSION}/${OPA_BIN}"

  sudo mv /tmp/opa /usr/local/bin/opa
  sudo chmod +x /usr/local/bin/opa
fi

############################
# FINAL
############################
echo
echo "==============================================="
echo "Ambiente DevSecOps instalado com sucesso"
echo "Arquitetura: $SYSTEM_ARCH"
echo "OPA: v${OPA_VERSION}"
echo
echo "IMPORTANTE:"
echo "- Reinicie o terminal (grupo docker / PATH)"
echo "- Verifique:"
echo "  docker ps"
echo "  terraform version"
echo "  tflocal --version"
echo "  opa version"
echo "==============================================="
