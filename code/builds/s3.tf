provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "dev_s3" {
  bucket_prefix = "dev-"

  tags = {
    Environment          = "Dev"
    git_commit           = "b627306a202c16c6e404d45db894dd9485f3666f"
    git_file             = "code/builds/s3.tf"
    git_last_modified_at = "2024-04-10 16:10:42"
    git_last_modified_by = "104196755+jaco-van-zyl-derivco@users.noreply.github.com"
    git_modifiers        = "104196755+jaco-van-zyl-derivco"
    git_org              = "jaco-van-zyl-derivco"
    git_repo             = "prisma-cloud-devsecops-workshop"
    yor_name             = "dev_s3"
    yor_trace            = "e63095d4-07d0-4c84-85f2-6f9db7e124ad"
  }
}

resource "aws_s3_bucket_ownership_controls" "dev_s3" {
  bucket = aws_s3_bucket.dev_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
