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
  project_id = [for x in data.terraform_remote_state.terraform-devl.outputs.projects: x.id if x.path == "dev/xascode/devl/corp/snapshots/snapshots"][0]
  project_name = [for x in data.terraform_remote_state.terraform-devl.outputs.projects: x.name if x.path == "dev/xascode/devl/corp/snapshots/snapshots"][0]
  project_number = [for x in data.terraform_remote_state.terraform-devl.outputs.projects: x.number if x.path == "dev/xascode/devl/corp/snapshots/snapshots"][0]
  project_path = [for x in data.terraform_remote_state.terraform-devl.outputs.projects: x.path if x.path == "dev/xascode/devl/corp/snapshots/snapshots"][0]
  project_dot_path = join(".",split("/", [for x in data.terraform_remote_state.terraform-devl.outputs.projects: x.number if x.path == "dev/xascode/devl/corp/snapshots/snapshots"][0]))
  project_dash_path = join("-",split("/", [for x in data.terraform_remote_state.terraform-devl.outputs.projects: x.number if x.path == "dev/xascode/devl/corp/snapshots/snapshots"][0]))
}
