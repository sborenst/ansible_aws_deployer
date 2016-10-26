# OpenShift Ansible AWS Provisioner
This repository contains various Ansible playbooks, templates, and other support
files used to provision OpenShift environments onto AWS.

## OpenShift Workshops
The `bu-workshop` files stand up an environment running on [Amazon Web
Services](https://aws.amazon.com). They use CloudFormations, EC2, VPC, and Route 53
services within AWS. They provision several RHEL7-based servers that are
participating in an [OpenShift 3](https://www.openshift.com/container-platform/)
environment that has persistent storage for its infrastructure components.

Additionally, the scripts set up OpenShift's metrics and logging aggregation
services.

Lastly, the scripts set up and configure various workshop services, users, and
volumes for those users

### Environment

#### OpenShift Hosts
* one master
* one infrastructure node
* six "application" nodes
* one nfs server
* one bastion host

#### Workshop Services
* GitLab
* Nexus
* Workshop lab guide built via S2I

### Prerequisites
In order to use these scripts, you will need to set a few things up.

- An AWS IAM account with the following permissions:
  - Policies can be defined for Users, Groups or Roles
  - Navigate to: AWS Dashboard -> Identity & Access Management -> Select Users or Groups or Roles -> Permissions -> Inline Policies -> Create Policy -> Custom Policy
    - Policy Name: openshift (your preference)
    - Policy Document:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1459269951000",
            "Effect": "Allow",
            "Action": [
                "cloudformation:*",
                "iam:*",
                "route53:*",
                "elasticloadbalancing:*",
                "ec2:*",
                "cloudwatch:*",
                "autoscaling:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```
  Finer-grained permissions are possible, and pull requests are welcome.

- AWS credentials for the account above must be used with the AWS command line
    tool (detailed below)
- A route53 [public hosted
    zone](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)
    is required for the scripts to create the various DNS entries for the
    resources it creates. Two DNS entries will be created for workshops:
  - `master.guid.domain.tld` - a DNS entry pointing to the master
  - `*.cloudapps.guid.domain.tld` - a wildcard DNS entry pointing to the
      router/infrastructure node
- An EC2 SSH keypair should be created in advance and you should save the key
    file to your system.
- A Red Hat Customer Portal account that has appropriate OpenShift subscriptions
    - Red Hat employee subscriptions can be used

## Software Requirements
### Packaged Software
- [Python](https://www.python.org) version 2.7.x (3.x untested and may not work)
- [Python Boto](http://docs.pythonboto.org) version 2.41 or greater
- [Ansible](https://github.com/ansible/ansible) version 2.1.2 or greater

Python and the Python dependencies may be installed via your OS' package manager
(eg: python2-boto on Fedora/CentOS/RHEL) or via
[pip](https://pypi.python.org/pypi/pip). [Python
virtualenv](https://pypi.python.org/pypi/virtualenv) can also work.

## Usage
### Configure the EC2 Credentials
You will need to place your EC2 credentials in the ~/.aws/credentials file:
```
[default]
aws_access_key_id = foo
aws_secret_access_key = bar
```

### Add the SSH Key to the SSH Agent
If your operating system has an SSH agent and you are not using your default
configured SSH key, you will need to add the private key you use with your EC2
instances to your SSH agent: 
```
ssh-add <path to key file>
```

Note that if you use an SSH config that specifies what keys to use for what
hosts this step may not be necessary.

### Vars files
Each "environment" has two vars files `_vars` and `_secret_vars` in the
`Environment` folder. The `example_secret_vars` file shows the format for what
to put in your `bu-workshop_secret_vars` file.

The `bu-workshop_vars` file contains most of the configuration settings to use
in the environment. Really the only ones you should expect to modify are the
domain-related and number of (workshop) user options. All AMIs and sizing is
preconfigured and automatic for the AWS region you deploy into.

### CloudFormation Template
If you want more or less nodes, be sure to change the value `6` in the
CloudFormation template
(`ansible/files/cf_templates/cf.bu-workshop.template.j2`) in the application
autoscaling group.

### Ansible
Once you have installed your prerequisites and have configured all settings and
files, simply run Ansible like so:

    ansible-playbook -i 127.0.0.1 ansible/bu-workshop.yml -e "config=bu-workshop" -e "aws_region=us-west-1" -e "guid=atlanta"

Be sure to exchange `guid` for a sensible prefix of your choosing.

## Cleanup
Just go into your AWS account to the CloudFormation section and find the
deployed stack in the proper region. Delete it.

## Troubleshooting
Information will be added here as problems are solved. So far it's pretty
vanilla, but quite slow. Expect at least an hour for deployment, if not two or
more if you are far from the system(s).
