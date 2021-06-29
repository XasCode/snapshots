resource "google_project_iam_binding" "project" {
  project = module.snapshots.id
  role    = google_organization_iam_custom_role.role-svc-check-snapshots.name
  members = [
    "serviceAccount:${google_service_account.svc-check-snapshots.email}",
  ]
}

resource "google_secret_manager_secret_iam_binding" "binding" {
  project = module.snapshots.id
  secret_id = google_secret_manager_secret.secret-basic.id
  role = google_organization_iam_custom_role.role-svc-check-snapshots.name
  members = [
    "serviceAccount:${google_service_account.svc-check-snapshots.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = google_storage_bucket.backup_records.name
  role = google_organization_iam_custom_role.role-svc-check-snapshots.name
  members = [
    "serviceAccount:${google_service_account.svc-check-snapshots.email}"
  ]
}

