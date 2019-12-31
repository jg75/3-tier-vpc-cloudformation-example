#! /bin/bash
parameters=(
    VpcCidrBlock='172.100.0.0/20'
    PublicSubnetCidrBlock='172.100.0.0/22'
    PublicFailOverSubnetCidrBlock='172.100.4.0/22'
    Private1SubnetCidrBlock='172.100.8.0/23'
    Private1FailOverSubnetCidrBlock='172.100.10.0/23'
    Private2SubnetCidrBlock='172.100.12.0/23'
    Private2FailOverSubnetCidrBlock='172.100.14.0/23'
)

aws cloudformation deploy \
    --template-file 3-tier-template.yml \
    --stack-name jim-vpc \
    --parameter-overrides "${parameters[@]}"
