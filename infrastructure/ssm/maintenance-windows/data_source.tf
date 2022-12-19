data "aws_instances" "instances_id" {

  filter {
    name   = var.filter_key_tag
    values = ["${var.filter_value_tag}"]
  }
}

