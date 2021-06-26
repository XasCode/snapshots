output "path" {
  description = "The path of this project."
  value = join("", [module.prj_container.path, var.name])
}

output "name" {
  description = "The name of the project."
#  value = google_project.project.name
  value = length(google_project.project) > 0 ? google_project.project[0].name : ""
}

output "id" {
  description = "The project_id."
#  value = google_project.project.project_id
  value = length(google_project.project) > 0 ? google_project.project[0].project_id : ""
}

output "number" {
  description = "The project number."
#  value = google_project.project.number
  value = length(google_project.project) > 0 ? google_project.project[0].number : ""
}
