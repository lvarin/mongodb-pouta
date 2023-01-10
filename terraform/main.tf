
data "openstack_compute_flavor_v2" "flavor_mongodb" {
  name = "${var.flavor}" # flavor to be used
}

data "openstack_images_image_v2" "image" {
  name        = "${var.image}" # Name of image to be used
  most_recent = true
}

resource "openstack_networking_secgroup_v2" "mongodb_data" {
  name = "MongoDB-data"
  description = "External traffic MongoDB"
}

#
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_27017" {
  for_each          = toset(split(",", var.cidr_list))
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.control_port
  port_range_max    = var.control_port
  remote_ip_prefix  = each.value
  security_group_id = "${openstack_networking_secgroup_v2.mongodb_data.id}"
}
#

resource "openstack_networking_secgroup_v2" "secgroup_ssh" {
  name = "SSH-mongodb"
  description = "SSH connection from CSC to the API"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_22" {
  for_each          = toset(split(",", var.cidr_ssh))
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.value
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_ssh.id}"
}

resource "openstack_compute_instance_v2" "mongodb" {
  name            = "${var.mongodb_prefix}"
  #name            = "${var.mongodb_prefix}-${count.index}"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor_mongodb.id
  key_pair        = var.keypair
  security_groups = [
		     "${openstack_networking_secgroup_v2.secgroup_ssh.name}",
		     "${openstack_networking_secgroup_v2.mongodb_data.name}"
                    ]

  network {
    name = var.network
  }
}

# Add Floating ip

resource "openstack_networking_floatingip_v2" "fip1" {
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "fip1" {
  floating_ip = openstack_networking_floatingip_v2.fip1.address
  instance_id = openstack_compute_instance_v2.mongodb.id
 provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      host        = "${openstack_networking_floatingip_v2.fip1.address}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

}

output "inventory" {
  value = concat(
      [ {
        "groups"           : "['mongodb']",
        "name"             : "${openstack_compute_instance_v2.mongodb.name}",
        "ip"               : "${openstack_networking_floatingip_v2.fip1.address}",
        "ansible_ssh_user" : "${var.ssh_user}",
        "private_key_file" : "${var.private_key_path}",
        "ssh_args"         : "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
      } ],
  )
}

