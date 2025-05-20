module "snapshots" {
  source = "./vendor/modules/project"
  
  name   = "snapshots"
  parent = var.parent

  billing_account = var.billing_account

  envs   = var.envs
  environment    = var.environment
}
