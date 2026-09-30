resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kong" {
  key_name   = "${var.name_prefix}-${random_id.suffix.hex}"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "ssh_private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/${var.name_prefix}.pem"
  file_permission = "0600"
}

resource "aws_instance" "kong" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.kong.id]
  key_name                    = aws_key_pair.kong.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {})

  tags = {
    Name = "${var.name_prefix}-kong"
  }
}

resource "aws_eip" "kong" {
  domain   = "vpc"
  instance = aws_instance.kong.id

  tags = {
    Name = "${var.name_prefix}-eip"
  }
}
