# Default tags
locals {
  user = "emestre"
  tp   = basename(abspath(path.root)) # Get the name of the current directory
  name = "${local.user}-${local.tp}"  # Concatenate the username and the directory name
  tags = {                            # Define a map of tags to apply to all resources
    Name  = local.name
    Owner = local.user
  }
}

# Generate the user data for the Nextcloud instance
locals {
  nextcloud_userdata = templatefile("${path.module}/userdata/nextcloud.sh.tftpl",
    {
      efs_dns = aws_efs_file_system.nextcloud.dns_name,
      db_name = aws_db_instance.nextcloud.db_name,
      db_host = aws_db_instance.nextcloud.address,
      db_user = aws_db_instance.nextcloud.username,
      db_pass = random_password.nextcloud.result,
      fqdn    = aws_route53_record.nextcloud.fqdn,
  })
}