#! /bin/bash
# http://serverfault.com/questions/578921/how-would-you-go-about-listing-instances-using-aws-cli-in-certain-vpc-with-the-t

case "$1" in
  master)
    nodefilter="Name=tag:AnsibleGroup,Values=masters" ;;
  node)
    nodefilter="Name=tag:AnsibleGroup,Values=nodes" ;;
  infra)
    nodefilter="Name=tag:AnsibleGroup,Values=infranodes" ;;
  nfs)
    nodefilter="Name=tag:AnsibleGroup,Values=nfs" ;;
  bastion)
    nodefilter="Name=tag:AnsibleGroup,Values=bastions" ;;
  all)
    nodefilter="" ;;

    *) ;;
esac

aws ec2 describe-instances --output text \
  --region $3 \
  --filters "Name=instance-state-name,Values=running" \
    "Name=tag:Project,Values=$2" \
   $nodefilter \
  --query 'Reservations[*].Instances[*].[ PublicDnsName,PrivateDnsName,Placement.AvailabilityZone,Tags[?Key==`AnsibleGroup`].Value[] ]' | \
  sed '$!N;s/\n/ /' | sort -k 3
