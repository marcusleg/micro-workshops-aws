
# How to Set Up AWS CLI for your company provided AWS account

## Prerequisites

Obtain an AWS account via the [_INFRA Requests_ Slack bot](https://codecentric.slack.com/archives/D03E99FSLCD).

## Step 1: Sign in to AWS Management Console
1. Access the [AWS Management Console](https://aws.amazon.com/console/) and log in with your AWS account credentials.

## Step 2: Create Access Key for Existing IAM User
1. Within the AWS Management Console, navigate to the IAM dashboard.
2. Click on "Users" in the navigation pane, then select the existing user for whom you want to create a new access key.
3. In the user details page, select the "Security credentials" tab.
4. In the "Access keys" section, click "Create access key".
5. You can download the access key ID and secret access key from here. Make sure to store them securely as the secret access key won't be shown again.

## Step 3: Install AWS CLI
If the AWS CLI isn't installed on your machine, follow the instructions on the [AWS CLI installation page](https://aws.amazon.com/cli/) to install it.

## Step 4: Configure AWS CLI with New Access Key
1. Open a terminal or command prompt.
2. Run `aws configure` to start the configuration process for the AWS CLI.
3. When prompted, input the access key ID and secret access key you just created. Continue by entering the default region name (e.g., `us-west-2`) and the output format (e.g., `json`).

## Step 5: Verify Configuration
1. To ensure the AWS CLI is correctly configured with your IAM user credentials, execute the command: `aws sts get-caller-identity`.
2. This command will return details about the IAM identity used by the CLI, including the user's AWS account ID, user or role ID, and ARN. If you see these details, it means the CLI is correctly configured.
