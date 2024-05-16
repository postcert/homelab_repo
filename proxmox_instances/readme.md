# Proxmox Instances

A lazy TF + Ansible combination to provision instances on my proxmox cluster

## Usage

`make {init,plan,apply} INSTANCE=$folder_name` for TF and `make configure INSTANCE=$folder_name` for Ansible