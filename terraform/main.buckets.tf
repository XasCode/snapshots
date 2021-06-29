resource "google_storage_bucket" "bucket" {
  name = "snapshots-bucket-${random_id.random.hex}"
  project = module.snapshots.id
}

resource "google_storage_bucket" "backup_records" {
  name = "backup_records_${module.snapshots.id}"
  project = module.snapshots.id
}

resource "google_storage_bucket_object" "archive" {
  name   = "index-${filemd5(var.src_zip)}.zip"
  bucket = google_storage_bucket.bucket.name
  source = var.src_zip
}
