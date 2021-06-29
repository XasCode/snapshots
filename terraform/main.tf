provider "archive" {}

resource "random_id" "random" {
  byte_length = 3
}

data "archive_file" "srcfiles" {
  type        = "zip"
  output_path = "snapshots.zip"
  source_dir  = "./src"
}
