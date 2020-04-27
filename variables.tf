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
  default = "airline_collector"
}

variable "alarm_notifier" {
  type    = string
  default = "alarm_notifier"
}

variable "default_tags" {
  type = map(string)
  default = {
    project : "airline_tickets",
    env : "dev"
  }
}

variable "topic_name" {
  description = "Name of the AWS SNS topic"
  default     = "Airlines"
}

variable "subscriptions" {
  description = "A phone number to subscribe to SNS."
  type        = string
}

variable "default_sender_id" {
  description = "A custom ID, such as your business brand, displayed as the sender on the receiving device"
  default     = "Airlines_app"
}

variable "default_sms_type" {
  description = "Promotional messages are noncritical, such as marketing messages. Transactional messages are delivered with higher reliability to support customer transactions, such as one-time passcodes."
  default     = "Promotional"
}

variable "delivery_status_iam_role_arn" {
  description = "The IAM role that allows Amazon SNS to write logs for SMS deliveries in CloudWatch Logs."
  default     = ""
}

variable "delivery_status_success_sampling_rate" {
  description = "Default percentage of success to sample."
  default     = ""
}

variable "monthly_spend_limit" {
  description = "The maximum amount to spend on SMS messages each month. If you send a message that exceeds your limit, Amazon SNS stops sending messages within minutes."
  default     = 10
}
