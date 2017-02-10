# aws-cli-scripts

A collection of Bash functions to ease interaction with [aws command line tool](https://aws.amazon.com/documentation/cli/).

## Development environment

Dev environments are built on Docker images. Dockerfiles are stored under directory dockerfiles/<service>/Dockerfile

### Building image

The following example command builds Docker image for DynamoDB local development.


`sudo docker build -f dockerfiles/dynamodb/Dockerfile -t dynamodb:dev .`

### Running image

The following example command starts dynamodb:dev image, mounts current working directory under /mnt/workspace and enables port forwarding from port 8000 to 8000

`sudo docker run -v $PWD:/mnt/repo -p 8000:8000 -it dynamodb:dev`

#### Connecting to local DynamoDB

```
aws dynamodb list-tables --endpoint-url http://localhost:8000 #Inside the container
aws dynamodb list-tables --endpoint-url http://172.17.0.1:8000 #From outside of container
```
