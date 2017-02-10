#!/usr/bin/env bash
#
# Functions to interact with EC2
unset ERROR

getInstanceId() {
  ${CURL_CMD} http://169.254.169.254/latest/meta-data/instance-id
}

getRegion() {
  ${CURL_CMD} http://169.254.169.254/latest/meta-data/hostname | cut -d '.' -f 2
}

getPublicIP() {
  #ARG1: Optional instance-id. If instance ID is not provided use getInstanceId to read it from meta-data
  #ARG2: Optional region. If region is not provided and envrionment variable AWS_DEFAULT_REGION is not set
  #      attempt to resolve it by querying instance meta-data
  #returns: Public IP address if the instance
  if [[ -z $1 ]]; then
    INSTANCEID=$(getInstanceId)
  else
    INSTANCEID=$1
  fi
  if [[ -z $2 && -z ${AWS_DEFAULT_REGION} ]]; then
    AWS_DEFAULT_REGION=$(getRegion)
  else
    AWS_DEFAULT_REGION=$2
  fi
  aws ec2 describe-instances --instance-ids ${INSTANCEID}  --query 'Reservations[].Instances[].PrivateIpAddress' --output text
}
