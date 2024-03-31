variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "app_count" {
  type    = number
  default = 3
}

variable "ecs_container_name" {
  type    = string
  default = "nginx-test-app"
}

variable "ecs_cpu" {
  type    = number
  default = 256
}

variable "ecs_mem" {
  type    = number
  default = 512
}