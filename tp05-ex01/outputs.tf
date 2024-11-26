#data "aws_instances" "instances_list" {
#  filter {
#    name = "tag:Owner"
#    values = [local.user]
#  }
#}

#output "instances_list" {
#  value = "${data.aws_instances.instances_list}"
#}

data "aws_instance" "instance_details" {
  for_each = toset(data.aws_instances.instances.ids)
  instance_id = each.value
}

output "public_ips" {
  value = [for instance in data.aws_instance.instance_details : instance.public_ip]
}

output "private_ips" {
  value = [for instance in data.aws_instance.instance_details : instance.private_ip]
}

#output "public_ips" {
#  value = [for instance in data.aws_instances.instances_list : aws_instance.instance.private_ip]
#}
#
#output "private_ips" {
#  value = [for instance in data.aws_instances.instances_list : aws_instance.instance.private_ip]
#}