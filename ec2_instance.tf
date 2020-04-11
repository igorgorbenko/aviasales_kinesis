#--------------------------------------------------------------
# New EC2 spot instance
#--------------------------------------------------------------
resource "aws_spot_instance_request" "producer_instance" {
  ami                    = "ami-09d069a04349dc3cb"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.my_producer.id]
  user_data              = file("scripts/bootstrap.sh")
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name


  spot_price           = 0.01
  wait_for_fulfillment = true
  spot_type            = "one-time"

  tags = var.default_tags
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------
resource "aws_security_group" "my_producer" {
  name        = "kinesis_procucer_security_group"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.default_tags
}

#--------------------------------------------------------------
# AWS EC2 Role
#--------------------------------------------------------------
resource "aws_iam_role" "ec2_kinesis" {
  name = "EC2-KinesisStreams-FullAccess"

  #   assume_role_policy = "${file("assumerolepolicy.json")}"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
 {
   "Action": "sts:AssumeRole",
   "Principal": {
     "Service": "ec2.amazonaws.com"
   },
   "Effect": "Allow",
   "Sid": ""
 }
]
}
EOF

  tags = var.default_tags
}

resource "aws_iam_policy" "policy_kinesis_stream" {
  name        = "policy_kinesis_stream"
  description = "policy_kinesis_stream"
  policy      = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
      "Action": [
          "cloudwatch:*",
          "logs:*",
          "kinesis:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
  }
]
}
EOF
}

resource "aws_iam_policy_attachment" "ec2_kinesis_attach" {
  name       = "ec2_kinesis_attach"
  roles      = [aws_iam_role.ec2_kinesis.name]
  policy_arn = aws_iam_policy.policy_kinesis_stream.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_kinesis.name
}
