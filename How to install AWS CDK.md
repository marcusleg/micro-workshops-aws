# How to install AWS CDK

To get started with the AWS Cloud Development Kit (AWS CDK), follow this concise step-by-step tutorial. AWS CDK enables you to define cloud infrastructure in code and provision it through AWS CloudFormation. Before proceeding, ensure you have an AWS account and your AWS CLI is configured with access credentials.

### Step 1: Install Node.js and npm

The AWS CDK requires Node.js and npm (Node Package Manager). Install it via your operating system's package manager or download and install the latest version from [the official Node.js website](https://nodejs.org/). This will include npm.

### Step 2: Install AWS CDK

Open your terminal or command prompt and run the following command to install the AWS CDK globally:

```sh
npm install -g aws-cdk
```

This command installs the AWS CDK Toolkit, which is a command-line utility that allows you to work with CDK apps.

### Step 3: Bootstrap Your AWS Environment

Before deploying your CDK application, you must bootstrap your AWS environment to create the necessary resources that the AWS CDK requires for deploying your cloud applications. To do this, run the following command:

```sh
cdk bootstrap aws://ACCOUNT-NUMBER/REGION
```

Replace `ACCOUNT-NUMBER` with your AWS account number and `REGION` with the region you want to deploy resources to. For instance, if you want to automatically fill in your account number and target the `eu-central-1` region, you can use:

```sh
cdk bootstrap aws://$(aws sts get-caller-identity | jq -r .Account)/eu-central-1
```

This command requires that you have the AWS CLI installed and configured, and it uses `jq` to parse the output of the AWS CLI command `aws sts get-caller-identity` to get your AWS account number.

### Additional Resources

For more detailed information and to dive deeper into AWS CDK, refer to the AWS CDK Getting Started Guide at [https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html). This guide provides comprehensive instructions and additional steps for creating your first CDK project, writing your infrastructure as code, and deploying it to AWS.

Following these steps will get your AWS CDK setup and ready to use for developing and deploying cloud applications using infrastructure as code.