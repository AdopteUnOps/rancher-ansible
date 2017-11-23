#------------------------------------------#
# AWS EC2 Configuration
#------------------------------------------#
resource "aws_instance" "rancher_host_dev" {
    count                       = "${var.count_host_dev_env}"
    ami                         = "${var.ami}"
    instance_type               = "${var.instance_type}"
    key_name                    = "${var.key_name}"
    subnet_id                   = "${element(sort(aws_subnet.rancher_ha.*.id), count.index)}"

    vpc_security_group_ids = ["${aws_security_group.rancher_ha.id}"]

    tags {
        Name = "${var.name_prefix_host_dev}-${count.index}"
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
        command = "./ansible/ansible-playbook ./create_project.yml --extra-vars 'rancher_master_host = ${element(sort(aws_instance.rancher_ha.*.private_ip), count.index)} rancher_master_port = 8080 rancher_master_url = http://{{rancher_master_host}}:{{rancher_master_port}} rancher_project_name = dev'"
    }

}
resource "aws_security_group" "rancher_host" {
    name        = "${var.name_prefix}-host"
    description = "Rancher HA Host Ports"
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

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}