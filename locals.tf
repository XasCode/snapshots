data "terraform_remote_state" "terraform-devl" {
  backend = "remote"
  config = {
    organization = "xascode"
    workspaces = {
      name = "terraform-devl"
    }
  }
}

locals {
  #project_number = data.terraform_remote_state.terraform-devl.outputs.projects
  project_number = [for x in data.terraform_remote_state.terraform-devl.outputs.projects: x.number if x.path == "dev/xascode/devl/corp/randd/snapshots/snapshots"][0]
}
