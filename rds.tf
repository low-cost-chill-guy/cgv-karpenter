resource "aws_db_subnet_group" "chill-dbsg" {
  name       = "${var.tag}-dbsg"
  subnet_ids = [
    aws_subnet.eksnet_work[0].id,  # AZ-A 서브넷
    aws_subnet.eksnet_work[1].id   # AZ-C 서브넷
  ]
}
# Primary DB 인스턴스 (가용 영역 A - 쓰기 인스턴스)
resource "aws_db_instance" "chill_dbins_a_write" {
  allocated_storage      = 20
  storage_type          = "gp3"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  db_name               = var.db_name
  identifier            = "chilldb-a-write"
  username              = var.db_username
  password              = var.db_password
  parameter_group_name  = "default.mysql8.0"
  multi_az              = false
  db_subnet_group_name  = aws_db_subnet_group.chill-dbsg.id
  vpc_security_group_ids = [aws_security_group.eks_secu.id]
  skip_final_snapshot   = true
  backup_retention_period = 7  # 백업 보존 기간 설정 (7일)
  tags = {
    Name = "${var.tag}-db-a-write"
  }
}

# 읽기 인스턴스 (가용 영역 A - 읽기 복제본)
resource "aws_db_instance" "chill_dbins_a_read" {
  allocated_storage      = 20
  storage_type          = "gp3"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  identifier            = "chilldb-a-read"
  replicate_source_db   = aws_db_instance.chill_dbins_a_write.arn  # Primary DB의 ARN 사용
  multi_az              = false
  db_subnet_group_name  = aws_db_subnet_group.chill-dbsg.id
  vpc_security_group_ids = [aws_security_group.eks_secu.id]
  skip_final_snapshot   = true
  tags = {
    Name = "${var.tag}-db-a-read"
  }
}

# Primary DB 인스턴스 (가용 영역 C - 쓰기 인스턴스)
resource "aws_db_instance" "chill_dbins_c_write" {
  allocated_storage      = 20
  storage_type          = "gp3"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  db_name               = var.db_name
  identifier            = "chilldb-c-write"
  username              = var.db_username
  password              = var.db_password
  parameter_group_name  = "default.mysql8.0"
  multi_az              = false
  db_subnet_group_name  = aws_db_subnet_group.chill-dbsg.id
  vpc_security_group_ids = [aws_security_group.eks_secu.id]
  skip_final_snapshot   = true
  backup_retention_period = 7  # 백업 보존 기간 설정 (7일)
  tags = {
    Name = "${var.tag}-db-c-write"
  }
}

# 읽기 인스턴스 (가용 영역 C - 읽기 복제본)
resource "aws_db_instance" "chill_dbins_c_read" {
  allocated_storage      = 20
  storage_type          = "gp3"
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"
  identifier            = "chilldb-c-read"
  replicate_source_db   = aws_db_instance.chill_dbins_c_write.arn  # Primary DB의 ARN 사용
  multi_az              = false
  db_subnet_group_name  = aws_db_subnet_group.chill-dbsg.id
  vpc_security_group_ids = [aws_security_group.eks_secu.id]
  skip_final_snapshot   = true
  tags = {
    Name = "${var.tag}-db-c-read"
  }
}

