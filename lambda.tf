data "archive_file" "process_tickets_zip" {
  source_file = "${path.module}/lambda/process_tickets/main.py"
  type        = "zip"
  output_path = "${path.module}/lambda/process_tickets/main.zip"
}

resource "aws_lambda_function" "process_tickets" {
  function_name    = var.raw_stream_lambda
  filename         = data.archive_file.process_tickets_zip.output_path
  source_code_hash = data.archive_file.process_tickets_zip.output_base64sha256

  role        = aws_iam_role.role_for_lambda_tickets.arn
  handler     = "main.lambda_handler"
  runtime     = "python3.7"
  timeout     = 15
  memory_size = 128

  tags = var.default_tags
}

resource "aws_lambda_event_source_mapping" "kinesis_mapping" {
  event_source_arn  = aws_kinesis_stream.airline_tickets.arn
  enabled           = true
  function_name     = aws_lambda_function.process_tickets.arn
  starting_position = "LATEST"
}

resource "aws_iam_role" "role_for_lambda_tickets" {
  name = "Lambda-TicketsProcessingRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.default_tags
}

resource "aws_iam_policy" "lambda_kinesis_dynamo" {
  name        = "lambda_kinesis_dynamo"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards",
          "kinesis:ListStreams",
          "kinesis:SubscribeToShard",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "dynamodb:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_dynamo" {
  role       = aws_iam_role.role_for_lambda_tickets.name
  policy_arn = aws_iam_policy.lambda_kinesis_dynamo.arn
}
