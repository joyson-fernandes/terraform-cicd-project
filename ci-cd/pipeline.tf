resource "aws_codepipeline" "terraform_pipeline" {
  name     = "terraform-cicd-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  
  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }
  
  stage {
    name = "Source"
    
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "yourusername/terraform-cicd-project"
        BranchName       = "main"
      }
    }
  }
  
  stage {
    name = "Build"
    
    action {
      name             = "BuildAndTest"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      
      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
      }
    }
  }
  
  stage {
    name = "Deploy_Dev"
    
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"
      
      configuration = {
        BucketName = data.terraform_remote_state.dev.outputs.website_bucket_id
        Extract    = "true"
      }
    }
  }

  stage {
    name = "Approval"
  
    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    
      configuration = {
        CustomData      = "Please review and approve deployment to production"
        NotificationArn = aws_sns_topic.approval_notification.arn
      }
    }
  }

  stage {
    name = "Deploy_Prod"
  
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build_output"]
      version         = "1"
    
      configuration = {
        BucketName = data.terraform_remote_state.prod.outputs.prod_website_bucket_id
        Extract    = "true"
      }
    }
  }
}

# SNS topic for approval notifications
resource "aws_sns_topic" "approval_notification" {
  name = "pipeline-approval-notification"
}

# Subscription to SNS topic
resource "aws_sns_topic_subscription" "approval_email" {
  topic_arn = aws_sns_topic.approval_notification.arn
  protocol  = "email"
  endpoint  = "jf@joysontech.com"  # Replace with your email address
}

# S3 Bucket to store pipeline artifacts
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "terraform-cicd-artifacts-${random_string.suffix.result}"
  
  tags = {
    Name = "Pipeline Artifacts"
  }
}

# GitHub Connection using AWS CodeStar
resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

# Random string suffix used to generate unique bucket names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}