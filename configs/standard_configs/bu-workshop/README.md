
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
