data "aws_instances" "my_instances" {
  filter {
    name = "Owner"
    values = [local.user]
  }
}

output "public_ips" {
  value = [for instance in aws_instance.my_instances : instance.public_ip]
}

output "private_ips" {
  value = [for instance in aws_instance.my_instances : instance.private_ip]
}