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
