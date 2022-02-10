locals {
  name          = "terraform-gitops-cp-watson-machine-learning"
  bin_dir       = module.setup_clis.bin_dir
  subscription_name = "ibm-cpd-wml-subscription"
  subscription_chart_dir = "${path.module}/charts/${local.subscription_name}"
  subscription_yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.subscription_name}"
  instance_name = "ibm-cpd-wml-instance"
  instance_chart_dir = "${path.module}/charts/${local.instance_name}"
  instance_yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.instance_name}"
  service_url   = "http://${local.name}.${var.namespace}"
  subscription_content = {
    name = "ibm-cpd-wml-subscription"
    operator_namespace = var.namespace
    syncwave = "-5"
    channel = "v1.1"
    installPlan = "Automatic"
  }
  instance_content = {
    cpd_namespace = "zen"
    name = "wml-cr"
    scale = "small"
    license = "Enterprise"
    storageVendor = "Portworx"
    storageClass = "portworx-shared-gp3"
  }
  layer = "services"
  type  = "operators"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_operator_yaml {

  triggers = {
    name = local.subscription_name
    chart_dir = local.subscription_chart_dir
    yaml_dir = local.subscription_yaml_dir
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.chart_dir} '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.subscription_content)
    }
  }
}

resource null_resource setup_operator_gitops {
  depends_on = [null_resource.create_operator_yaml]

  triggers = {
    name = local.subscription_name
    namespace = var.namespace
    yaml_dir = local.subscription_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}

resource null_resource create_instance_yaml {

  triggers = {
    name = local.instance_name
    chart_dir = local.instance_chart_dir
    yaml_dir = local.instance_yaml_dir
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.chart_dir} '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.instance_content)
    }
  }
}

resource null_resource setup_instance_gitops {
  depends_on = [null_resource.create_instance_yaml]

  triggers = {
    name = local.instance_name
    namespace = var.namespace
    yaml_dir = local.instance_chart_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
