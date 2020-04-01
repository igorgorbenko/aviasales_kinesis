variable "aws_region" {
  default     = "us-east-1"
  description = "AWS Region"
}

variable "key_name" {
  type    = string
  default = "virginia"
}

variable "raw_stream_info" {
  type    = string
  default = "airline_tickets"
}

variable "special_stream_info" {
  type    = string
  default = "special_stream"
}

variable "raw_stream_lambda" {
  type    = string
  default = "airline_tickets_processing"
}

variable "default_tags" {
  type = map(string)
  default = {
    project : "airline_tickets",
    env : "dev"
  }
}
