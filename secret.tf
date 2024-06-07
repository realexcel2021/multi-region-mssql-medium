resource "random_string" "this" {
  length = 5
  special = false
}

resource "aws_secretsmanager_secret" "db_pass" {
  name = "db_pass_mssql-${random_string.this.result}"

  replica {
    region = local.region2
  }

}

resource "random_password" "password" {
  length           = 16
  special          = true
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = <<EOF
    {
        "password": "${random_password.password.result}",
        "username": "replica_mssql"
    }
  EOF
}