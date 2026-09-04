# stockroom-deployment  ![VeraCode Badge](https://moocher-uproot-cobbler.ngrok-free.dev/badgeService?businessApplicationId=5eb7b1610439979c1b47003845ce72247b106215)

    
Terraform + GitHub Actions deployment repo for the **Stockroom** application.

This repo contains no application code. It owns all infrastructure-as-code and the
CI/CD pipeline that deploys two services to AWS ECS Fargate:

| Service | Description |
| ------- | ----------- |
| `stockroom-api` | Python/FastAPI inventory management API |
| `stockroom-frontend` | React single-page application |

---

## How deployments work

Deployments are triggered by merging a pull request (MR) into the `release/prod` branch.
The GitHub Actions workflow (`.github/workflows/deploy.yml`) then:

1. Authenticates to AWS via OIDC (no long-lived keys).
2. Initialises Terraform against an S3 remote backend.
3. Runs `terraform plan` to preview changes.
4. **(Trust Authority gate — see below)**
5. Runs `terraform apply` to push the changes live.

### Trust Authority integration point

There is a clearly annotated placeholder comment in `.github/workflows/deploy.yml`
immediately before the `Terraform Apply` step:

```yaml
# NOTE: Veracode Repo Tools inserts a Trust Authority decision gate here.
# Before applying, it calls POST /decisions/evaluate with the Asset Snapshot IDs
# produced by the AST scans in each service repo's CI pipeline.
# If Trust Authority returns "Unsafe to Ship", this workflow fails and
# terraform apply never runs.
```

When Veracode Repo Tools are configured, they replace this comment with a live step
that calls the Trust Authority API and fails the workflow if the security posture is
unacceptable.

---

## Required GitHub secrets and variables

Configure these in **Settings → Secrets and variables → Actions** for the repository.

### Secrets

| Name | Description |
| ---- | ----------- |
| `AWS_ROLE_ARN` | ARN of the IAM role to assume via OIDC (e.g. `arn:aws:iam::123456789012:role/github-actions-stockroom`) |
| `TF_STATE_BUCKET` | S3 bucket name that holds the Terraform state file |
| `ECR_REGISTRY` | ECR registry hostname (e.g. `123456789012.dkr.ecr.us-east-1.amazonaws.com`) |
| `DB_PASSWORD` | Password for the RDS PostgreSQL database |
| `API_KEY` | API key injected into the stockroom-api container as `X-API-Key` |

### Variables (non-secret)

| Name | Description | Default |
| ---- | ----------- | ------- |
| `AWS_REGION` | AWS region to deploy into | `us-east-1` |

---

## Prerequisites for local Terraform runs

- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with credentials that have sufficient IAM permissions.
- [Terraform 1.7+](https://developer.hashicorp.com/terraform/downloads)
- An existing S3 bucket for remote state storage.

---

## Quick deploy steps (local)

1. **Copy and fill in the example tfvars:**

   ```bash
   cp terraform.tfvars.example terraform/terraform.tfvars
   # Edit terraform/terraform.tfvars and populate all values
   ```

   > `terraform.tfvars.example` lives at the repo root for easy discovery.
   > The actual `terraform/terraform.tfvars` file used by Terraform lives inside
   > `terraform/` so that `terraform plan/apply` picks it up automatically via the
   > `-var-file=terraform.tfvars` flag. **Never commit `terraform/terraform.tfvars`
   > — it contains secrets.**

2. **Initialise Terraform:**

   ```bash
   cd terraform
   terraform init \
     -backend-config="bucket=<YOUR_TF_STATE_BUCKET>" \
     -backend-config="key=stockroom/prod/terraform.tfstate" \
     -backend-config="region=us-east-1"
   ```

3. **Plan:**

   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

4. **Apply:**

   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

---

## Infrastructure overview

```shell
VPC (10.0.0.0/16)
├── Public subnets (10.0.1.0/24, 10.0.2.0/24)
│   ├── Internet Gateway
│   ├── NAT Gateway (single, in AZ-a for cost)
│   └── Application Load Balancer
│       ├── /api/* → stockroom-api ECS service (port 8000)
│       └── default → stockroom-frontend ECS service (port 80)
└── Private subnets (10.0.10.0/24, 10.0.11.0/24)
    ├── ECS Fargate tasks (api + frontend)
    └── RDS PostgreSQL 16 (db.t3.micro)
```

ECR repositories are created for both services so that the service CI pipelines
can push images before triggering a deploy.
