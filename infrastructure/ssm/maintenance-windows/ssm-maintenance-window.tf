resource "aws_ssm_maintenance_window" "window" {
  name     = "maintenance-window-stop-Instance"
  description = "Demo hector"
  #schedule = "cron( 00 19 ? * * *  )"
  schedule = "rate(40 minutes)"
  duration = 1
  cutoff   = 0
  schedule_timezone = "America/Lima"
}

resource "aws_ssm_maintenance_window_target" "target1" {
  window_id     = aws_ssm_maintenance_window.window.id
  name          = "maintenance-window-target"
  description   = "This is a maintenance window target - Hector"
  resource_type = "INSTANCE"

  targets {
    key    = "${var.filter_key_tag}"
    values = ["${var.filter_value_tag}"]
  }
}

resource "aws_ssm_maintenance_window_task" "example" {
  max_concurrency = 2
  max_errors      = 1
  priority        = 1
  task_arn        = "AWS-StopEC2Instance"
  task_type       = "AUTOMATION"
  window_id       = aws_ssm_maintenance_window.window.id
  service_role_arn = aws_iam_role.ssm-maintenance-role.arn
  #count    = length(data.aws_instances.instances_id.ids)
  targets {
    key    ="WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.target1.id]
  }
  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"
      parameter {
        name   = "InstanceId"
        #values = ["i-0affea130a595560c"]
        values = toset(data.aws_instances.instances_id.ids)
    }
  }
  }
}