variable "organization_id" {
  type = string
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


variable "sg" {
  type = string
}

variable "parent" {
  type = object({
    path = string
    name = string
  })
}

variable "src_dir" {
  type = string
}