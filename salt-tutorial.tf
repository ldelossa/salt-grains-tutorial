variable "local_public_ip" {}

output "server01_ip" {
    value = "${aws_instance.server01.public_ip}"
}
output "salt-master01_ip" {
    value = "${aws_instance.salt-master01.public_ip}"
}

provider "aws" {
    access_key = ""
    secret_key = ""
    region = ""
}

resource "aws_vpc" "salt-tutorial" {
    cidr_block = "10.10.0.0/16"
    enable_dns_hostnames = "true"
    
    tags {
        Name = "salt-tutorial"
    }
}

resource "aws_network_acl" "salt-tutorial-nacl01" {
    vpc_id = "${aws_vpc.salt-tutorial.id}"
    subnet_ids = ["${aws_subnet.salt-tutorial-subnet01.id}"]
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        rule_no = 1
        action = "allow"
        cidr_block = "0.0.0.0/0"
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        rule_no = 1
        action = "allow"
        cidr_block = "0.0.0.0/0"
    }
}



resource "aws_internet_gateway" "salt-tutorial-ig" {
    vpc_id = "${aws_vpc.salt-tutorial.id}"
    
    tags {
        Name = "salt-tutorial-ig"
    }
}

resource "aws_route_table" "salt-tutorial-route01" {
    vpc_id = "${aws_vpc.salt-tutorial.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.salt-tutorial-ig.id}"
    }

    tags {
        Name = "salt-tutorial-route01"
    }
}

resource "aws_subnet" "salt-tutorial-subnet01" {
    vpc_id = "${aws_vpc.salt-tutorial.id}"
    cidr_block = "10.10.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-west-1c"
    
    tags {
       Name = "salt-tutorial-subnet01"
    }
}

resource "aws_route_table_association" "salt-tutorial-s01-r01-association" {
    subnet_id = "${aws_subnet.salt-tutorial-subnet01.id}"
    route_table_id = "${aws_route_table.salt-tutorial-route01.id}"
}

resource "aws_security_group" "salt-tutorial-sg01" {
    name = "salt-tutorial-sg01"
    description = "Will allow all inbound traffic"
    vpc_id = "${aws_vpc.salt-tutorial.id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.local_public_ip}/32"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${aws_subnet.salt-tutorial-subnet01.cidr_block}"]
    }
    
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${aws_subnet.salt-tutorial-subnet01.cidr_block}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "salt-master01" {
    ami = "ami-06116566"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.salt-tutorial-subnet01.id}"
    vpc_security_group_ids = ["${aws_security_group.salt-tutorial-sg01.id}"]
    key_name = "salt-tutorial"
    tags {
        "Name" = "salt-master01"
    }
   
    ebs_block_device {
        device_name = "/dev/sdf"
        volume_type = "gp2"
        volume_size = "32"
    }
    
    ephemeral_block_device {
        device_name = "xvdd"
        virtual_name = "ephemeral0"
    }
    ephemeral_block_device {
        device_name = "xvde"
        virtual_name = "ephemeral1"
    }
    ephemeral_block_device {
        device_name = "xvdf"
        virtual_name = "ephemeral2"
    }
    ephemeral_block_device {
        device_name = "xvdg"
        virtual_name = "ephemeral3"
    }
    ephemeral_block_device {
        device_name = "xvdh"
        virtual_name = "ephemeral4"
    }
    ephemeral_block_device {
        device_name = "xvdi"
        virtual_name = "ephemeral5"
    }
    ephemeral_block_device {
        device_name = "xvdj"
        virtual_name = "ephemeral6"
    }
    ephemeral_block_device {
        device_name = "xvdk"
        virtual_name = "ephemeral7"
    }

    provisioner "file" {
        connection {
            user = "ubuntu"
            private_key = "${file("")}"
        }
        source = "./block-devices.py"
        destination = "/tmp/block-devices.py"
    }
    provisioner "remote-exec" {
        connection {
            user = "ubuntu"
            private_key = "${file("")}"
        }
        inline = [
            "sudo apt-get update",
            "sudo ufw disable",
            "sudo stop ufw",
            "echo ${aws_instance.salt-master01.private_ip} salt",
            "wget -P /tmp/ https://raw.githubusercontent.com/saltstack/salt-bootstrap/stable/bootstrap-salt.sh",
            "sudo chmod u+x /tmp/bootstrap-salt.sh",
            "sudo sh /tmp/bootstrap-salt.sh -M -N git v2015.8.10",
            "sudo mkdir -p /srv/salt/_grains/",
            "sudo mv /tmp/block-devices.py /srv/salt/_grains/"
            ]
    }
}


resource "aws_instance" "server01" {
    ami = "ami-06116566"
    instance_type = "m3.xlarge"
    vpc_security_group_ids = ["${aws_security_group.salt-tutorial-sg01.id}"]
    subnet_id = "${aws_subnet.salt-tutorial-subnet01.id}"
    key_name = "salt-tutorial"
    tags {
        "Name" = "server01"
    }

    ebs_block_device {
        device_name = "/dev/sdf"
        volume_type = "gp2"
        volume_size = "32"
    }
    
    ephemeral_block_device {
        device_name = "xvdd"
        virtual_name = "ephemeral0"
    }
    ephemeral_block_device {
        device_name = "xvde"
        virtual_name = "ephemeral1"
    }
    ephemeral_block_device {
        device_name = "xvdf"
        virtual_name = "ephemeral2"
    }
    ephemeral_block_device {
        device_name = "xvdg"
        virtual_name = "ephemeral3"
    }
    ephemeral_block_device {
        device_name = "xvdh"
        virtual_name = "ephemeral4"
    }
    ephemeral_block_device {
        device_name = "xvdi"
        virtual_name = "ephemeral5"
    }
    ephemeral_block_device {
        device_name = "xvdj"
        virtual_name = "ephemeral6"
    }
    ephemeral_block_device {
        device_name = "xvdk"
        virtual_name = "ephemeral7"
    }
    

    provisioner "remote-exec" {
        connection {
            user = "ubuntu"
            private_key = "${file("")}"
        }
        inline = [
            "sudo ufw disable",
            "sudo stop ufw",
            "sudo -u root sh -c 'echo ${aws_instance.salt-master01.private_ip} salt >> /etc/hosts'",
            "sudo wget -P /tmp/ https://raw.githubusercontent.com/saltstack/salt-bootstrap/stable/bootstrap-salt.sh",
            "sudo chmod u+x /tmp/bootstrap-salt.sh",
            "sudo apt-get update",
            "sudo sh /tmp/bootstrap-salt.sh -A 'salt' -i 'server01' git v2015.8.10"
            ]
    }
}
    
