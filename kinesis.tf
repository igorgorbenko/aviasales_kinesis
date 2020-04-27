#--------------------------------------------------------------
# Kinesis Streams
#--------------------------------------------------------------
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

#--------------------------------------------------------------
# Kinesis Analytics Application
#--------------------------------------------------------------
resource "aws_kinesis_analytics_application" "test_application" {
  name = "kinesis_analytics_airlines_app"

  inputs {
    name_prefix = "test_prefix"

    kinesis_stream {
      resource_arn = aws_kinesis_stream.airline_tickets.arn
      role_arn     = aws_iam_role.kinesis_analytics_airlines_app_role.arn
    }

    parallelism {
      count = 1
    }

    schema {
      record_columns {
        mapping  = "$.cost"
        name     = "cost"
        sql_type = "DOUBLE"
      }

      record_columns {
        mapping  = "$.trip_class"
        name     = "trip_class"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.show_to_affiliates"
        name     = "show_to_affiliates"
        sql_type = "BOOLEAN"
      }

      record_columns {
        mapping  = "$.return_date"
        name     = "return_date"
        sql_type = "TIMESTAMP"
      }

      record_columns {
        mapping  = "$.origin"
        name     = "origin"
        sql_type = "VARCHAR(4)"
      }

      record_columns {
        mapping  = "$.number_of_changes"
        name     = "number_of_changes"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.gate"
        name     = "gate"
        sql_type = "VARCHAR(16)"
      }

      record_columns {
        mapping  = "$.found_at"
        name     = "found_at"
        sql_type = "TIMESTAMP"
      }

      record_columns {
        mapping  = "$.duration"
        name     = "duration"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.distance"
        name     = "distance"
        sql_type = "INTEGER"
      }

      record_columns {
        mapping  = "$.destination"
        name     = "destination"
        sql_type = "VARCHAR(4)"
      }

      record_columns {
        mapping  = "$.depart_date"
        name     = "depart_date"
        sql_type = "TIMESTAMP"
      }

      record_columns {
        mapping  = "$.actual"
        name     = "actual"
        sql_type = "BOOLEAN"
      }

      record_columns {
        mapping  = "$.record_id"
        name     = "record_id"
        sql_type = "VARCHAR(64)"
      }

      record_encoding = "UTF-8"

      record_format {
        mapping_parameters {
          json {
            record_row_path = "$"
          }
        }
      }
    }
  }

  # reference_data_sources {
  #   table_name = "DESTINATION_SQL_STREAM"

  #   schema {
  #     record_columns {
  #       mapping  = "$.cost"
  #       name     = "cost"
  #       sql_type = "DOUBLE"
  #     }

  #     record_columns {
  #       mapping  = "$.gate"
  #       name     = "gate"
  #       sql_type = " VARCHAR(16)"
  #     }

  #     record_encoding = "UTF-8"

  #     record_format {
  #       mapping_parameters {
  #         json {
  #           record_row_path = "$"
  #         }
  #       }
  #     }
  #   }
  # }

  outputs {
    name = "IN_APP_STREAM"

    schema {
      record_format_type = "JSON"
    }

    kinesis_stream {
      resource_arn = aws_kinesis_stream.special_stream.arn
      role_arn     = aws_iam_role.kinesis_analytics_airlines_app_role.arn
    }

  }

  code = file("sql/analytics_query.sql")

}

#--------------------------------------------------------------
# Kinesis Analytics Application AWS Role
#--------------------------------------------------------------
resource "aws_iam_role_policy" "kinesis_analytics_airlines_app_policy" {
  name = "kinesis_analytics_airlines_app_policy"
  role = aws_iam_role.kinesis_analytics_airlines_app_role.id

  policy = <<-EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "kinesis:DescribeStream",
            "kinesis:GetShardIterator",
            "kinesis:GetRecords",
            "kinesis:PutRecord",
            "kinesis:PutRecords"

        ],
        "Resource": "*"
    }
]
}
  EOF
}

resource "aws_iam_role" "kinesis_analytics_airlines_app_role" {
  name = "kinesis_analytics_airlines_app_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "kinesisanalytics.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}
