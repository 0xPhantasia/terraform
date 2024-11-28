#data "aws_subnet_ids" "private_subnet_ids" {
#  for_each = data.aws_subnet_ids.example.ids
#  id       = each.value
#}
#
#data "aws_subnet_ids" "private_subnet_ids" {
#  for_each = aws.private_subnets.id
#  id       = each.value
#}

# Create EFS
resource "aws_efs_file_system" "nextcloud-efs" {
  creation_token = local.name
  encrypted = true # Au repos ?
}

# Mount EFS to EC2 instances to every private subnet
resource "aws_efs_mount_target" "nextcloud-efs-mount" {
  file_system_id = aws_efs_file_system.nextcloud-efs.id
  for_each = aws_subnet.private_subnets
  subnet_id      = each.value.id
  security_groups = [
    aws_security_group.efs-sg.id
  ]
}
