# Warnet AMI Build & SSL Certificate Update Guide

This guide covers how to:
1. Generate new Let's Encrypt SSL certificates for war.pianka.io
2. Build a new AMI with updated certificates using Packer
3. Deploy the new AMI

## Prerequisites

- AWS credentials with Route53 and EC2 permissions
- acme.sh installed (for certificate generation)
- Packer installed
- Terraform installed

## Part 1: Generate New Let's Encrypt Certificate

### 1.1 Set Up AWS Credentials

Export your AWS credentials as environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
```

To get AWS credentials:
- Go to AWS Console → IAM → Users → [Your User]
- Click "Security credentials" tab
- Under "Access keys", click "Create access key"
- Choose "Command Line Interface (CLI)" as use case
- Copy both the Access Key ID and Secret Access Key

### 1.2 Install acme.sh (if not already installed)

```bash
curl https://get.acme.sh | sh -s email=your-email@example.com
source ~/.bashrc
```

### 1.3 Generate Certificate

```bash
# Generate certificate using Route53 DNS validation (automated)
acme.sh --issue --dns dns_aws -d war.pianka.io
```

This will:
- Create a DNS TXT record in Route53 automatically
- Validate domain ownership
- Generate the certificate
- Store files in `~/.acme.sh/war.pianka.io_ecc/`

### 1.4 Copy Certificates to Repository

```bash
# Copy and rename to the format needed by nginx
cp ~/.acme.sh/war.pianka.io_ecc/fullchain.cer ~/repos/Warnet/ansible/resources/fullchain.pem
cp ~/.acme.sh/war.pianka.io_ecc/war.pianka.io.key ~/repos/Warnet/ansible/resources/privkey.pem

# Set proper permissions
chmod 644 ~/repos/Warnet/ansible/resources/fullchain.pem
chmod 600 ~/repos/Warnet/ansible/resources/privkey.pem

# Verify files exist
ls -lh ~/repos/Warnet/ansible/resources/*.pem
```

**Important Notes:**
- `privkey.pem` is gitignored and will NOT be committed to version control
- Certificates are valid for 90 days and must be renewed before expiration
- You do NOT need the old private key to generate a new certificate

## Part 2: Build AMI with Packer

### 2.1 Navigate to Packer Directory

```bash
cd ~/repos/Warnet/packer
```

### 2.2 Initialize Packer (first time only)

```bash
packer init warnet.pkr.hcl
```

This downloads the required Packer plugins.

### 2.3 Validate Configuration

```bash
packer validate -var-file=warnet.pkrvars.hcl warnet.pkr.hcl
```

This checks for syntax errors before building.

### 2.4 Build the AMI

```bash
packer build -var-file=warnet.pkrvars.hcl warnet.pkr.hcl
```

**What happens during the build (10-20 minutes):**

1. Launches a t2.large EC2 instance in us-east-2
2. Runs 4 Ansible playbooks sequentially:
   - `warnet.yaml` - Installs Init6 game server and WarCast
   - `agent.yaml` - Installs monitoring agent
   - `nginx.yaml` - Configures nginx with SSL certificates
   - `iptables.yaml` - Sets up firewall rules
3. Creates AMI snapshot
4. Distributes AMI to 14+ AWS regions:
   - US: us-east-2, us-east-1, us-west-1, us-west-2
   - Canada: ca-central-1, ca-west-1
   - Mexico: mx-central-1
   - Europe: eu-central-1, eu-west-1, eu-west-2, eu-south-1, eu-west-3, eu-south-2, eu-north-1, eu-central-2
5. Terminates the build instance
6. Outputs manifest with AMI IDs

**Expected output:**
```
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.warnet: AMIs were created:
us-east-2: ami-0xxxxxxxxxxxxx
us-east-1: ami-0xxxxxxxxxxxxx
...
```

**Save the us-east-2 AMI ID** - you'll need it for deployment.

## Part 3: Deploy New AMI with Terraform (not needed unless redeploying all of Warnet)

### 3.1 Update Terraform Configuration

Edit `terraform/ec2.tf` and update the AMI ID:

```hcl
resource "aws_instance" "warnet" {
  ami           = "ami-0XXXXXXXXXXXXXXXXX"  # Replace with new AMI ID from packer build
  instance_type = "t2.medium"
  # ... rest of config remains unchanged
}
```

### 3.2 Preview Changes

```bash
cd ~/repos/Warnet/terraform
terraform plan
```

Review the output. It should show:
- EC2 instance will be replaced (due to AMI change)
- Other resources should remain unchanged

### 3.3 Apply Changes

```bash
terraform apply
```

Type `yes` when prompted.

**What happens:**
- Terraform terminates the old EC2 instance
- Launches a new instance using the new AMI
- Route53 DNS points to the new instance
- The new instance has updated SSL certificates baked in

### 3.4 Verify Deployment

Check the SSL certificate is updated:

```bash
echo | openssl s_client -servername war.pianka.io -connect war.pianka.io:443 2>/dev/null | openssl x509 -noout -dates
```

You should see the new expiration date (90 days from certificate generation).

## Architecture Overview

### Certificate Storage
- Source files: `ansible/resources/fullchain.pem` and `ansible/resources/privkey.pem`
- Deployed to: `/etc/letsencrypt/live/war.pianka.io/` on AMI
- Used by: nginx for HTTPS termination

### AMI Components
The built AMI includes:
- Init6 game server (running on port 64808)
- WarCast application
- Nginx reverse proxy with SSL termination
- Monitoring agent
- Firewall rules (nftables)

### Infrastructure
- EC2 instances are launched from the AMI
- Lambda orchestrator periodically rotates instances across regions
- Route53 DNS points to the active instance
- Security groups control network access

## Key Files Reference

### Certificate Files
- `ansible/resources/fullchain.pem` - Public certificate chain (tracked in git)
- `ansible/resources/privkey.pem` - Private key (gitignored, NEVER commit)

### Packer Files
- `packer/warnet.pkr.hcl` - Main Packer configuration
- `packer/warnet.pkrvars.hcl` - Build variables
- `packer-manifest.json` - Build output (generated, gitignored)

### Ansible Playbooks
- `ansible/warnet.yaml` - Core application setup
- `ansible/agent.yaml` - Monitoring agent setup
- `ansible/nginx.yaml` - Nginx and SSL configuration
- `ansible/iptables.yaml` - Firewall rules

### Terraform Files
- `terraform/ec2.tf` - EC2 instance configuration (update AMI ID here)
- `terraform/iam.tf` - IAM roles and policies

## Troubleshooting

### Certificate Generation Issues

**Problem:** `SignatureDoesNotMatch` error from AWS
**Solution:** Check your AWS credentials are correct. The credentials file format may have issues. Use environment variables instead:
```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

**Problem:** DNS validation fails
**Solution:** Ensure your IAM user has Route53 permissions:
- `route53:ChangeResourceRecordSets`
- `route53:GetChange`
- `route53:ListHostedZones`

### Packer Build Issues

**Problem:** Packer can't connect to the instance
**Solution:**
- Ensure VPC and subnet IDs in `warnet.pkrvars.hcl` are correct
- Check security groups allow SSH access
- Verify the SSH key `warnet.pem` exists

**Problem:** Ansible playbook fails
**Solution:** Check the Ansible playbook logs in the Packer output for specific errors

### Terraform Deployment Issues

**Problem:** Terraform can't destroy the old instance
**Solution:** Check the instance exists and isn't protected from termination

**Problem:** New instance doesn't come up
**Solution:** Check CloudWatch logs and EC2 console for errors

## Security Notes

1. **Never commit `privkey.pem`** - It's gitignored for security
2. **Rotate AWS access keys** if they're exposed (like in chat logs)
3. **AMIs are encrypted at rest** - Private keys baked into AMI are protected
4. **Certificates expire in 90 days** - Set a reminder to renew

## Certificate Renewal Schedule

Let's Encrypt certificates are valid for 90 days. Schedule renewals at:
- **Day 60**: Start renewal process
- **Day 75**: Urgently renew if not done
- **Day 85**: Emergency renewal (5 days before expiration)

To automate this in the future, consider setting up certbot on the EC2 instances with automatic renewal via cron.

## To Do List
- [x] Block all AWS traffic (https://ip-ranges.amazonaws.com/ip-ranges.json)
- [ ] Background cron job to make sure the server finishes booting up
- [x] Add a Let's Encrypt certificate to the websocket endpoint

## Questions or Issues?

- Packer documentation: https://www.packer.io/docs
- acme.sh documentation: https://github.com/acmesh-official/acme.sh
- Let's Encrypt documentation: https://letsencrypt.org/docs/


