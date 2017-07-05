#!/usr/bin/env bash
#
# Functions to interact with EC2

unset ERROR
CURL_CMD="curl -s --connect-timeout 3"

ACLExists() {
    if [[ -z "$1" ]]; then
      echo "$FUNCNAME: ACL ID must be provided"
      exit 1
    fi
    aws ec2 describe-network-acls --network-acl-ids $1 >/dev/null  && echo 0
}

disassociateRouteTable() {
  if [[ $(routeTableExists $1) -eq 0 ]]; then
    aws ec2 disassociate-route-table --association-id $1
  else
    echo "Routetable $1 does not exist"
  fi
}

deleteACL() {
  if [[ $(ACLExists $1) -eq 0 ]]; then
    aws ec2 delete-network-acl --network-acl-id $1
  else
    echo "ACL $1 does not exist"
  fi
}

deleteInternetGateway() {
  if [[ $(internetGatewayExists $1) -eq 0 ]]; then
    aws ec2 delete-internet-gateway --internet-gateway-id $1
  else
    echo "Internet Gateway $1 does not exist"
  fi
}

deleteLoadbalancer() {
  if [[ $(loadbalancerExists $1) -eq 0 ]]; then
    aws elb delete-load-balancer --load-balancer-name $1
    if [[ "$?" -eq "0" ]]; then
        echo "Loadbalancer $1 deleted"
    else
        echo "Failed to delete loadbalancer $1"
    fi
  else
    echo "Loadbalancer $1 does not exist"
  fi
}

deleteSecurityGroup() {
  if [[ $(securityGroupExists $1) -eq 0 ]]; then
    aws ec2 delete-security-group --group-id $1
  else
    echo "SecurityGroup $1 does not exist"
  fi
}

deleteSubnet() {
  if [[ $(subnetExists $1) -eq 0 ]]; then
    aws ec2 delete-subnet --subnet-id $1
  else
    echo "Subnet $1 does not exist"
  fi
}

deleteRoute() {
  if [[ $(routeTableExists $1) -eq 0 ]]; then
    aws ec2 delete-route --route-table-id $1 --destination-cidr-block $2
  else
    echo "Route $1 does not exist"
  fi
}

deleteRouteTable() {
  if [[ $(routeTableExists $1) -eq 0 ]]; then
    aws ec2 delete-route-table --route-table-id $1
  else
    echo "Routetable $1 does not exist"
  fi
}

deleteVPC() {
  if [[ $(VPCExists $1) -eq 0 ]]; then
    aws ec2 delete-vpc --vpc-id $1
  else
    echo "VPC $1 does not exist"
  fi
}

describeInternetGateways() {
  aws ec2 describe-internet-gateways --internet-gateway-ids $1 --output text
}

describeSubnets() {
  aws ec2 describe-subnets --subnet-ids $1 --output text
}

describeRouteTables() {
  aws ec2 describe-route-tables --route-table-ids $1 --output text
}

detachInternetGateway() {
  if [[ $(internetGatewayExists $1) -eq 0 && $(vpcExists $2) -eq 0  ]]; then
    aws ec2 detach-internet-gateway --internet-gateway-id $1 --vpc-id $2
  else
    echo "Routetable $1 or VPC $2 does not exist"
  fi
}

getInstanceId() {
  ${CURL_CMD} http://169.254.169.254/latest/meta-data/instance-id
}

getRegion() {
  ${CURL_CMD} http://169.254.169.254/latest/dynamic/instance-identity/document | grep '\"region\"' | cut -d\" -f4
}

getPublicIP() {
  #ARG1: Optional instance-id. If instance ID is not provided use getInstanceId to read it from meta-data
  #ARG2: Optional region. If region is not provided and envrionment variable AWS_DEFAULT_REGION is not set
  #      attempt to resolve it by querying instance meta-data
  #returns: Public IP address of the instance
  if [[ -z $1 ]]; then
    INSTANCEID=$(getInstanceId)
  else
    INSTANCEID=$1
  fi
  if [[ ! -z $2 ]]; then
    REGION=$2
  elif [[ ! -z ${AWS_DEFAULT_REGION} ]]; then
    REGION=${AWS_DEFAULT_REGION}
  else
    REGION=$(getRegion)
  fi
  aws ec2 describe-instances --region ${REGION} --instance-ids ${INSTANCEID}  --query 'Reservations[].Instances[].PublicIpAddress' --output text
}

getPrivateIP() {
  #ARG1: Optional instance-id. If instance ID is not provided use getInstanceId to read it from meta-data
  #ARG2: Optional region. If region is not provided and envrionment variable AWS_DEFAULT_REGION is not set
  #      attempt to resolve it by querying instance meta-data
  #returns: Private IP address of the instance
  if [[ -z $1 ]]; then
    INSTANCEID=$(getInstanceId)
  else
    INSTANCEID=$1
  fi
  if [[ ! -z $2 ]]; then
    REGION=$2
  elif [[ ! -z ${AWS_DEFAULT_REGION} ]]; then
    REGION=${AWS_DEFAULT_REGION}
  else
    REGION=$(getRegion)
  fi
  aws ec2 describe-instances --region ${REGION} --instance-ids ${INSTANCEID}  --query 'Reservations[].Instances[].PrivateIpAddress' --output text
}

getStackName() {
  #ARG1: Optional instance-id. If instance ID is not provided use getInstanceId to read it from meta-data
  #ARG2: Optional region. If region is not provided and envrionment variable AWS_DEFAULT_REGION is not set
  #      attempt to resolve it by querying instance meta-data
  #returns: cloudformation stack name of an instance

  if [[ -z $1 ]]; then
    INSTANCEID=$(getInstanceId)
  else
    INSTANCEID=$1
  fi
  if [[ ! -z $2 ]]; then
    REGION=$2
  elif [[ ! -z ${AWS_DEFAULT_REGION} ]]; then
    REGION=${AWS_DEFAULT_REGION}
  else
    REGION=$(getRegion)
  fi
  aws ec2 describe-tags --region ${REGION} --filters "Name=resource-id,Values=${INSTANCEID}" --output text | grep aws:cloudformation:stack-name | awk '{print $5}'
}

getTagValueByKey() {
  # ARG1 - Tag key to lookup
  aws ec2 describe-tags --region $(getRegion) --filters "Name=resource-id,Values=$(getInstanceId)" --output text | grep $1 | awk '{print $5}'
}

internetGatewayExists() {
  if [[ -z "$1" ]]; then
    echo "$FUNCNAME: Internet Gateway ID must be provided"
    exit 1
  fi
  aws ec2 describe-internet-gateways --internet-gateway-ids $1 >/dev/null  && echo 0
}

loadbalancerExists() {
  if [[ -z "$1" ]]; then
    echo "$FUNCNAME: Loadbalancer name must be provided"
    exit 1
  fi
  aws elb describe-load-balancers --load-balancer-names $1 >/dev/null  && echo 0
}

routeTableExists() {
  if [[ -z "$1" ]]; then
    echo "$FUNCNAME: Routetable ID must be provided"
    exit 1
  fi
  aws ec2 describe-route-tables --route-table-ids $1 >/dev/null  && echo 0
}

securityGroupExists() {
  if [[ -z "$1" ]]; then
    echo "$FUNCNAME: SecurityGroup ID must be provided"
    exit 1
  fi
  aws ec2 describe-security-groups --group-ids $1 >/dev/null  && echo 0
}

subnetExists() {
  if [[ -z "$1" ]]; then
    echo "$FUNCNAME: SubnetID must be provided"
    exit 1
  fi
  aws ec2 describe-subnets --subnet-ids $1 >/dev/null  && echo 0
}

VPCExists() {
  if [[ -z "$1" ]]; then
    echo "$FUNCNAME: VPC ID must be provided"
    exit 1
  fi
  aws ec2 describe-vpcs --vpc-ids $1 >/dev/null  && echo 0
}
