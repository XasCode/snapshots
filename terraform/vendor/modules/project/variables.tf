variable "name" {
  description = "Project name."
  type        = string
  validation {
    condition = length(var.name) < 23
    error_message = "Length of project name must be 23 characters or less to guarantee project_id is less than or equal to the 30 character limit."
  }
}

variable "parent" {
  description = "Path and name identifier for the folder containing the project."
  type = object({
    path = string
    name = string
  })
}

variable "billing_account" {
  description = "The account to bill project resources to."
  type = string
}

variable "envs" {
  type = list(string)
}

variable "environment" {
  type = string
}
