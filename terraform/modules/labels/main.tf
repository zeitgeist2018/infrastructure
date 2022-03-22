#Module      : locals
#Description : To generate consistent label names and tags for resources. You can use terraform-labels to implement a strict naming convention.
locals {
  enabled = var.enabled == true ? true : false
  id_context = {
    name        = var.name
    environment = var.environment
  }

  id_labels = [for l in var.label_order : local.id_context[l] if length(local.id_context[l]) > 0]

  id          = lower(join(var.delimiter, local.id_labels, var.attributes))
  name        = local.enabled == true ? lower(format("%v", var.name)) : ""
  environment = local.enabled == true ? lower(format("%v", var.environment)) : ""
  attributes  = local.enabled == true ? lower(format("%v", join(var.delimiter, compact(var.attributes)))) : ""

  # Note: `Name` has a special meaning in AWS and we need to disamgiuate it by using the computed `id`
  tags = merge(
    {
      "Name"        = local.id
      "Environment" = local.environment
    },
    var.tags
  )
}
