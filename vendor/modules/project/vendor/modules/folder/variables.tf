variable "name" {
  description = "Folder name."
  type        = string
  validation {
    condition = length(split("/", var.name)) == 1
    error_message = "Using / as a path delimeter so make sure the name doesn't contain this combination."
  }
}

variable "parent" {
  description = "This new folder's parent folder."
  type = object({
    name = string
    path = string
  })
}

variable "envs" {
  type = list(string)
}

variable "environment" {
  type = string
}
