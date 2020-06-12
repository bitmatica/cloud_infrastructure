# Terraform - Provision AWS services

This repo is meant to bootstrap AWS infrastructure, including the following:
* VPC
* EKS
* RDS
* ECR
* Route53 subdomain
* Kubernetes deployments
* Frontend hosting/deployments via S3/CloudFront
* KMS/secret management

TODO:
* SNS/SQS
* SES
* etc

After installing the AWS CLI. Configure it to use your credentials.

```shell
$ aws configure
AWS Access Key ID [None]: <YOUR_AWS_ACCESS_KEY_ID>
AWS Secret Access Key [None]: <YOUR_AWS_SECRET_ACCESS_KEY>
Default region name [None]: <YOUR_AWS_REGION>
Default output format [None]: json
```

This enables Terraform access to the configuration file and performs operations on your behalf with these security credentials.

After you've done this, initalize your Terraform workspace, which will download 
the provider and initialize it with the values provided in the `terraform.tfvars` file.

```shell
$ terraform init
Initializing modules...
Downloading terraform-aws-modules/eks/aws 9.0.0 for eks...
- eks in .terraform/modules/eks/terraform-aws-modules-terraform-aws-eks-908c656
- eks.node_groups in .terraform/modules/eks/terraform-aws-modules-terraform-aws-eks-908c656/modules/node_groups
Downloading terraform-aws-modules/vpc/aws 2.6.0 for vpc...
- vpc in .terraform/modules/vpc/terraform-aws-modules-terraform-aws-vpc-4b28d3d

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "template" (hashicorp/template) 2.1.2...
- Downloading plugin for provider "kubernetes" (hashicorp/kubernetes) 1.10.0...
- Downloading plugin for provider "aws" (hashicorp/aws) 2.52.0...
- Downloading plugin for provider "random" (hashicorp/random) 2.2.1...
- Downloading plugin for provider "local" (hashicorp/local) 1.4.0...
- Downloading plugin for provider "null" (hashicorp/null) 2.1.2...

Terraform has been successfully initialized!
```

Then, provision your infrastructure by running `terraform apply`. This will 
take approximately 10 minutes.

```shell
$ terraform apply

# Output truncated...

Plan: 51 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

# Output truncated...

Outputs:

blogmatica_dev_app_hostname = blogmatica-zbq5x90t.dev.bitmatica.com
blogmatica_dev_cluster_endpoint = https://00F81E73B092E618A9CEE372D42DE26D.gr7.us-west-2.eks.amazonaws.com
blogmatica_dev_cluster_id = blogmatica-zbq5x90t-dev
blogmatica_dev_db_instance_name = demodb
blogmatica_dev_private_subnets = [
  "subnet-00270bfe5c161efcb",
  "subnet-0ae97872ad83079f7",
]
blogmatica_dev_public_subnets = [
  "subnet-0ad5ec270c9a38f19",
  "subnet-062543dadba68009b",
]
blogmatica_dev_vpc_id = vpc-0a9ef1b6fd8375aef
region = us-west-2
```

## Configure kubectl

To configure kubetcl, you need both [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html).

The following command will get the access credentials for your cluster and automatically
configure `kubectl`.

```shell
$ aws eks --region us-east-2 update-kubeconfig --name training-eks-sR8eLIil
```

The
[Kubernetes cluster name](https://github.com/hashicorp/learn-terraform-eks/blob/master/outputs.tf#L26)
and [region](https://github.com/hashicorp/learn-terraform-eks/blob/master/outputs.tf#L21)
 correspond to the output variables showed after the successful Terraform run.

You can view these outputs again by running:

```shell
$ terraform output
```
