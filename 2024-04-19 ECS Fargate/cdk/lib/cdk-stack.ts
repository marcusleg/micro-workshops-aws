import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";

const workshopPrefix = "2024-04-19-workshop"

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, "MyVpc", {});

    const cluster = new ecs.Cluster(this, "MyCluster", {
      clusterName: `${workshopPrefix}-fargate-cluster`,
      vpc: vpc,
    });

    new ecs_patterns.ApplicationLoadBalancedFargateService(this, "MyApplicationLoadBalancedFargateService", {
      serviceName: `${workshopPrefix}-ecs-sample`,
      cluster: cluster,
      cpu: 256,
      desiredCount: 3,
      taskImageOptions: { image: ecs.ContainerImage.fromRegistry("amazon/amazon-ecs-sample") },
      memoryLimitMiB: 512,
      publicLoadBalancer: true
    });
  }
}
