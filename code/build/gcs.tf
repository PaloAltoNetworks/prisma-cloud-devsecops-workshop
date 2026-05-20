provider "google" {
  project = "qwiklabs-gcp-03-fa7edfd03d8e" ##the project id of you lab instance
  region  = "us-central1"
}

resource "google_storage_bucket" "sample" {
  name          = "demo2-${random_id.Rand_suffix.hex}"
  location      = "us-central1"
  force_destroy = true

  uniform_bucket_level_access = false

  #public_access_prevention = "enforced" ##comment out this line of code for demo
}

resource "random_id" "Rand_suffix" {
  byte_length = 4
}

output "Bucket_name" {
  value = google_storage_bucket.sample.name
}
