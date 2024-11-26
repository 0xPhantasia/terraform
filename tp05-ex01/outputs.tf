data "aws_instances" "instances_list" {
  filter {
    name = "tag:Owner"
    values = [local.user]
  }
}

output "instances_list" {
  value = "${data.aws_instances.instances_list}"
}

output "public_ips" {
  value = [for instance in data.aws_instances.instances_list : aws_instance.instance.private_ip]
}

output "private_ips" {
  value = [for instance in data.aws_instances.instances_list : aws_instance.instance.private_ip]
}