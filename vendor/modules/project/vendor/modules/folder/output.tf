output "path" {
  description = "The path of this folder"
  value = "${join("", [var.parent.path, var.name])}/"
}

output "name" {
  description = "The name of the folder. Its format is folders/{folder_id}."
  value = length(google_folder.folder) > 0 ? google_folder.folder[0].name : ""
}
