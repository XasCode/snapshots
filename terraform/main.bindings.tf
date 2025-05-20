resource "google_project_iam_binding" "project" {
  project = module.snapshots.id
  role    = google_organization_iam_custom_role.role-svc-check-snapshots[0].name
  members = [
    "serviceAccount:${google_service_account.svc-check-snapshots[0].email}",
  ]
  count   = contains(var.envs, var.environment) ? 1 : 0
}

resource "google_secret_manager_secret_iam_binding" "binding" {
  project   = module.snapshots.id
  secret_id = google_secret_manager_secret.secret-basic[0].id
  role      = google_organization_iam_custom_role.role-svc-check-snapshots[0].name
  members   = [
    "serviceAccount:${google_service_account.svc-check-snapshots[0].email}"
  ]
  count     = contains(var.envs, var.environment) ? 1 : 0
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket  = google_storage_bucket.backup_records[0].name
  role    = google_organization_iam_custom_role.role-svc-check-snapshots[0].name
  members = [
    "serviceAccount:${google_service_account.svc-check-snapshots[0].email}"
  ]
  count   = contains(var.envs, var.environment) ? 1 : 0
}

resource "google_folder_iam_binding" "parent_folder" {
  folder  = var.parent.name
  role    = google_organization_iam_custom_role.role-svc-check-snapshots[0].name
  members = [
    "serviceAccount:${google_service_account.svc-check-snapshots[0].email}",
  ]
  count   = contains(var.envs, var.environment) ? 1 : 0
}
