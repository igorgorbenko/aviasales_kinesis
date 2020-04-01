resource "aws_kinesis_stream" "airline_tickets" {
  name        = var.raw_stream_info
  shard_count = 1

  tags = var.default_tags
}


resource "aws_kinesis_stream" "special_stream" {
  name        = var.special_stream_info
  shard_count = 1

  tags = var.default_tags

}
