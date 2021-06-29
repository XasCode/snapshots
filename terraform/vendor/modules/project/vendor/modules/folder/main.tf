resource "google_folder" "folder" {
  display_name = var.name
  parent       = var.parent.name
  count        = contains(var.envs, var.environment) ? 1 : 0
}
