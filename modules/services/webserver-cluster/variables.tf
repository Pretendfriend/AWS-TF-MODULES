variable "server_port" {
  description = "The port the server will use for http"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}

variable "db_remote_state_bucket" {
  default     = "mmacnish-project-test"
  description = "The name of the s3 bucket for the database's remote state"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to run (e.g t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC instacnes in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC instacnes in the ASG"
  type        = number
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}