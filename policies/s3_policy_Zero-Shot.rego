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
# Entrada:
# - input.resource_changes (Terraform plan em JSON)
#
# Compatível com OPA 1.11.0 (Rego v1 – sintaxe com `if`)

deny[msg] if {
    # Itera sobre as mudanças de recursos do plano
    rc := input.resource_changes[_]

    # Apenas o recurso desejado
    rc.type == "aws_s3_bucket_public_access_block"

    # Apenas quando houver criação do recurso
    rc.change.actions[_] == "create"

    # Estado final planejado
    after := rc.change.after

    # Lista dos campos obrigatórios de proteção
    public_access_flags := [
        after.block_public_acls,
        after.block_public_policy,
        after.ignore_public_acls,
        after.restrict_public_buckets
    ]

    # Se QUALQUER um deles for false, a política nega
    public_access_flags[_] == false

    # Mensagem de erro retornada pelo deny
    msg := sprintf(
        "Criação negada: o recurso %s (%s) possui configurações inseguras de acesso público ao S3. Todos os atributos de Public Access Block devem ser true.",
        [rc.name, rc.address]
    )
}
