variable "tag_class" {
  type    = string
  default = "dsba6190"
}

variable "tag_instructor" {
  type    = string
  default = "cford38"
}


variable "tag_semester" {
  type    = string
  default = "fall2025"
}

variable "location" {
  description = "Location of Resource Group"
  type        = string
  default     = "eastus"

  validation {
    condition     = contains(["eastus"], lower(var.location))
    error_message = "Unsupported Azure Region specified."
  }
}


// Azure-Specific App Variables

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "student_name" {
  description = "Application Name"
  type        = string
  default     = "jsengsy"
}

variable "class_name" {
  description = "Application Name"
  type        = string
  default     = "dsba6190"
}

variable "sql_admin_username" {
  description = "Admin username for Azure SQL Server"
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Admin password for Azure SQL Server"
  type        = string
  sensitive   = true
  default     = "P@assword123!"
}
