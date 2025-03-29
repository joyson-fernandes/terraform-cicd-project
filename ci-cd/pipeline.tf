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
}

resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "terraform-cicd-artifacts-${random_string.suffix.result}"
  
  tags = {
    Name = "Pipeline Artifacts"
  }
}

resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

# Note: You'll need to manually complete the connection in the AWS console