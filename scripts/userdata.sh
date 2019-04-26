#!/bin/bash -x
yum update -y aws-cfn-bootstrap
/usr/bin/sudo /usr/bin/pip install --upgrade awscli
/usr/bin/sudo yum groupinstall -y "Development Tools"
/usr/bin/sudo yum install -y jq
/usr/bin/sudo yum install -y postgresql-devel
/usr/bin/sudo yum install -y postgresql-server
/usr/bin/sudo /sbin/service postgresql initdb
/usr/bin/sudo /etc/init.d/postgresql restart
/usr/bin/sudo mkdir -p /var/log/demodata
/usr/bin/wget https://s3-us-west-2.amazonaws.com/ctepoc-clickctream-dataset/OtherClickStreamDataSets/GADemoData.csv
/usr/bin/wget https://s3-us-west-2.amazonaws.com/ctepoc-clickctream-dataset/OtherClickStreamDataSets/Schematic_Log.csv
/usr/bin/sudo /bin/mv ./GADemoData.csv ./Schematic_Log.csv /var/log/demodata
/usr/bin/aws s3 sync /var/log/demodata/ s3://${StreamingAnalyticsBucket}/demodata --acl public-read
/usr/bin/sudo /bin/chown -R aws-kinesis-agent-user:aws-kinesis-agent-user /var/log/demodata/
source <(aws sts assume-role --role-arn arn:aws:iam::${AWS::AccountId}:role/${AppRole} --role-session-name "QuickStart" --duration-seconds 1900 | jq -r  '.Credentials | @sh "export AWS_SESSION_TOKEN=\(.SessionToken)\nexport AWS_ACCESS_KEY_ID=\(.AccessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey) "')
export PGPASSWORD='${MasterUserPassword}'
psql -h ${RedshiftCluster.Endpoint.Address} -U ${MasterUser} -d ${DatabaseName} -p ${RedshiftCluster.Endpoint.Port} PGPASSWORD -c 'create schema if not exists apache_logs;'
psql -h ${RedshiftCluster.Endpoint.Address} -U ${MasterUser} -d ${DatabaseName} -p ${RedshiftCluster.Endpoint.Port} PGPASSWORD -c 'create schema if not exists clickstream_demo;'
psql -h ${RedshiftCluster.Endpoint.Address} -U ${MasterUser} -d ${DatabaseName} -p ${RedshiftCluster.Endpoint.Port} PGPASSWORD -c 'create table apache_logs.access_logs (HOST VARCHAR(1000), IDENT VARCHAR(1000), AUTHUSER VARCHAR(1000), DATETIME TIMESTAMP, REQUEST VARCHAR(4000), RESPONSE VARCHAR(4000), BYTES VARCHAR(4000));'
psql -h ${RedshiftCluster.Endpoint.Address} -U ${MasterUser} -d ${DatabaseName} -p ${RedshiftCluster.Endpoint.Port} PGPASSWORD -c 'create table clickstream_demo.schematic_log(action varchar(100), bytes integer, item varchar(1000), number_of_purchases integer, response varchar(100), pct_purchase numeric(8,2), number_of_views integer, brand varchar(1000), clickhere varchar(1000), category varchar(1000), clientip varchar(1000), itemid varchar(1000), msg varchar(1000), number_of_records integer, productid varchar(1000), rbytes integer, rstat integer, serverip varchar(1000), sessionid varchar(1000), timestamp timestamp, url varchar(2000));'
psql -h ${RedshiftCluster.Endpoint.Address} -U ${MasterUser} -d ${DatabaseName} -p ${RedshiftCluster.Endpoint.Port} PGPASSWORD -c 'create table clickstream_demo.ga_demo_data(city varchar(100), country_region varchar(1000), date date, exits integer,medium varchar(1000), number_of_records integer, page varchar(1000), pageviews integer, section varchar(1000), time_on_page integer, total_downloads integer, unique_visitors integer, visits integer);'
psql -h ${RedshiftCluster.Endpoint.Address} -U ${MasterUser} -d ${DatabaseName} -p ${RedshiftCluster.Endpoint.Port} PGPASSWORD -c "copy clickstream_demo.schematic_log from 's3://${StreamingAnalyticsBucket}/demodata/Schematic_Log.csv' CREDENTIALS 'aws_access_key_id=$AWS_ACCESS_KEY_ID;aws_secret_access_key=$AWS_SECRET_ACCESS_KEY;token=$AWS_SESSION_TOKEN' delimiter ',' EMPTYASNULL ACCEPTINVCHARS ACCEPTANYDATE IGNOREHEADER AS 1;"
psql -h ${RedshiftCluster.Endpoint.Address} -U ${MasterUser} -d ${DatabaseName} -p ${RedshiftCluster.Endpoint.Port} PGPASSWORD -c "copy clickstream_demo.ga_demo_data from 's3://${StreamingAnalyticsBucket}/demodata/GADemoData.csv' CREDENTIALS 'aws_access_key_id=$AWS_ACCESS_KEY_ID;aws_secret_access_key=$AWS_SECRET_ACCESS_KEY;token=$AWS_SESSION_TOKEN' delimiter '\t' EMPTYASNULL ACCEPTINVCHARS ACCEPTANYDATE IGNOREHEADER AS 1;"
echo '${MasterUserPassword}' '${RedshiftCluster.Endpoint.Address}' '${MasterUser}' '${DatabaseName}' '${RedshiftCluster.Endpoint.Port}' '${StreamingAnalyticsBucket}' '${AppRole}' '${AWS::AccountId}' 'arn:aws:iam::${AWS::AccountId}:role/${AppRole}' > /home/ec2-user/variabledata
/opt/aws/bin/cfn-init -v --stack ${AWS::StackName} --resource LaunchConfigisDemos --region ${AWS::Region}
/opt/aws/bin/cfn-signal -e $? --stack ${AWS::StackName} --resource AppServerGroupisDemos --region ${AWS::Region}
