resource "aws_security_group" "kong" {
  name        = "${var.name_prefix}-${random_id.suffix.hex}"
  description = "Kong AI workshop proxy/admin"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Kong proxy (students)"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kong Admin API (operator IP)"
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = [local.operator_cidr]
  }

  ingress {
    description = "Kong Manager GUI (operator IP)"
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = [local.operator_cidr]
  }

  ingress {
    description = "SSH (operator IP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.operator_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-sg"
  }
}
