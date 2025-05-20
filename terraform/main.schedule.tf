resource "google_pubsub_topic" "pubsub-snapshots" {
  count  = contains(var.envs, var.environment) ? 1 : 0
  project = module.snapshots.id
  name = "pubsub-${module.snapshots.name}-${random_id.random[0].hex}"
}

resource "google_app_engine_application" "app" {
  count       = contains(var.envs, var.environment) ? 1 : 0
  project     = module.snapshots.id
  location_id = "us-east1"
  depends_on  = [
    google_project_service.app_engine[0]
  ]
}

resource "google_cloud_scheduler_job" "scheduler-job-snapshots" {
  count  = contains(var.envs, var.environment) ? 1 : 0
  project     = module.snapshots.id
  name        = "scheduler-job-${module.snapshots.name}-${random_id.random[0].hex}"
  description = "scheduler-job-${module.snapshots.name}-${random_id.random[0].hex}"
  schedule    = "0 5 * * *"
  region      = "us-east1"
  pubsub_target {
    topic_name = google_pubsub_topic.pubsub-snapshots[0].id
    data = base64encode("{\"daysInCycle\": 1, \"startTime\": \"00:00\", \"maxRetentionDays\": 6, \"storageLocations\": [\"us\"]}")
  }
  retry_config {
    retry_count          = 0
    max_retry_duration   = "0s"
    min_backoff_duration = "5s"
    max_backoff_duration = "3600s"
    max_doublings        = 5
  }
  depends_on = [
    google_project_service.cloud_scheduler[0],
    google_project_service.app_engine[0],
    google_app_engine_application.app[0]
  ]
}

resource "google_cloudfunctions_function" "function-snapshots" {
  count                 = contains(var.envs, var.environment) ? 1 : 0
  project               = module.snapshots.id
  name                  = "function-${module.snapshots.name}-${random_id.random[0].hex}"
  description           = "function-${module.snapshots.name}-${random_id.random[0].hex}"
  runtime               = "nodejs14"
  region                = "us-east1"
  available_memory_mb   = 256
  timeout               = 60
  source_archive_bucket = google_storage_bucket.bucket[0].name
  source_archive_object = google_storage_bucket_object.archive[0].name
  service_account_email = google_service_account.svc-check-snapshots[0].email
  entry_point           = "helloPubSub"
  event_trigger {
      event_type = "google.pubsub.topic.publish"
      resource   = google_pubsub_topic.pubsub-snapshots[0].id
   }
  depends_on            = [google_project_service.cloud_functions[0], google_project_service.cloud_build[0]]
}
