resource "local_sensitive_file" "kong_yml" {
  content         = local.kong_yml
  filename        = "${path.module}/.generated/kong.yml"
  file_permission = "0600"
}

resource "terraform_data" "kong_install" {
  triggers_replace = {
    instance_id  = aws_instance.kong.id
    eip          = aws_eip.kong.public_ip
    kong_image   = var.kong_image
    license_sha  = filesha256(local.license_abs)
    kong_yml_sha = sha256(local.kong_yml)
    install_sha  = filesha256("${path.module}/scripts/install-kong.sh")
  }

  connection {
    type        = "ssh"
    host        = aws_eip.kong.public_ip
    user        = "ec2-user"
    private_key = tls_private_key.ssh.private_key_pem
    timeout     = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/kong-workshop",
    ]
  }

  provisioner "file" {
    source      = local.license_abs
    destination = "/tmp/kong-workshop/license.json"
  }

  provisioner "file" {
    source      = local_sensitive_file.kong_yml.filename
    destination = "/tmp/kong-workshop/kong.yml"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install-kong.sh"
    destination = "/tmp/kong-workshop/install-kong.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kong-workshop/install-kong.sh",
      "KONG_IMAGE='${var.kong_image}' PUBLIC_IP='${aws_eip.kong.public_ip}' bash /tmp/kong-workshop/install-kong.sh",
    ]
  }

  depends_on = [
    aws_eip.kong,
    aws_security_group.kong,
    local_sensitive_file.kong_yml,
  ]
}
