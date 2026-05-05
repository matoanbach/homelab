pm_hosts = ["turtle"]
node_count = 2

vm_name_prefix               = "worker"
use_legacy_naming_convention = false

vm_net_name        = "vmbr0"
vm_net_subnet_cidr = "10.0.0.0/24"
vm_host_number     = 23

vm_user      = "toan"
vm_onboot    = true
vm_sockets   = 1
vm_max_vcpus = 2
vm_vcpus     = 2
vm_cpu_type  = "host"
vm_memory_mb = 4096

vm_os_disk_storage = "local-lvm"
vm_os_disk_size_gb = 20

vm_ubuntu_tmpl_name = "rhel-template"

vm_tags = ""

# ssh_public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))

add_worker_node_data_disk     = false
worker_node_data_disk_storage = "local-lvm"
worker_node_data_disk_size    = 10