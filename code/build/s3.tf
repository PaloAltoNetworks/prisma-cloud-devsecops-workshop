provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "dev_s3" {
  bucket_prefix = "dev-"

  tags = {
    Environment          = "Dev"
    git_commit           = "faf529e349de596b5281ae30f878e2062e2b4a4c"
    git_file             = "code/build/s3.tf"
    git_last_modified_at = "2024-04-10 15:58:12"
    git_last_modified_by = "104196755+jaco-van-zyl-derivco@users.noreply.github.com"
    git_modifiers        = "104196755+jaco-van-zyl-derivco"
    git_org              = "jaco-van-zyl-derivco"
    git_repo             = "prisma-cloud-devsecops-workshop"
    yor_name             = "dev_s3"
    yor_trace            = "6f998e11-9676-4fe0-9446-02748b26bf78"
  }
}

resource "aws_s3_bucket_ownership_controls" "dev_s3" {
  bucket = aws_s3_bucket.dev_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

