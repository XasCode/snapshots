resource "google_secret_manager_secret" "secret-basic" {
  count     = contains(var.envs, var.environment) ? 1 : 0
  project   = module.snapshots.id
  secret_id = "SENDGRID_API_KEY"
  replication {
    automatic = true
  }

  depends_on = [google_project_service.secretmanager[0]]
}


resource "google_secret_manager_secret_version" "secret-version-basic" {
  count       = contains(var.envs, var.environment) ? 1 : 0
  secret      = google_secret_manager_secret.secret-basic[0].id
  secret_data = var.sg

  depends_on  = [google_project_service.secretmanager[0]]
}
