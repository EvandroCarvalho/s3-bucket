# required for AWS
variable "aws_access_key_id" {
    description = "Access key to AWS console"
    default = ""
}
variable "aws_access_secret_id" {
    description = "Secret key to AWS console"
    default = ""
}
variable "region" {
    description = "Region of AWS VPC"
    default = ""
}
