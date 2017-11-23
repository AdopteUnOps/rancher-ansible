resource "null_resource" "ansible-provision" {
  depends_on = ["aws_instance.rancher_ha", "aws_instance.rancher_host_dev"]
 
  provisioner "local-exec" {
    command = "echo \"[rancher_ha]\" &gt; rancher-inventory"
  }
 
  provisioner "local-exec" {
    command = "echo \"${join("\n",formatlist("%s ansible_ssh_user=%s", aws_instance.rancher_ha.*.public_ip, var.ssh_user))}\" &gt;&gt; rancher-inventory"
  }
 
  provisioner "local-exec" {
    command = "echo \"[rancher-nodes]\" &gt;&gt; rancher-inventory"
  }
 
  provisioner "local-exec" {
    command = "echo \"${join("\n",formatlist("%s ansible_ssh_user=%s", aws_instance.rancher_host_dev.*.public_ip, var.ssh_user))}\" &gt;&gt; rancher-inventory"
  }
} 
