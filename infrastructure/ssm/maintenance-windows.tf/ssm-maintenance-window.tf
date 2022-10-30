resource "aws_ssm_maintenance_window" "window" {
  name     = "maintenance-window-stop-Instance"
  description = "Demo hector"
  schedule = "cron( 0 19 ? * * *  )"
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
    key    = "tag:Name"
    values = ["hector"]
  }
}

resource "aws_ssm_maintenance_window_task" "example" {
  max_concurrency = 2
  max_errors      = 1
  priority        = 1
  task_arn        = "AWS-StopEC2Instance"
  task_type       = "AUTOMATION"
  window_id       = aws_ssm_maintenance_window.window.id

  targets {
    key    ="WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.target1.id]
  }

}