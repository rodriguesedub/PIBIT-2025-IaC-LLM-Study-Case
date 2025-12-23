package terraform

# Política de negação para aws_s3_bucket_public_access_block
#
# Objetivo:
# Negar a CRIAÇÃO de qualquer recurso aws_s3_bucket_public_access_block
# quando QUALQUER um dos seguintes atributos estiver definido como false:
# - block_public_acls
# - block_public_policy
# - ignore_public_acls
# - restrict_public_buckets
#
# A política lê a estrutura:
# input.resource_changes (Terraform plan em JSON)

deny[msg] {
    # Itera sobre todas as mudanças de recursos do plano
    rc := input.resource_changes[_]

    # Garante que o recurso é do tipo correto
    rc.type == "aws_s3_bucket_public_access_block"

    # Garante que a ação inclui criação do recurso
    rc.change.actions[_] == "create"

    # Obtém o estado final planejado do recurso
    after := rc.change.after

    # Verifica se QUALQUER um dos atributos de proteção está false
    (
        after.block_public_acls == false
        or after.block_public_policy == false
        or after.ignore_public_acls == false
        or after.restrict_public_buckets == false
    )

    # Mensagem de erro clara para o usuário/CI
    msg := sprintf(
        "Criação negada: o recurso %s (%s) possui configurações inseguras de acesso público ao S3. Todos os atributos de Public Access Block devem ser true.",
        [rc.name, rc.address]
    )
}
