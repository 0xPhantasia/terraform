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
resource "aws_efs_file_system" "nextcloud-fs" {
  creation_token = local.name
  encrypted = true # Au repos ?
}

# Mount EFS to EC2 instances member of nextcloud-sg security group
resource "aws_efs_mount_target" "nextcloud-fs-mounts" {
  file_system_id = aws_efs_file_system.nextcloud-fs.id
  for_each = aws_subnet.private_subnets
  subnet_id      = each.value.id
  security_groups = [
    aws_security_group.nextcloud-sg.id
  ]
}
