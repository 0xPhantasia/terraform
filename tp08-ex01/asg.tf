resource "aws_autoscaling_group" "nextcloud_asg" {
  name                = "${local.name}-nextcloud-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = values(aws_subnet.private_subnets)[*].id

  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.nextcloud.arn]
  
  depends_on = [aws_lb.nextcloud]

  launch_template {
    id      = aws_launch_template.nextcloud.id
    version = "$Latest"
  }

  tag {
    key                 = "Owner"
    value               = local.user
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scaleout_policy" {
  name                   = "${local.user}-${local.tp}-nextcloud-scaleout"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.nextcloud_asg.name
}

resource "aws_autoscaling_policy" "scalein_policy" {
  name                   = "${local.user}-${local.tp}-nextcloud-scalein"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.nextcloud_asg.name
}
