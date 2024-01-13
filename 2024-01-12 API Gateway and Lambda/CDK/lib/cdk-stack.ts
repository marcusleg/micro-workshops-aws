import * as cdk from "aws-cdk-lib";
import { aws_apigatewayv2, aws_lambda, aws_lambda_nodejs } from "aws-cdk-lib";
import { Construct } from "constructs";
import { HttpLambdaIntegration } from "aws-cdk-lib/aws-apigatewayv2-integrations";

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const apiGateway = new aws_apigatewayv2.HttpApi(this, "HttpApi", {
      apiName: "my-api",
    });

    new cdk.CfnOutput(this, "ApiGatewayUrl", { value: apiGateway.url! });

    const lambdaRootRoute = new aws_lambda_nodejs.NodejsFunction(
      this,
      "MyApiRootRouteHandler",
      {
        entry: "lambda-functions/my-api-root-route.ts",
        handler: "handler",
        runtime: aws_lambda.Runtime.NODEJS_20_X,
      },
    );

    const integrationRootRoute = new HttpLambdaIntegration(
      "RootRoute",
      lambdaRootRoute,
    );

    apiGateway.addRoutes({
      path: "/",
      methods: [aws_apigatewayv2.HttpMethod.GET],
      integration: integrationRootRoute,
    });
  }
}
