# How to install AWS CDK

Reference: https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html

1. Install Node.js and npm
2. `npm install -g aws-cdk`
3. `cdk bootstrap aws://ACCOUNT-NUMBER/REGION` (e.g. `cdk bootstrap aws://$(aws sts get-caller-identity | jq -r .Account)/eu-central-1`) 