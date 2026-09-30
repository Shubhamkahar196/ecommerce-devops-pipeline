locals {
  region          = var.aws_region
  name            = var.my_environment
  vpc_cidr        = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  intra_subnets   = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "my_environment"{
    description="This is the name of my environment"
    type=string
    
}

variable "instance_type" {
  description = "This is the instance type of environment"
  type        = string
}

variable "ami_id" {
    description = "This is the ami id of ec2"
    type = string

}

variable "aws_region"{
    description = "This is region of ec2"
    type = string
}