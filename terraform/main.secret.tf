resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "SENDGRID_API_KEY"
  project = module.snapshots.id
  replication {
    automatic = true
  }
}


resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret = google_secret_manager_secret.secret-basic.id
  secret_data = var.sg
}
