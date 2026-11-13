resource "local_file" "smoke_test" {
  content = templatefile("${path.module}/templates/smoke-test.sh.tftpl", {
    proxy_url       = "http://${aws_eip.kong.public_ip}:8000"
    workshop_apikey = "sk-kong-workshop"
  })
  filename        = "${path.module}/.generated/smoke-test.sh"
  file_permission = "0755"
}
