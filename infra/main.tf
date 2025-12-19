provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    s3 = "http://localhost:4566"
  }
}

# Recurso Vulnerável: Bucket Público e sem Criptografia
resource "aws_s3_bucket" "dados_sensiveis" {
  bucket = "meu-bucket-vulneravel"
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.dados_sensiveis.id

  block_public_acls       = false # PERIGO
  block_public_policy     = false # PERIGO
  ignore_public_acls      = false # PERIGO
  restrict_public_buckets = false # PERIGO
}
