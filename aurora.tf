# ---------------------------------------------------------------------------
# AWS Aurora resources
# ---------------------------------------------------------------------------

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-product-db"
  engine                  = "aurora-postgresql"
  engine_mode             = "serverless"
  database_name           = var.db_name
  enable_http_endpoint    = true
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 1

  db_subnet_group_name = aws_db_subnet_group.this.name

  skip_final_snapshot     = true

  scaling_configuration {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 4
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}

resource "aws_db_subnet_group" "this" {
  name = "aurora-subnet-group"
  subnet_ids = [for o in aws_subnet.aurora : o.id]
}