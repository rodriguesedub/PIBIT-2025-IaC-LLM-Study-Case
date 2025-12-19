#!/usr/bin/env bash
set -e

echo "Iniciando instalação e verificação do ambiente DevSecOps..."

############################
# FUNÇÃO DE CHECAGEM
############################
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

############################
# ATUALIZAÇÃO DO SISTEMA
############################
echo "Atualizando pacotes do sistema..."
sudo apt update && sudo apt upgrade -y

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
# DOCKER
############################
if command_exists docker; then
  echo "Docker já instalado: $(docker --version)"
else
  echo "Instalando Docker..."
  sudo apt install -y ca-certificates curl gnupg lsb-release
  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"
  echo "Reinicie o terminal para usar Docker sem sudo."
fi

############################
# TERRAFORM
############################
if command_exists terraform; then
  echo "Terraform já instalado: $(terraform version | head -n 1)"
else
  echo "Instalando Terraform..."
  sudo apt install -y gnupg software-properties-common curl
  curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp.gpg

  echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list

  sudo apt update
  sudo apt install -y terraform
fi

############################
# ANSIBLE
############################
if command_exists ansible; then
  echo "Ansible já instalado: $(ansible --version | head -n 1)"
else
  echo "Instalando Ansible..."
  sudo apt install -y ansible
fi

############################
# AWS CLI
############################
if command_exists aws; then
  echo "AWS CLI já instalada: $(aws --version)"
else
  echo "Instalando AWS CLI v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -o /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
  rm -rf /tmp/awscliv2.zip /tmp/aws
fi

############################
# LOCALSTACK CLI
############################
if command_exists localstack; then
  echo "LocalStack CLI já instalada: $(localstack --version)"
else
  echo "Instalando LocalStack CLI..."
  VERSION="4.12.0"
  curl -L \
    "https://github.com/localstack/localstack-cli/releases/download/v${VERSION}/localstack-cli-${VERSION}-linux-amd64-onefile.tar.gz" \
    -o /tmp/localstack-cli.tar.gz

  sudo tar -xzf /tmp/localstack-cli.tar.gz -C /usr/local/bin localstack
  sudo chmod +x /usr/local/bin/localstack
  rm -f /tmp/localstack-cli.tar.gz
fi

############################
# TFLOCAL
############################
if command_exists tflocal; then
  echo "tflocal já instalado."
else
  echo "Instalando tflocal..."
  pip install --upgrade terraform-local
fi

############################
# OPA
############################
if command_exists opa; then
  echo "OPA já instalado: $(opa version | head -n 1)"
else
  echo "Instalando OPA..."
  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" ]]; then
    OPA_ARCH="linux-amd64"
  elif [[ "$ARCH" == "aarch64" ]]; then
    OPA_ARCH="linux-arm64"
  else
    echo "Arquitetura não suportada: $ARCH"
    exit 1
  fi

  OPA_VERSION="1.6.3"
  curl -Lo /tmp/opa.zip \
    "https://openpolicyagent.org/downloads/v${OPA_VERSION}/opa_${OPA_ARCH}.zip"

  unzip -o /tmp/opa.zip -d /tmp
  sudo mv /tmp/opa /usr/local/bin/
  sudo chmod +x /usr/local/bin/opa
  rm -f /tmp/opa.zip
fi

############################
# FINAL
############################
echo "Ambiente instalado com sucesso."
echo "Reinicie o terminal se adicionou o usuário ao grupo Docker."
