#!/usr/bin/env bash
#
# Functions to interact with DynamoDB
unset ERROR #

getAttributeValueFromTable() {
  # ARG1 - Table name
  # ARG2 - Attribute name
  # USAGE: getAttributeValueFromTable Config kon_dns
  if [[ "$#" -eq "2" ]] || error "${FUNCNAME} requires 2 arguments, $# given. ERROR 1." 1
  TABLE="$1"
  ATTRI="$2"
  if [[ "$(tableFound ${TABLE})" ]] || error "${FUNCNAME} Table ${TABLE} not found. ERROR 1." 1
  aws dynamodb get-item --table-name upp-cluster-config --key '{"ConfigKey":{"S":"kon_dns"}}' \
  --attributes-to-get key --endpoint-url http://localhost:8000 --output text | awk -F '\t' '{print $2}'

}

tabelFound(){
  # Check whether given DynamoDB table exist
  # ARG1 - Table name


}
