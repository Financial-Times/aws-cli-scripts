#!/usr/bin/env bash
#
# Functions to interact with EC2
unset ERROR
declare -r CURL_CMD="curl -s --connect-timeout 3"

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
  #returns: Public IP address if the instance
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

getTagValueByKey() {
  # ARG1 - Tag key to lookup
  aws ec2 describe-tags --region $(getRegion) --filters "Name=resource-id,Values=$(getInstanceId)" --output text | grep $1 | awk '{print $5}'
}
