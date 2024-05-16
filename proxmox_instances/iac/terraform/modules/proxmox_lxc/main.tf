terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    ansible = {
      source = "nbering/ansible"
      version = "1.0.4"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.pm_api_url
}


locals {
  instance_config = yamldecode(file(var.instance_config))
  env_defaults    = yamldecode(file(var.env_defaults))

  ssh_keys = join("", [for key_path in local.env_defaults.ssh_key_paths : file(key_path)])
}

resource "proxmox_lxc" "containers" {
  for_each = { for instance in local.instance_config.instances : instance.name => instance }

  hostname    = each.value.name
  target_node = each.value.target_node

  ostemplate = local.env_defaults.ct_def_template

  password        = var.password
  ssh_public_keys = local.ssh_keys

  cores  = each.value.cores
  memory = each.value.memory

  start  = local.instance_config.start.on_create
  onboot = local.instance_config.start.on_boot

  rootfs {
    storage = local.env_defaults.prox_def_storage
    size    = each.value.disk_size
  }

  network {
    name   = local.env_defaults.net_def_nic
    bridge = local.env_defaults.net_def_bridge
    ip     = each.value.address != "dhcp" ? "${each.value.address}/${local.env_defaults.net_def_cidr}" : "${each.value.address}"
    gw     = local.env_defaults.net_def_gateway
    ip6    = local.env_defaults.net_def_ipv6_conf
  }

  features {
    fuse    = lookup(local.instance_config.features, "fuse", null)
    keyctl  = lookup(local.instance_config.features, "keyctl", null)
    mount   = lookup(local.instance_config.features, "mount", null)
    nesting = lookup(local.instance_config.features, "nesting", null)
  }

  dynamic "mountpoint" {
    # Use a conditional to check if 'mountpoints' is defined and not empty
    for_each = length(lookup(each.value, "mountpoints", [])) > 0 ? each.value.mountpoints : []


    content {
      // Without 'volume' defined, Proxmox will try to create a volume with
      // the value of 'storage' + : + 'size' (without the trailing G) - e.g.
      // "/srv/host/bind-mount-point:256".
      // This behaviour looks to be caused by a bug in the provider.
      key     = mountpoint.value.key
      slot    = mountpoint.value.slot
      storage = mountpoint.value.storage
      volume  = mountpoint.value.volume
      mp      = mountpoint.value.mp
      size    = mountpoint.value.size
    }
  }
}

locals {
  lxc_username = "root"
}

resource "ansible_host" "instances" {
  for_each = { for container in resource.proxmox_lxc.containers : container.hostname => container }
  inventory_hostname   = each.value.hostname
  groups = [ local.instance_config.deployment_name ]
  vars = {
    ansible_user                 = local.lxc_username
    ansible_ssh_private_key_file = trimsuffix(local.env_defaults.ssh_key_paths[1], ".pub")
  }
}