#
# DO NOT MODIFY THIS FILE, MODIFY 'group_vars/all' INSTEAD
#

variable "keypair" {
  type    = string
  default = ""   # name of keypair that will have access to the VMs
}

variable "network" {
  type    = string
  default = "" # default network to be used
}

variable "cidr_ssh" {
  type    = string
  default = "" # Comma separated list of ip range with SSH access
}

variable "cidr_list" {
  type    = string
  default = "" # Comma separated list of ip range with MongoDB access
}

variable "control_port" {
  type    = string
  default = "" # Comma separated list of ip range with MongoDB access
}

###

variable "mongodb_prefix" {
  type = string
  default = "mongodb" # Name of the VM to create
}

variable "flavor" {
  description = "Flavor to be used"
  default     = ""
}

variable "image" {
  description = "Image name to be used"
  default     = ""
}

variable "ssh_user" {
  description = "SSH user name to connect to your instance."
  default     = ""
}

variable "private_key_path" {
  description = "Path to the private SSH key, used to access the instance."
  default     = "" # path where terraform will find the private key
}


