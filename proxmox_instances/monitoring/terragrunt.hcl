terraform {
    source = "${get_path_to_repo_root()}/iac/terraform/modules/proxmox_lxc"
}

inputs = {
    instance_config = "./instance_config.yaml"
    env_defaults = find_in_parent_folders("env_defaults.yaml")
    working_dir = "${get_terragrunt_dir()}"
}