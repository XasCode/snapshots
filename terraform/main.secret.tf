resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "SENDGRID_API_KEY"
  project = local.project.id
  replication {
    automatic = true
  }

  depends_on = [google_project_service.secretmanager]
}


resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret = google_secret_manager_secret.secret-basic.id
  secret_data = var.sg

  depends_on = [google_project_service.secretmanager]
}
