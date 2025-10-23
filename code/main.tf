terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "demo-project-id" # placeholder; not used by Checkov
  region  = "us-central1"
}

# Deliberately misconfigured GCS bucket to trigger findings:
# - uniform_bucket_level_access = false (bad)
# - public IAM member (bad)
resource "google_storage_bucket" "bad_bucket" {
  name                        = "demo-checkov-bad-bucket-12345"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = false  # Checkov should flag CKV_GCP_31
}

resource "google_storage_bucket_iam_member" "public_reader" {
  bucket = google_storage_bucket.bad_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"  # Checkov should flag public access
}

