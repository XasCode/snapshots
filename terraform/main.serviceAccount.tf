resource "google_organization_iam_custom_role" "role-svc-check-snapshots" {
  count       = contains(var.envs, var.environment) ? 1 : 0
  role_id     = "role_svc_check_snapshots_${random_id.random[0].hex}"
  org_id      = var.organization_id
  title       = "role_svc_check_snapshots_${random_id.random[0].hex}"
  description = "Role / permissions to assign to service account for automatically setting up disk snapshots."
  permissions = [
    "compute.disks.list",
    "compute.projects.get",
    "compute.snapshots.list",
    "compute.instances.list",
    "compute.regions.list",
    "compute.zones.list",
    "compute.disks.addResourcePolicies",
    "compute.resourcePolicies.create",
    "compute.resourcePolicies.get",
    "compute.resourcePolicies.list",
    "compute.resourcePolicies.use",
    "resourcemanager.organizations.get",
    "resourcemanager.folders.get",
    "resourcemanager.folders.list",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list",
    "secretmanager.versions.access",
#    "secretmanager.locations.get",
#    "secretmanager.locations.list",
#    "secretmanager.secrets.get",
#    "secretmanager.secrets.getIamPolicy",
#    "secretmanager.secrets.list",
#    "secretmanager.versions.get",
#    "secretmanager.versions.list",
    "storage.objects.create"
  ]
}

resource "google_service_account" "svc-check-snapshots" {
  count        = contains(var.envs, var.environment) ? 1 : 0
  project      = module.snapshots.id
  display_name = "Service account for automatically setting up disk snapshots."
  account_id   = "svc-check-snapshots-${random_id.random[0].hex}"
}
