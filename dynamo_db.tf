resource "aws_dynamodb_table" "airline_tickets_table" {
  name           = var.raw_stream_info
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "record_id"

  attribute {
    name = "record_id"
    type = "S"
  }

  tags = var.default_tags
}
