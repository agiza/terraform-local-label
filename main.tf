#
# Terraform module to provide consistent naming
#
# TODO:
#   Add attributes to name if not empty
#   return name as lowercase
#   return id and id_20, id_32 for combined name

resource "null_resource" "pre1" {
  count     = "${var.enabled ? 1 : 0}"
  triggers  = {
    attributes    = "${lower(format("%s", join(var.delimiter, compact(var.attributes))))}"
    environment   = "${lower(format("%s", var.environment))}"
    name          = "${lower(format("%s", var.name))}"
    organization  = "${lower(format("%s", var.organization))}"
  }
}
resource "null_resource" "pre2" {
  count     = "${var.enabled ? 1 : 0}"
  triggers  = {
    name_env      = "${var.namespace-env ? join(var.delimiter, list(null_resource.pre1.triggers.environment, null_resource.pre1.triggers.name)) : null_resource.pre1.triggers.name}"
  }
}
resource "null_resource" "pre3" {
  count     = "${var.enabled ? 1 : 0}"
  triggers  = {
    name_org      = "${var.namespace-org ? join(var.delimiter, list(null_resource.pre1.triggers.organization, null_resource.pre2.triggers.name_env)) : null_resource.pre2.triggers.name_env}"
  }
}
resource "null_resource" "this" {
  count     = "${var.enabled ? 1 : 0}"
  triggers  = {
    attributes    = "${null_resource.pre1.triggers.attributes}"
    environment   = "${null_resource.pre1.triggers.environment}"
    organization  = "${null_resource.pre1.triggers.organization}"
    name          = "${null_resource.pre3.triggers.name_org}"
    name_20       = "${substr(replace(null_resource.pre3.triggers.name_org,"_","-"),0,19 <= length(null_resource.pre3.triggers.name_org) ? 19 : length(null_resource.pre3.triggers.name_org))}"
    name_32       = "${substr(replace(null_resource.pre3.triggers.name_org,"_","-"),0,31 <= length(null_resource.pre3.triggers.name_org) ? 31 : length(null_resource.pre3.triggers.name_org))}"
    /* FIX: wants only strings. Moved to outputs
    tags        = "${ merge(
      var.tags,
      map("Name", var.name),
      map("Environment", var.environment),
      map("Terraform", "true") )}"*/
  }
}
