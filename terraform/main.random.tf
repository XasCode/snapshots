resource "random_id" "random" {
  count       = contains(var.envs, var.environment) ? 1 : 0
  byte_length = 3
}
