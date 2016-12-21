# OpenShift Ansible AWS Provisioner
This repository contains various Ansible playbooks, templates, and other support
files used to provision OpenShift environments onto AWS.

## Prerequisites
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
                "autoscaling:*",
                "s3:*"
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

### Workshop Environment
When using the "bu-workshop" playbooks, the following holds true:

#### OpenShift Hosts
* one master
* one infrastructure node
* twenty four (24) "application" nodes
* one nfs server
* one bastion host

#### Workshop Services
* GitLab
* Nexus (although unused in labs due to performance / scalability in large
  workshops)
* Workshop lab guide built via S2I

## General Usage
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
to put in your `bu-workshop_secret_vars` file, if you were using the
`bu-workshop` playbook.

The `bu-workshop_vars` file contains most of the configuration settings to use
in the environment. Really the only ones you should expect to modify are the
domain-related and number of (workshop) user options. All AMIs and sizing is
preconfigured and automatic for the AWS region you deploy into.

### CloudFormation Template
Additionally, you will need to edit the `HostedZoneId` in the CloudFormation
template to correspond to your own DNS zone.

### Ansible
Once you have installed your prerequisites and have configured all settings and
files, simply run Ansible like so:

    ansible-playbook -i 127.0.0.1 ansible/bu-workshop.yml -e "config_name=bu-workshop" -e "aws_region=us-west-1" -e "guid=atlanta"

Be sure to exchange `guid` for a sensible prefix of your choosing.

If you want more or less nodes, you can pass in the `num_nodes` variable when
calling `ansible-playbook` with the value you desire.

You must select the correct AWS region.

## Cleanup

### S3 Bucket
An S3 bucket is used to back the Docker registry. AWS will not let you delete a
non-empty S3 bucket, so you must do this manually. The `aws` CLI makes this
easy:

    aws s3 rm s3://bucket-name --recursive

Your bucket name is named `{{ config_name }}-{{ guid }}`. So, in the case of a
`bu-workshop` environment where you provided the `guid` of "Atlanta", your S3
bucket is called `bu-workshop-atlanta`.

### CloudFormation
Just go into your AWS account to the CloudFormation section in the region where
you provisioned, find the deployed stack, and delete it.

### SSH config
This Ansible script places entries into your `~/.ssh/config`. It is recommended
that you remove them once you are done with your environment.

## Troubleshooting
Information will be added here as problems are solved. So far it's pretty
vanilla, but quite slow. Expect at least an hour for deployment, if not two or
more if you are far from the system(s).

### EC2 instability
It has been seen that, on occasion, EC2 is generally unstable. This manifests in
various ways:

* The autoscaling group for the nodes takes an extremely long time to deploy, or
  will never complete deploying

* Individual EC2 instances may have terrible performance, which can result in
  nodes that seem to be "hung" despite being reachable via SSH.

There is not much that can be done in this circumstance besides starting over
(in a different region).

### Re-Running
While Ansible is idempotent and supports being re-run, there are some known
issues with doing so. Specifically:

* You should skip the tag `nfs_tasks` with the `--skip-tags` option if you
  re-run the playbook **after** the NFS server has been provisioned and
  configured. The playbook is not safe for re-run and will fail.

* You may also wish to skip the tag `bastion_proxy_config` when re-running, as
  the tasks associated with this play will re-write the same entries to your SSH
  config file, which could result in hosts becoming unexpectedly unreachable.

### Setting up AWS Client

yum install unzip -y
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
ln /usr/local/bin/aws /bin/aws
aws configure

### Sofware pre-requisite for Ansible Host
git clone git://github.com/boto/boto.git
cd boto
python setup.py install
