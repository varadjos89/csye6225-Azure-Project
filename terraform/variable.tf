variable "location" {
  type    = "string"
  default = "East US"
}

variable "resource_group_name" {
  type    = "string"
  default = "rsg"
}

variable "network_security_group_name" {
  type    = "string"
  default = "nsg"
}

variable "address_space" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "address_space_1" {
  type    = "string"
  default = "10.0.1.0/24"

}

variable "address_space_2" {
  type    = "string"
  default = "10.0.2.0/24"
}

variable "address_space_3" {
  type    = "string"
  default = "10.0.3.0/24"
}

variable "vm_hostname" {
  type    = "string"
  default = "vmhost"
}

variable "codeDeployBucketName" {
  type    = "string"
  default = "codedeploy.me"
}
variable "subscription_id" {
  type = "string"
}

variable "client_id" {
  type = "string"
}

variable "client_secret" {
  type = "string"
}

variable "tenant_id" {
  type = "string"
}

