# AWS VPC With Cloudformation Example

---

## Deploying

You can deploy this from the command line, for example:

```bash
stack_name=my-vpc-example
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
    --template-file template.yml \
    --stack-name $stack_name \
    --parameter-overrides "${parameters[@]}"
```
