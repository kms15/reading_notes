provider "aws" {
    region = "us-west-2"
}

# find the ami for the most recent version of ubuntu 18.04
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
       name = "name"
       values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
       name = "virtualization-type"
       values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

# create a security group to allow incoming traffic on 8080
resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# create a t2.micro instance
resource "aws_instance" "example" {
    # ami = "ami-0c55b159cbfafe1f0" # from Terraform Up & Running
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    # launch a simple web server on startup
    user_data = <<-EOF
        #!/bin/bash
        echo "<html><head><title>Hello</title></head><body><h1>Hello world!</h1></body></html>" > index.html
        nohup busybox httpd -f -p 8080 &
        EOF

    tags = {
        Name = "terraform-example"
    }
}
