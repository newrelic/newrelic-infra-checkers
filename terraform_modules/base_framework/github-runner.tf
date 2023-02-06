locals {
  repositories_with_e2e_access = [
    "repo:newrelic/nri-oracledb:*",
    "repo:newrelic/nri-f5:*",
  ]
  repositories_with_tfstates_access = [
    "repo:newrelic/coreint-canaries:*",
  ]
}

# ############################################################################
#  OIDC Provider and IAM role for the token sent to Github
# ############################################################################
resource aws_iam_openid_connect_provider github {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource aws_iam_role github_role_for_e2e {
  name        = "github-role-for-e2e"
  description = "Role assumed by the GitHub OIDC provider for e2e"

  assume_role_policy = jsonencode({
    "Version"   = "2012-10-17",
    "Statement" = [
      {
        "Effect"    = "Allow",
        "Action"    = "sts:AssumeRoleWithWebIdentity",
        "Principal" = {
          "Federated" = aws_iam_openid_connect_provider.github.arn
        }
        "Condition" = {
          "StringEquals" = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
          }
          "ForAnyValue:StringLike" : {
            "token.actions.githubusercontent.com:sub" : local.repositories_with_e2e_access
          }
        }
      }
    ]
  })
}

resource aws_iam_policy access_to_fargate {
  name        = "test-policy"
  description = "A test policy"

  policy = jsonencode({
    "Version"   = "2012-10-17",
    "Statement" = [
      {
        "Effect"   = "Allow",
        "Resource" = "*",
        "Action"   = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "logs:GetLogEvents",
        ]
      },
      {
        "Effect"    = "Allow",
        "Action"    = "iam:PassRole",
        "Resource"  = "*",
        "Condition" = {
          "StringLike" = {
            "iam:PassedToService" : "ecs-tasks.amazonaws.com",
          }
        }
      }
    ]
  })
}

resource aws_iam_role_policy_attachment github_role_for_e2e_access_to_fargate {
  role       = aws_iam_role.github_role_for_e2e.name
  policy_arn = aws_iam_policy.access_to_fargate.arn
}

resource aws_iam_role_policy_attachment github_role_for_e2e_access_to_terraform_states {
  role       = aws_iam_role.github_role_for_e2e.name
  policy_arn = aws_iam_policy.access_to_terraform_states.arn
}


resource aws_iam_role github_role_for_tfstates {
  name        = "github-role-to-access-to-tfstates"
  description = "Role assumed by the GitHub OIDC provider that allows access to save terraform states"

  assume_role_policy = jsonencode({
    "Version"   = "2012-10-17",
    "Statement" = [
      {
        "Effect"    = "Allow",
        "Action"    = "sts:AssumeRoleWithWebIdentity",
        "Principal" = {
          "Federated" = aws_iam_openid_connect_provider.github.arn
        }
        "Condition" = {
          "StringEquals" = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
          }
          "ForAnyValue:StringLike" : {
            "token.actions.githubusercontent.com:sub" : local.repositories_with_tfstates_access
          }
        }
      }
    ]
  })
}

resource aws_iam_role_policy_attachment github_role_for_tfstates_access_to_terraform_states {
  role       = aws_iam_role.github_role_for_tfstates.name
  policy_arn = aws_iam_policy.access_to_terraform_states.arn
}


# ############################################################################
#  ECS Cluster to run tasks and log group
# ############################################################################
resource aws_ecs_cluster github_task_runner {
  name = "github-task-runner"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}


resource aws_ecs_cluster_capacity_providers github_task_runner {
  cluster_name = aws_ecs_cluster.github_task_runner.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
}


resource aws_cloudwatch_log_group github_task_runner {
  name              = "/ecs/github-task-runner"
  retention_in_days = 14
}


# ############################################################################
#  Fargate IAM for tasks
# ############################################################################
resource aws_iam_role fargate_for_github_tasks__task_role {
  name = "fargate-for-github-tasks--task-role"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  assume_role_policy = jsonencode({
    "Version"   = "2012-10-17",
    "Statement" = [
      {
        "Effect"    = "Allow",
        "Action"    = "sts:AssumeRole",
        "Principal" = {
          "Service" = ["ecs-tasks.amazonaws.com"]
        }
      }
    ]
  })
}


resource aws_iam_role fargate_for_github_tasks__execution_role {
  name = "fargate-for-github-tasks--execution-role"

  assume_role_policy = jsonencode({
    "Version"   = "2012-10-17",
    "Statement" = [
      {
        "Effect"    = "Allow",
        "Action"    = "sts:AssumeRole",
        "Principal" = {
          "Service" = ["ecs-tasks.amazonaws.com"]
        }
      }
    ]
  })

  inline_policy {
    name   = "AllowToWriteLogs"
    policy = jsonencode({
      "Version"   = "2012-10-17",
      "Statement" = [
        {
          "Effect" : "Allow",
          "Action" : [
            # "ecr:GetAuthorizationToken",
            # "ecr:BatchCheckLayerAvailability",
            # "ecr:GetDownloadUrlForLayer",
            # "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}


# ############################################################################
#  Outputs
# ############################################################################
output github_runner {
  value = {
    aws_iam_role = {
      github_role_for_e2e = {
        arn  = aws_iam_role.github_role_for_e2e.arn
        name = aws_iam_role.github_role_for_e2e.name
      }
      github_role_for_tfstates = {
        arn  = aws_iam_role.github_role_for_tfstates.arn
        name = aws_iam_role.github_role_for_tfstates.name
      }
      task_role = {
        arn  = aws_iam_role.fargate_for_github_tasks__task_role.arn
        name = aws_iam_role.fargate_for_github_tasks__task_role.name
      }
      execution_role = {
        arn  = aws_iam_role.fargate_for_github_tasks__execution_role.arn
        name = aws_iam_role.fargate_for_github_tasks__execution_role.name
      }
    },
    aws_ecs_cluster = {
      github_task_runner = {
        name = aws_ecs_cluster.github_task_runner.name
      }
    }
    aws_cloudwatch_log_group = {
      github_task_runner = {
        name   = aws_cloudwatch_log_group.github_task_runner.name
        region = data.aws_region.current.name
      }
    }
  }
}
