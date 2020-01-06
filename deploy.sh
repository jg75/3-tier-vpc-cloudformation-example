#! /bin/bash

# An error occurred (ValidationError) when calling the CreateChangeSet operation: Parameters: 
# [
# must have values
parameters=(
    VpcCidrBlock='172.100.0.0/20'
    PrimaryPublicSubnetCidrBlock='172.100.0.0/22'
    SecondaryBackendSubnetCidrBlock='172.100.4.0/22'
    SecondaryPublicSubnetCidrBlock='172.100.8.0/23'
    PrimaryBackendSubnetCidrBlock='172.100.10.0/23'
    PrimaryAppSubnetCidrBlock='172.100.12.0/23'
    SecondaryAppSubnetCidrBlock='172.100.14.0/23'
)

aws cloudformation deploy \
    --template-file 3-tier-template.yml \
    --stack-name jim-vpc \
    --parameter-overrides "${parameters[@]}"
