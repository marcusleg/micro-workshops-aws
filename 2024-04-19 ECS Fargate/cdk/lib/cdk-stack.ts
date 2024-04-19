import * as cdk from 'aws-cdk-lib';
import {Construct} from 'constructs';
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";
import * as efs from "aws-cdk-lib/aws-efs";
import * as rds from 'aws-cdk-lib/aws-rds';
import * as iam from "aws-cdk-lib/aws-iam";

const workshopPrefix = "2024-04-19-workshop"

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, "EcsVpc", {});

    const cluster = new ecs.Cluster(this, "FargateCluster", {
      clusterName: `${workshopPrefix}-fargate-cluster`,
      vpc: vpc,
    });


    // ECS sample application
    new ecs_patterns.ApplicationLoadBalancedFargateService(this, "EcsSample", {
      serviceName: `${workshopPrefix}-ecs-sample`,
      cluster: cluster,
      cpu: 256,
      memoryLimitMiB: 512,
      desiredCount: 1,
      taskImageOptions: {
        image: ecs.ContainerImage.fromRegistry("amazon/amazon-ecs-sample")
      },
      publicLoadBalancer: true
    });

    // Nextcloud
    const nextcloudRds = new rds.DatabaseInstance(this, 'NextcloudRds', {
      // databaseName: 'nextcloud',
      engine: rds.DatabaseInstanceEngine.postgres({version: rds.PostgresEngineVersion.VER_16_1}),
      instanceType: ec2.InstanceType.of(ec2.InstanceClass.T4G, ec2.InstanceSize.SMALL),
      vpc: vpc,
      credentials: rds.Credentials.fromUsername('adminuser', {password: cdk.SecretValue.unsafePlainText('adminuser')}),
    })

    const nextcloudEfsFilesystem = new efs.FileSystem(this, 'NextcloudFileSystem', {
      // fileSystemName: "nextcloud",
      vpc,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    const nextcloudTaskRole = new iam.Role(this, 'NextcloudTaskRole', {
      assumedBy: new iam.ServicePrincipal('ecs-tasks.amazonaws.com'),
    });

    nextcloudTaskRole.addToPolicy(new iam.PolicyStatement({
      actions: ['rds:*'],
      resources: ['*'],
    }));

    const nextcloudEcsPattern = new ecs_patterns.ApplicationLoadBalancedFargateService(this, "Nextcloud", {
      serviceName: `${workshopPrefix}-nextcloud`,
      cluster: cluster,
      cpu: 1024,
      memoryLimitMiB: 2048,
      desiredCount: 3,
      publicLoadBalancer: true,
      taskImageOptions: {
        image: ecs.ContainerImage.fromRegistry("nextcloud:28"),
        taskRole: nextcloudTaskRole,
      },
    })

    nextcloudEcsPattern.service.taskDefinition.addVolume({
      name: 'data',
      efsVolumeConfiguration: {
        fileSystemId: nextcloudEfsFilesystem.fileSystemId,
      }
    })

    nextcloudEcsPattern.taskDefinition.defaultContainer?.addMountPoints({
      sourceVolume: 'data',
      containerPath: '/var/www/html',
      readOnly: false,
    });
  }
}
