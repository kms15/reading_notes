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

# create a t2.micro instance
resource "aws_instance" "example" {
    # ami = "ami-0c55b159cbfafe1f0" # from Terraform Up & Running
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"

    tags = {
        Name = "terraform-example"
    }
}
