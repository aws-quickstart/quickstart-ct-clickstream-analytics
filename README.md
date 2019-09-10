# quickstart-clickstream-analytics-ct
## Clickstream Analytics on the AWS Cloud

This Quick Start automatically builds a clickstream analytics solution on Amazon Web Services (AWS) in about 30 minutes. It integrates AWS services such as Amazon Kinesis Data Firehose, Amazon Simple Storage Service (Amazon S3), Amazon Elasticsearch Service (Amazon ES), Amazon Redshift, and Amazon QuickSight. The clickstream analytics solution provides:

- Streaming data ingestion, which can process millions of website clicks (clickstream data) a day from global websites.
- Near real-time visualization of web usage metrics such as events per hour, visitor count, and referrers. It also enables you to build a recommendation engine with Amazon Redshift application programming interfaces (APIs).
- Ability to publish your website clickstream data to Amazon S3, Amazon Redshift, and Amazon ES.
- Analysis and visualizations of your clickstream data using Kibana (an open-source tool that comes with Amazon ES) and Amazon QuickSight.

This Quick Start is for users who want to get started with AWS-native components for clickstream analytics on AWS. Once this foundation layer is in place, you can use it to ingest, analyze, and generate business insights from clickstream data that your websites generate. 

This reference architecture is automated by AWS CloudFormation templates that you can customize to meet your specific requirements. The AWS CloudFormation templates included with the Quick Start automate the following:

- Deploying clickstream analytics into a new virtual private cloud (VPC)
- Deploying clickstream analytics into an existing VPC in your AWS account

![Quick Start architecture for clickstream analytics](https://d1.awsstatic.com/partner-network/QuickStart/datasheets/clickstream-analytics-on-aws-arch.cfd05acf7325a0bc3578031f1f978eb3d60be1ef.png)

For architectural details, best practices, step-by-step instructions, and customization options, see the [deployment guide](https://fwd.aws/MmPAP).

To post feedback, submit feature ideas, or report bugs, use the **Issues** section of this GitHub repo.

If you'd like to submit code for this Quick Start, please review the [AWS Quick Start Contributor's Guide](https://aws-quickstart.github.io/). 
