# Add this at the top of your pipeline-role.tf file
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-terraform-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# Your existing policy code
resource "aws_iam_policy" "codepipeline_policy" {
  name        = "codepipeline-terraform-policy"
  description = "Policy for CodePipeline to access required services"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl",
          "s3:ListBucket"
        ],
        Resource = [
          "${aws_s3_bucket.pipeline_artifacts.arn}",
          "${aws_s3_bucket.pipeline_artifacts.arn}/*"
        ]
      },
      # Add a broader S3 permission for website buckets
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::dev-website-*",
          "arn:aws:s3:::dev-website-*/*",
          "arn:aws:s3:::prod-website-*",
          "arn:aws:s3:::prod-website-*/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = "arn:aws:codestar-connections:eu-west-2:061051257340:connection/b81bf3ee-47f8-44a1-ad8d-e0ab22666ae9"
      }
    ]
  })
}

# Add this to attach the policy to the role
resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}