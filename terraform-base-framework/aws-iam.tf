resource aws_iam_user base_framework {
  name          = "base-framework"
  force_destroy = true
}

resource aws_iam_access_key base_framework {
  user = aws_iam_user.base_framework.name
}


resource aws_iam_user_policy access_to_terraform_states {
  name = "access-to-terraform-states"
  user = aws_iam_user.base_framework.name

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      # S3 access for tfstates
      {
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.tfstates.bucket}"
        Action   = [
          "s3:ListBucket"
        ]
      }, {
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.tfstates.bucket}/*"
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ]
      }, {
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.tfstates.name}"
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
      },
      # EKS access
      {
        Effect   = "Allow",
        Resource = "arn:aws:eks:*:*:cluster/*"
        Action   = [
          "ssm:GetParameter",
        ]
      }, {
        Effect   = "Allow",
        Resource = "arn:aws:eks:*:*:addon/*"
        Action   = [
          "eks:ListAddons",
          "eks:DescribeAddonAddons",
          "eks:DescribeAddonAddonsVersion",
        ]
      }, {
        Effect   = "Allow",
        Resource = "arn:aws:eks:*:*:cluster/*"
        Action   = [
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:ListClusters",
        ]
      }, {
        Effect   = "Allow",
        Resource = "arn:aws:eks:*:*:fargateprofile/*"
        Action   = [
          "eks:DescribeFargateProfile",
          "eks:ListFargateProfiles",
        ]
      }, {
        Effect   = "Allow",
        Resource = "arn:aws:eks:*:*:nodegroup/*"
        Action   = [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
        ]
      }
    ]
  })
}

resource local_file credentials_file {
  filename = pathexpand("~/.aws/shared-credentials/base-framework/credentials")  # HARDCODED
  content  = jsonencode({
    "Version" : 1
    "AccessKeyId" : aws_iam_access_key.base_framework.id
    "SecretAccessKey" : aws_iam_access_key.base_framework.secret
  })
}

output iam {
  value = {
    aws_iam_user = {
      base_framework = {
        arn = aws_iam_user.base_framework.arn
      }
    }
  }
}
