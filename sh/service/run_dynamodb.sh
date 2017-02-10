#!/bin/bash

# Script to start local DynamoDB in directory specified by variable DYNAMODB_DIR
# If updating DYNAMODB_DIR value remember to change the path in Dockerfile
#
# © Jussi Heinonen 20170102

DYNAMODB_DIR="/opt/dynamodb"
mkdir -p ${DYNAMODB_DIR}
echo "Starting DynamoDB in ${DYNAMODB_DIR}"
java -Djava.library.path=${DYNAMODB_DIR}/DynamoDBLocal_lib -jar ${DYNAMODB_DIR}/DynamoDBLocal.jar -sharedDb -inMemory &
echo "DynamoDB running"
