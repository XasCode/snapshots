resource "google_storage_bucket" "bucket" {
  name = "snapshots-bucket-${random_id.random.hex}"
  project = local.project.id
}

resource "google_storage_bucket" "backup_records" {
  name = "backup_records_${local.project.id}"
  project = local.project.id
}

resource "google_storage_bucket_object" "archive" {
  name   = "index-${filemd5(data.archive_file.srcfiles.output_path)}.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.srcfiles.output_path
}
