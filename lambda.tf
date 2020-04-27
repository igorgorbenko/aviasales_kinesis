#--------------------------------------------------------------
# AWS Lambda Functions
#--------------------------------------------------------------
data "archive_file" "collector_zip" {
  source_file = "${path.module}/lambda/collector/main.py"
  type        = "zip"
  output_path = "${path.module}/lambda/collector/main.zip"
}

data "archive_file" "notifier_zip" {
  source_file = "${path.module}/lambda/notifier/main.py"
  type        = "zip"
  output_path = "${path.module}/lambda/notifier/main.zip"
}

resource "aws_lambda_function" "collector" {
  function_name    = var.raw_stream_lambda
  filename         = data.archive_file.collector_zip.output_path
  source_code_hash = data.archive_file.collector_zip.output_base64sha256

  role        = aws_iam_role.role_for_lambda_tickets.arn
  handler     = "main.lambda_handler"
  runtime     = "python3.7"
  timeout     = 15
  memory_size = 128

  tags = var.default_tags
}

resource "aws_lambda_function" "alarm_notifier" {
  function_name    = var.alarm_notifier
  filename         = data.archive_file.notifier_zip.output_path
  source_code_hash = data.archive_file.notifier_zip.output_base64sha256

  role        = aws_iam_role.role_for_lambda_alarm.arn
  handler     = "main.lambda_handler"
  runtime     = "python3.7"
  timeout     = 60
  memory_size = 128

  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.topic.arn
    }
  }

  tags = var.default_tags
}


resource "aws_lambda_event_source_mapping" "kinesis_mapping" {
  event_source_arn  = aws_kinesis_stream.airline_tickets.arn
  enabled           = true
  function_name     = aws_lambda_function.collector.arn
  starting_position = "LATEST"
}

resource "aws_lambda_event_source_mapping" "kinesis_mapping_alarm" {
  event_source_arn  = aws_kinesis_stream.special_stream.arn
  enabled           = true
  function_name     = aws_lambda_function.alarm_notifier.arn
  starting_position = "LATEST"
}

#--------------------------------------------------------------
# AWS Lambda Roles
#--------------------------------------------------------------
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


resource "aws_iam_role" "role_for_lambda_alarm" {
  name = "Lambda-KinesisAlarm"

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


resource "aws_iam_policy" "lambda_kinesis_sns" {
  name        = "lambda_kinesis_sns"
  path        = "/"
  description = "IAM policy for SNS alarm invoking from a lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:*",
                "kinesis:DescribeStream",
                "kinesis:DescribeStreamSummary",
                "kinesis:GetRecords",
                "kinesis:GetShardIterator",
                "kinesis:ListShards",
                "kinesis:ListStreams",
                "kinesis:SubscribeToShard",
                "sns:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_sns" {
  role       = aws_iam_role.role_for_lambda_alarm.name
  policy_arn = aws_iam_policy.lambda_kinesis_sns.arn
}
