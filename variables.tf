#------------------------------------------#
# General Variables
#------------------------------------------#
variable "ssh_user" {
  default = "ubuntu"
}
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}

#------------------------------------------#
# AWS Environment Variables
#------------------------------------------#
variable "region" {
    default     = "eu-central-1"
    description = "The region of AWS, for AMI lookups"
}

variable "count_srv" {
    default     = "1"
    description = "Number of HA servers to deploy"
}

variable "count_host_dev_env" {
    default     = "1"
    description = "Number of HA dev env host to deploy"
}

variable "name_prefix" {
    default     = "rancher-ha"
    description = "Prefix for all AWS resource names"
}

variable "name_prefix_host_dev" {
    default     = "rancher-dev"
    description = "Prefix for all AWS resource names"
}

variable "ami" {
    default     = "ami-6dec0c02"
    description = "Instance AMI ID ubuntu-14.04-docker-1.10.3.0"
}

variable "key_name" {
    description = "SSH key name in your AWS account for AWS instances"
}

variable "aws_access_key" {
    description = "AWS Access Key"
}

variable "aws_secret_key" {
    description = "AWS secret Key"
}

variable "instance_type" {
    default     = "t2.large" # RAM Requirements >= 8gb
    description = "AWS Instance type"
}

variable "root_volume_size" {
    default     = "16"
    description = "Size in GB of the root volume for instances"
}

variable "vpc_cidr" {
    default     = "192.168.199.0/24"
    description = "Subnet in CIDR format to assign to VPC"
}

variable "subnet_cidrs" {
    default     = ["192.168.199.0/26", "192.168.199.64/26", "192.168.199.128/26"]
    description = "Subnet ranges (requires 3 entries)"
}

variable "availability_zones" {
    default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    description = "Availability zones to place subnets"
}

variable "internal_elb" {
    default     = "false"
    description = "Force the ELB to be internal only"
}

#------------------------------------------#
# Database Variables
#------------------------------------------#
variable "db_name" {
    default     = "rancher"
    description = "Name of the RDS DB"
}

variable "db_user" {
    default     = "rancher"
    description = "Username used to connect to the RDS database"
}

variable "db_pass" {
    description = "Password used to connect to the RDS database"
}

#------------------------------------------#
# SSL Variables
#------------------------------------------#
variable "enable_https" {
    default     = false
    description = "Enable HTTPS termination on the loadbalancer"
}

variable "cert_body" {
    default = ""
}

variable "cert_private_key" {
    default = ""
}

variable "cert_chain" {
    default = ""
}

#------------------------------------------#
# Rancher Variables
#------------------------------------------#
variable "rancher_version" {
    default     = "stable"
    description = "Rancher version to deploy"
}

variable "rancher_access_key" {
    default = "F06A40A3C9A81EC3C07B"
    description = "Rancher Env Access Key"
}

variable "rancher_secret_key" {
    default = "BuPfyGcnm5oVrwhbJhkmbDoGQESoKiBZK2Seu1ZA"
    description = "Rancher Env Secret Key"
}
