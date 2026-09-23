import * as cdk from 'aws-cdk-lib/core';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as fs from 'fs';
import * as path from 'path';

export class PortfolioStack extends cdk.Stack {
  public readonly bucket: s3.Bucket;
  public readonly distribution: cloudfront.Distribution;
  public readonly portfoliosTable: dynamodb.Table;

  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    this.bucket = new s3.Bucket(this, 'PortfolioAssetsBucket', {
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      encryption: s3.BucketEncryption.S3_MANAGED,
      enforceSSL: true,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
    });

    const cdkOac = new cloudfront.S3OriginAccessControl(this, 'PortfolioOAC', {
      signing: cloudfront.Signing.SIGV4_ALWAYS,
    });

    const s3Origin = origins.S3BucketOrigin.withOriginAccessControl(this.bucket, {
      originAccessControl: cdkOac,
    });

    const publicKeyPem = fs.readFileSync(path.join(__dirname, '../keys/public_key.pem'), 'utf8');

    const cfPublicKey = new cloudfront.PublicKey(this, 'PortfolioPublicKey', {
      encodedKey: publicKeyPem,
      comment: 'Clave pública para firmar URLs de archivos privados',
    });

    const keyGroup = new cloudfront.KeyGroup(this, 'PortfolioKeyGroup', {
      items: [cfPublicKey],
      comment: 'Grupo de llaves autorizadas para archivos privados',
    });

    this.distribution = new cloudfront.Distribution(this, 'PortfolioDistribution', {
      defaultBehavior: {
        origin: s3Origin,
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
        cachePolicy: cloudfront.CachePolicy.CACHING_OPTIMIZED,
        allowedMethods: cloudfront.AllowedMethods.ALLOW_GET_HEAD,
      },
      // Optimización global (América Latina, Europa, Asia, América del Norte)
      priceClass: cloudfront.PriceClass.PRICE_CLASS_ALL,
      comment: 'Distribución global para activos de portafolio',
    });

    this.distribution.addBehavior('*/private/*', s3Origin, {
      viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      trustedKeyGroups: [keyGroup],
    });

    this.bucket.addToResourcePolicy(
      new iam.PolicyStatement({
        actions: ['s3:GetObject'],
        resources: [this.bucket.arnForObjects('*')],
        principals: [new iam.ServicePrincipal('cloudfront.amazonaws.com')],
        conditions: {
          StringEquals: {
            'AWS:SourceArn': `arn:aws:cloudfront::${this.account}:distribution/${this.distribution.distributionId}`,
          },
        },
      })
    );

    this.portfoliosTable = new dynamodb.Table(this, 'PortfoliosTable', {
      partitionKey: {
        name: 'studentId',
        type: dynamodb.AttributeType.STRING
      },
      sortKey: { name: 'publishedAt', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      pointInTimeRecovery: false,
    });

    this.portfoliosTable.addGlobalSecondaryIndex({
      indexName: 'VisibilityIndex',
      partitionKey: {
        name: 'visibility',
        type: dynamodb.AttributeType.STRING
      },
      sortKey: {
        name: 'publishedAt',
        type: dynamodb.AttributeType.STRING
      },
      projectionType: dynamodb.ProjectionType.ALL,
    });

    new cdk.CfnOutput(this, 'BucketName', {
      value: this.bucket.bucketName,
      description: 'Nombre del Bucket S3 de portafolios',
    });

    new cdk.CfnOutput(this, 'TableName', {
      value: this.portfoliosTable.tableName,
      description: 'Nombre de la tabla de DynamoDB de Portafolios',
    });

    new cdk.CfnOutput(this, 'CloudFrontDomainName', {
      value: this.distribution.distributionDomainName,
      description: 'Dominio de CloudFront para acceso público/optimizado',
    });

    new cdk.CfnOutput(this, 'KeyPairId', { value: cfPublicKey.publicKeyId });
  }

}
