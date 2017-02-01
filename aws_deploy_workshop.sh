#!/bin/bash
ansible-playbook -i 127.0.0.1, ansible/main.yml -e "config_name=workshop" -e "aws_region=us-east-1" -e "guid=workshop"

