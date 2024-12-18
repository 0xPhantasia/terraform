resource "aws_autoscaling_group" "nextcloud" {
  name                      = "${local.name}-nextcloud"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300

  # Utiliser les subnets privés sur les 3 AZ
  vpc_zone_identifier = values(aws_subnet.private_subnets)[*].id

  # Utiliser le Launch Template nouvellement créé
  launch_template {
    id      = aws_launch_template.nextcloud.id
    version = "$Latest"
  }

  # Attache l'ASG au target group de l'ALB
  target_group_arns = [aws_lb_target_group.nextcloud.arn]

  # Permet une mise à jour propre (évite de détruire avant de créer une nouvelle instance)
  lifecycle {
    create_before_destroy = true
  }

  # Tags de l'ASG
  tag {
    key                 = "Owner"
    value               = local.user
    propagate_at_launch = false
  }
}
