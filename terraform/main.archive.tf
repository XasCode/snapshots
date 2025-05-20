data "archive_file" "srcfiles" {
  type        = "zip"
  output_path = "snapshots.zip"
  source_dir  = var.src_dir
  count       = contains(var.envs, var.environment) ? 1 : 0
}
