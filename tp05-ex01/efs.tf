#data "aws_subnet_ids" "private_subnet_ids" {
#  for_each = data.aws_subnet_ids.example.ids
#  id       = each.value
#}
#
#data "aws_subnet_ids" "private_subnet_ids" {
#  for_each = aws.private_subnets.id
#  id       = each.value
#}

resource "aws_efs_file_system" "nextcloud-fs" {
  creation_token = local.name
  encrypted = true # Au repos ?
}

resource "aws_efs_mount_target" "nextcloud-fs-mounts" {
  count          = length(aws.private_subnets) # Assumes 3 subnets, one in each AZ
  file_system_id = aws_efs_file_system.nextcloud-fs.id
  subnet_id      = element(aws.private_subnets.id, count.index)
  security_groups = [
    aws_security_group.efs-sg.id
  ]
}