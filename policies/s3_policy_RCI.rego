package terraform

# Nega criação (ou replace) de aws_s3_bucket_public_access_block
# quando qualquer flag de proteção estiver false

deny[msg] if {
    rc := input.resource_changes[_]

    # Tipo do recurso
    rc.type == "aws_s3_bucket_public_access_block"

    # Create ou Replace (create aparece em ambos os casos)
    rc.change.actions[_] == "create"

    # Garante que existe estado final
    rc.change.after != null
    after := rc.change.after

    # Verifica configurações inseguras
    insecure_public_access(after)

    msg := sprintf(
        "Criação negada: o recurso %s possui configurações inseguras de acesso público ao S3. Todos os atributos de Public Access Block devem ser true.",
        [rc.address]
    )
}

############################
# Regras auxiliares (Rego v1)
############################

insecure_public_access(after) if {
    object.get(after, "block_public_acls", true) == false
}

insecure_public_access(after) if {
    object.get(after, "block_public_policy", true) == false
}

insecure_public_access(after) if {
    object.get(after, "ignore_public_acls", true) == false
}

insecure_public_access(after) if {
    object.get(after, "restrict_public_buckets", true) == false
}
