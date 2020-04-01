#!/bin/bash
REPO_PATH="https://raw.githubusercontent.com/igorgorbenko/aviasales_kinesis/master/producer"

sudo yum -y update

sudo yum install -y python36 python36-pip
sudo /usr/bin/pip-3.6 install --upgrade pip

sudo yum install -y aws-kinesis-agent
sudo cat > /etc/aws-kinesis/agent.json <<EOF
{
  "cloudwatch.emitMetrics": true,
  "kinesis.endpoint": "",
  "firehose.endpoint": "",

  "flows": [
    {
      "filePattern": "/var/log/airline_tickets/*log",
      "kinesisStream": "airline_tickets",
      "partitionKeyOption": "RANDOM",
      "dataProcessingOptions": [
         {
            "optionName": "CSVTOJSON",
            "customFieldNames": ["cost","trip_class","show_to_affiliates",
                "return_date","origin","number_of_changes","gate","found_at",
                "duration","distance","destination","depart_date","actual","record_id"]
         }
      ]
    }
  ]
}
EOF
sudo service aws-kinesis-agent restart

wget $REPO_PATH/api_caller.py -P /home/ec2-user/
wget $REPO_PATH/requirements.txt -P /home/ec2-user/
sudo chmod a+x /home/ec2-user/api_caller.py
sudo /usr/local/bin/pip3 install -r /home/ec2-user/requirements.txt

sudo mkdir /var/log/airline_tickets
