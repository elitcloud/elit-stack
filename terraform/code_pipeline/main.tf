resource "aws_s3_bucket" "pipeline_bucket" {
  bucket        = "${var.name}-pipeline-bucket"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.name}-codepipeline-role"
  assume_role_policy = "${file("${path.module}/policies/codepipeline_role.json")}"
}

data "template_file" "codepipeline_policy" {
  template = "${file("${path.module}/policies/codepipeline.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.pipeline_bucket.arn}"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.name}-codepipeline_policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.template_file.codepipeline_policy.rendered}"
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.name}-codebuild-role"
  assume_role_policy = "${file("${path.module}/policies/codebuild_role.json")}"
}

data "template_file" "codebuild_policy" {
  template = "${file("${path.module}/policies/codebuild_policy.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.pipeline_bucket.arn}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.name}-codebuild-policy"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}

data "template_file" "buildspec" {
  template = "${file("${path.module}/buildspec.yml")}"

  vars {
    repository_url     = "${var.repository_url}"
    region             = "${var.region}"
    name               = "${var.name}"
    cluster_name       = "${var.ecs_cluster_name}"
    subnet_id          = "${var.run_task_subnet_id}"
    security_group_ids = "${join(",", var.security_groups)}"
  }
}

resource "aws_codebuild_project" "main" {
  name          = "${var.name}-codebuild"
  build_timeout = "30"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"

    // https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    image           = "aws/codebuild/docker:1.12.1"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }
}

/* CodePipeline */

resource "aws_codepipeline" "pipeline" {
  name     = "${var.name}-codepipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.pipeline_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner      = "${var.github_owner}"
        Repo       = "${var.github_repo}"
        Branch     = "${var.github_branch}"
        OAuthToken = "${var.github_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.name}-codebuild"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "${var.ecs_cluster_name}"
        ServiceName = "${var.ecs_service_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
