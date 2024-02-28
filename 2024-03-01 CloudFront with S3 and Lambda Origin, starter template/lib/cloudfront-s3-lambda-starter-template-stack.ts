import * as cdk from 'aws-cdk-lib';
import {Construct} from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as s3deploy from 'aws-cdk-lib/aws-s3-deployment';
import { aws_lambda, aws_lambda_nodejs } from "aws-cdk-lib";

const workshopPrefix = '2024-03-01-workshop';

export class CloudfrontS3LambdaStarterTemplateStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // S3 static website assets
    const staticWebsiteAssetsBucket = new s3.Bucket(this, 'static-website-assets', {
      bucketName: `${workshopPrefix}-static-website-assets`,
      encryption: s3.BucketEncryption.S3_MANAGED,
    });

    new s3deploy.BucketDeployment(this, 'DeployFiles', {
      sources: [s3deploy.Source.asset('./static-website-assets')],
      destinationBucket: staticWebsiteAssetsBucket,
    });

    // Lambda API
    const lambdaApiRoute = new aws_lambda_nodejs.NodejsFunction(
      this,
      "ApiRouteHandler",
      {
        functionName: `${workshopPrefix}-api-route-handler`,
        entry: "lambda-functions/dynamic-api-route.ts",
        handler: "handler",
        runtime: aws_lambda.Runtime.NODEJS_20_X,

      },
    );

    const functionUrl = lambdaApiRoute.addFunctionUrl(
      {
      authType: aws_lambda.FunctionUrlAuthType.NONE,
    });

    // Output the Function URL
    new cdk.CfnOutput(this, 'FunctionUrl', {
      value: functionUrl.url,
    });
  }
}
