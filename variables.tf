variable "host_os" {
  type        = string
  default     = "windows"
  description = "The operating system of the host machine "
}

variable "admin_source_cidr" {
  type        = string
  description = "CIDR allowed to connect to SSH, such as your public IP followed by /32."
}
