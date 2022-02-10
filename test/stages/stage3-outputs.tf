
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name                = module.gitops_cp_wml.name
        instance_name       = module.gitops_cp_wml.instance_name
        sub_chart           = module.gitops_cp_wml.sub_chart
        sub_name            = module.gitops_cp_wml.sub_name
        operator_namespace  = module.gitops_cp_wml.operator_namespace
        branch              = module.gitops_cp_wml.branch
        namespace           = module.gitops_cp_wml.namespace
        server_name         = module.gitops_cp_wml.server_name
        layer               = module.gitops_cp_wml.layer
        layer_dir           = module.gitops_cp_wml.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_cp_wml.layer == "services" ? "2-services" : "3-applications")
        type                = module.gitops_cp_wml.type
      })
    }
  }
}
