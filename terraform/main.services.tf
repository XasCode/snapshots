resource "google_project_service" "cloud_scheduler" {
  project = module.snapshots.id
  service = "cloudscheduler.googleapis.com"
  timeouts {
    create = "3m"
    update = "6m"
  }
  disable_dependent_services = true
}

resource "google_project_service" "app_engine" {
  project = module.snapshots.id
  service = "appengine.googleapis.com"
  timeouts {
    create = "3m"
    update = "6m"
  }
  disable_dependent_services = true
}

resource "google_project_service" "cloud_functions" {
  project = module.snapshots.id
  service = "cloudfunctions.googleapis.com"
  timeouts {
    create = "3m"
    update = "6m"
  }
  disable_dependent_services = true
}

resource "google_project_service" "cloud_build" {
  project = module.snapshots.id
  service = "cloudbuild.googleapis.com"
  timeouts {
    create = "3m"
    update = "6m"
  }
  disable_dependent_services = true
}

resource "google_project_service" "cloud_resource_manager" {
  project = module.snapshots.id
  service = "cloudresourcemanager.googleapis.com"
  timeouts {
    create = "3m"
    update = "6m"
  }
  disable_dependent_services = true
}

resource "google_project_service" "secretmanager" {
  project = module.snapshots.id
  service = "secretmanager.googleapis.com"
  timeouts {
    create = "3m"
    update = "6m"
  }
  disable_dependent_services = true
}

