#------------------------------------------#
# AWS EC2 Configuration
#------------------------------------------#
resource "aws_instance" "rancher_ha" {
    count                       = "${var.count_srv}"
    ami                         = "${var.ami}"
    instance_type               = "${var.instance_type}"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${element(sort(aws_subnet.rancher_ha.*.id), count.index)}"

    vpc_security_group_ids = ["${aws_security_group.rancher_ha.id}"]

    tags {
        Name = "${var.name_prefix}-${count.index}"
    }

    root_block_device {
        volume_size = "${var.root_volume_size}"
        delete_on_termination = true
    }
    depends_on = ["aws_security_group.rancher_ha"]

    provisioner "remote-exec" {
        inline = ["# Connected!"]
        connection {
            user = "${var.ssh_user}"
	    private_key = "${file(var.private_key_path)}"
	    }
    }

    provisioner "local-exec" {
        command = "./ansible/ansible-playbook ./create_master.yml -u ${var.ssh_user} --extra-vars 'mysql_host = ${self.private_ip} mysql_database = ${var.db_name} mysql_user = ${var.db_user} mysql_password = ${var.db_pass} rancher_master_host = ${self.private_ip} rancher_master_port = 8080'"
    }
    
##using ansible 
#   provisioner "ansible" {
#    connection {
#        user = "${var.ssh_user}"
#    }
#    playbook = "ansible/create_master.yml"
#    hosts = ["rancher-master"]
#    plays = ["rancher-master"]
#    groups = ["rancher-master"]
#    extra_vars = { 
#	  "mysql_host" = "${self.private_ip}",
#         "mysql_database" = "${var.db_name}",
#         "mysql_user" = "${var.db_user}",
#         "mysql_password" = "${var.db_pass}",
#         #"rancher_master_host" = "${element(sort(aws_instance.rancher_ha.*.private_ip), count.index)}",
#	  "rancher_master_host" = "${self.private_ip}",	
#         "rancher_master_port" = "8080",
#	}
#}

}

resource "aws_security_group" "rancher_ha" {
    name        = "${var.name_prefix}-server"
    description = "Rancher HA Server Ports"
    vpc_id      = "${aws_vpc.rancher_ha.id}"

    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "tcp"
        self      = true
    }

    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "udp"
        self      = true
    }

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    ingress {
        from_port   = 9345
        to_port     = 9345
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
