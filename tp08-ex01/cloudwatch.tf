resource "aws_cloudwatch_metric_alarm" "scaleout_alarm" {
  alarm_name          = "${local.user}-${local.tp}-nextcloud-asg-scaleout"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1000
  alarm_actions       = [aws_autoscaling_policy.scaleout_policy.arn]

  dimensions = {
    TargetGroup  = aws_lb_target_group.nextcloud.arn_suffix
    LoadBalancer = aws_lb.nextcloud.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "scalein_alarm" {
  alarm_name          = "${local.user}-${local.tp}-nextcloud-asg-scalein"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 400
  alarm_actions       = [aws_autoscaling_policy.scalein_policy.arn]

  dimensions = {
    TargetGroup  = aws_lb_target_group.nextcloud.arn_suffix
    LoadBalancer = aws_lb.nextcloud.arn_suffix
  }
}

resource "aws_cloudwatch_dashboard" "nextcloud" {
  dashboard_name = "${local.name}-nextcloud-asg"
  dashboard_body = jsonencode({
    periodOverride = "inherit"
    start          = "-PT30M"
    widgets = [
      {
        height = 6
        properties = {
          legend = {
            position = "bottom"
          }
          liveData = true
          metrics = [
            [
              "AWS/AutoScaling",
              "GroupInServiceInstances",
              "AutoScalingGroupName",
              aws_autoscaling_group.nextcloud_asg.name,
              {
                color = "#2ca02c",
                label = "InServiceInstances"
              },
            ],
            [
              ".",
              "GroupTerminatingInstances",
              ".",
              ".",
              {
                color = "#d62728",
                label = "TerminatingInstances"
              },
            ],
          ]
          period = 60
          region = "eu-north-1"
          stat   = "Average"
          title  = "ASG - In Service/Terminating Instances"
        }
        type  = "metric"
        width = 24
        x     = 0
        y     = 0
      },
      {
        height = 6
        properties = {
          annotations = {
            horizontal = [
              {
                color = "#2ca02c",
                label = "Add Instance",
                value = 1000
              },
              {
                color = "#d62728",
                label = "Remove Instance",
                value = 400
              },
            ]
          }
          legend = {
            position = "bottom"
          }
          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCountPerTarget",
              "TargetGroup",
              aws_lb_target_group.nextcloud.arn_suffix,
            ],
          ]
          period = 60
          region = "eu-north-1"
          stat   = "Sum"
          title  = "ALB - Request Count Per Target"
        }
        type  = "metric"
        width = 24
        x     = 0
        y     = 6
      },
    ]
  })
}
