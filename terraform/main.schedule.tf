resource "google_pubsub_topic" "pubsub-snapshots" {
  name = "pubsub-${local.project.name}-${random_id.random.hex}"
  project = local.project.id
}

resource "google_app_engine_application" "app" {
  project     = local.project.id
  location_id = "us-east1"
  depends_on = [
    google_project_service.app_engine
  ]
}

resource "google_cloud_scheduler_job" "scheduler-job-snapshots" {
  name        = "scheduler-job-${local.project.name}-${random_id.random.hex}"
  description = "scheduler-job-${local.project.name}-${random_id.random.hex}"
  schedule    = "0 5 * * *"
  region      = "us-east1"
  project     = local.project.id
  pubsub_target {
    topic_name = google_pubsub_topic.pubsub-snapshots.id
    data = base64encode("{\"daysInCycle\": 1, \"startTime\": \"00:00\", \"maxRetentionDays\": 4, \"storageLocations\": [\"us\"]}")
  }
  retry_config {
    retry_count = 0
    max_retry_duration = "0s"
    min_backoff_duration = "5s"
    max_backoff_duration = "3600s"
    max_doublings = 5
  }
  depends_on = [
    google_project_service.cloud_scheduler,
    google_project_service.app_engine,
    google_app_engine_application.app
  ]
}

resource "google_cloudfunctions_function" "function-snapshots" {
  name        = "function-${local.project.name}-${random_id.random.hex}"
  description = "function-${local.project.name}-${random_id.random.hex}"
  runtime     = "nodejs14"
  project     = local.project.id
  region      = "us-east1"
  available_memory_mb   = 256
  timeout               = 60
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  service_account_email = google_service_account.svc-check-snapshots.email
  entry_point           = "helloPubSub"
  event_trigger {
      event_type= "google.pubsub.topic.publish"
      resource = google_pubsub_topic.pubsub-snapshots.id
   }
  depends_on = [google_project_service.cloud_functions, google_project_service.cloud_build]
}
