variable "cluster_name" {
  type    = string
  default = "eks_project"
}

variable "location" {
  type    = string
  default = "us-east-2"
}

variable "default_vpc_id" {
  type    = string
  default = "vpc-0338244bdf81cdc23" // cidr 172.31.0.0/16
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-07360426ae2f30194", "subnet-0e1dc35d985bafee2"] // cidr - 172.31.0.0/20, 172.31.16.0/20
}
