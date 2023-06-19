resource aws_iam_user coreint {
  name          = "base-framework"
  force_destroy = true
}

resource aws_iam_access_key coreint {
  user = aws_iam_user.coreint.name
}

resource aws_iam_policy access_to_terraform_states {
  name        = "access-to-terraform-states"
  description = "This policy allows to store and access tfstates in the bucket ${aws_s3_bucket.tfstates.bucket}"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
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
      }
    ]
  })
}

resource aws_iam_policy access_to_new_terraform_states {
  name        = "access-to-new-terraform-states"
  description = "This policy allows to store and access tfstates in the bucket coreint-canaries"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = "arn:aws:s3:::coreint-canaries"
        Action   = [
          "s3:ListBucket"
        ]
      }, {
        Effect   = "Allow"
        Resource = "arn:aws:s3:::coreint-canaries/*"
        Action   = [
          "s3:GetObject",
          "s3:PutObject"
        ]
      }, {
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:*:*:table/coreint-canaries"
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
      }
    ]
  })
}

resource aws_iam_policy access_to_eks_cluster {
  name        = "access-to-eks-cluster"
  description = "This policy allows to access all EKS clusters in this account"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
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

resource aws_iam_user_policy_attachment coreint_access_to_terraform_states {
  user       = aws_iam_user.coreint.name
  policy_arn = aws_iam_policy.access_to_terraform_states.arn
}

resource aws_iam_user_policy_attachment coreint_access_to_new_terraform_states {
  user       = aws_iam_user.coreint.name
  policy_arn = aws_iam_policy.access_to_new_terraform_states.arn
}

resource aws_iam_user_policy_attachment coreint_access_to_eks_cluster {
  user       = aws_iam_user.coreint.name
  policy_arn = aws_iam_policy.access_to_eks_cluster.arn
}

resource local_file credentials_file {
  filename = pathexpand("~/.aws/shared-credentials/base-framework/credentials")  # HARDCODED
  directory_permission = "0700"
  file_permission = "0400"
  content  = jsonencode({
    "Version" : 1
    "AccessKeyId" : aws_iam_access_key.coreint.id
    "SecretAccessKey" : aws_iam_access_key.coreint.secret
  })
}

output iam_team_user {
  value = {
    aws_iam_user = {
      coreint = {
        arn = aws_iam_user.coreint.arn
      }
    }
  }
}
