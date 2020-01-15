# AWS VPC With Cloudformation Example

---

## 3 Tier Network

> In our 3 tier network, let's say we want to have the following requirements met:
- Scalability and High Availability: A moderately sized VPC with room to grow, scalable network devices with failover capabilities.
- Public Subnet: This could be used as a landing zone for a VPN, bastion, servers that need internet access, etc..
- App Subnet: This private subnet would be app tier resources that will need access to AWS web services like S3 and SSM, may also need to be able to download patches and connect to other API's on the internet, but shouldn't be publicly available.
- Backend Subnet: This private subnet would be backend tier for resources like RDS instances or VPC Lambdas that don't need access to the internet at all and shouldn't be publicly available, but still may need access to S3 and SSM.

You don't need to be an expert on subnetting, but you should be aware of a few basic things. I would suggest you take a look at this guide on [VPC Sizing](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#VPC_Sizing) and this [VPC FAQ](https://aws.amazon.com/answers/networking/aws-single-vpc-design/) before you go any further if you're new to these concepts like [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) and subnetting. You might leave room in your VPC like this when you have development teams that will be expected to create their own subnets for their applications or maybe you want to increase the number of availability zones you're using for failover at a later time, but nobody is stopping you from getting creative with your subnetting, but be congizant of your [limits](https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html). For simplicity's sake we could have a /16 CIDR block for our VPC and start with /24 CIDR blocks for our subnets. This gives us a subnet with 251 IP addresses available, bearing in mind that AWS reserves certain IP addresses, particularly the first 4 and the last in the subnet.

| Resource | CIDR | Availability Zone |
| ----------- | ----------- | ----------- |
| VPC | 10.0.0.0/16 | - |
| Primary Public Subnet | 10.0.0.0/24 | us-east-1a |
| Secondary Public Subnet | 10.0.8.0/24 | us-east-1b |
| Primary App Subnet | 10.0.16.0/24 | us-east-1a |
| Secondary App Subnet | 10.0.24.0/24 | us-east-1b |
| Primary Backend Subnet | 10.0.32.0/24 | us-east-1a |
| Secondary Backend Subnet | 10.0.40.0/24 | us-east-1b |

We're going to use an [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code) service called [CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) to create a VPC using multiple availability zones for failover and design for failure for redundancy.

We know we need access to the internet, so we need an internet gateway.

> Internet Gateway
An internet gateway is a horizontally scaled, redundant, and highly available VPC component that allows communication between instances in your VPC and the internet. It therefore imposes no availability risks or bandwidth constraints on your network traffic.
An internet gateway serves two purposes: to provide a target in your VPC route tables for internet-routable traffic, and to perform network address translation (NAT) for instances that have been assigned public IPv4 addresses.

We know that our App tier needs access to the internet to connect to API's and may need to download software patches from time to time, so we'll need a NAT gateway and we can't tolerate any failure and we have the resources to build for failure, so our failover subnet(s) will have NAT gateway(s) for redundancy. NAT gateways are automatically scaled AWS resources like internet gatewways, but will allow our private resources to have outbound access to the internet and allow inbound responses, but not allow inbound connections from the internet. Be careful not to confuse NAT gateway with NAT instance. A NAT instance will create a bottleneck in our infrastructure and cost more in the long run. NAT gateways and NAT instances are going to add costs, so be mindful of the pricing.

> NAT
You can use a NAT device to enable instances in a private subnet to connect to the internet (for example, for software updates) or other AWS services, but prevent the internet from initiating connections with the instances. A NAT device forwards traffic from the instances in the private subnet to the internet or other AWS services, and then sends the response back to the instances. When traffic goes to the internet, the source IPv4 address is replaced with the NAT device’s address and similarly, when the response traffic goes to those instances, the NAT device translates the address back to those instances’ private IPv4 addresses.

We know that our resources need access to AWS web services like S3 and SSM, so we'll create VPC endpoints for those. VPC endpoints will allow your private resources to connect to S3 and SSM without the need for a public IP address or using the internet. This adds security to your application since your private data isn't travelling the internet via an internet gateway or a NAT gateway, especially where secrets in SSM Parameter Store are concerned. An interface endpoint uses PrivateLink, which has it's own costs, which you should be aware of. Gateway endpoints, such as S3, don't use PrivateLink, so there aren't any additional costs.

> VPC Endpoints
A VPC endpoint enables you to privately connect your VPC to supported AWS services and VPC endpoint services powered by PrivateLink without requiring an internet gateway, NAT device, VPN connection, or AWS Direct Connect connection. Instances in your VPC do not require public IP addresses to communicate with resources in the service. Traffic between your VPC and the other service does not leave the Amazon network.

Refer to the `template.yml` for more information

---

### Deploying

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
