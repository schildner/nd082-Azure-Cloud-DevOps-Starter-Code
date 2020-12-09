variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "udacity-azure-course-project1-iac"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westeurope"
}

variable "username" {
  description = "The VM users login."
}

variable "password" {
  description = "The VM users password."
}

variable "number_of_vms" {
  description = "The number of Virtual Machines to be deployed"
  default = "1"
}