resource "random_id" "project" {
  byte_length = 3
  count       = contains(var.envs, var.environment) ? 1 : 0
}

module "prj_container" {
  source = "./vendor/modules/folder"
  
  name   = var.name
  parent = var.parent

  envs         = var.envs
  environment  = var.environment
}

resource "google_project" "project" {
  auto_create_network = false
  billing_account     = var.billing_account
  folder_id           = module.prj_container.name
  labels              = {}
  name                = var.name
  project_id          = "${var.name}-${random_id.project[0].hex}"
  count               = contains(var.envs, var.environment) ? 1 : 0
  timeouts {}

  depends_on = [random_id.project, module.prj_container]
}

##### Should move into module for resource. #####

#data "google_compute_regions" "available" {
#  count   = contains(var.envs, var.environment) ? 1 : 0
#  project = google_project.project[0].project_id
#}

#resource "google_compute_resource_policy" "auto_snapshot_policy" {
#  count   = contains(var.envs, var.environment) ? length([for x in data.google_compute_regions.available[0].names: x if substr(x, 0, 3) == "us-"]) : 0
#  project = google_project.project[0].project_id
#  name    = "auto-${[for x in data.google_compute_regions.available[0].names: x if substr(x, 0, 3) == "us-"][count.index]}-backups"
#  region  = [for x in data.google_compute_regions.available[0].names: x if substr(x, 0, 3) == "us-"][count.index]
#  snapshot_schedule_policy {
#    schedule {
#      daily_schedule {
#        days_in_cycle = var.snapshots.days_in_cycle
#        start_time     = var.snapshots.start_time
#      }
#    }
#    retention_policy {
#      max_retention_days    = var.snapshots.max_retention_days
#      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
#    }
#    snapshot_properties {
#      storage_locations = var.snapshots.storage_locations
#      guest_flush       = false
#    }
#  }
#}
