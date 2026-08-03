data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ---- Task Execution Role ----
# Used by ECS to pull images from ECR and write logs to CloudWatch.

resource "aws_iam_role" "ecs_exec" {
  name               = "${var.name_prefix}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(var.tags, { Name = "${var.name_prefix}-ecs-exec-role" })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---- Task Role ----
# Assumed by the running container. Stockroom does not currently require
# additional AWS permissions (no S3 or SSM access), but this role exists
# so permissions can be attached here without changing the task definition.

resource "aws_iam_role" "ecs_task" {
  name               = "${var.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(var.tags, { Name = "${var.name_prefix}-ecs-task-role" })
}
