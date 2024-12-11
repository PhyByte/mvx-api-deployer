# Multiversx Api Deployer


This repository provide the tools to quickly deploy a complete infrastyructure with docker compose to run the Multiversx API.
It remain with a minimal configuration to be able to deploy it on any server quickly.

This tool will deploy:
- An Observing Squad for access the chain data
- An elastic search indexer for convert the raw data
- An elastic search for store the converted data
- A Multiversx API for access the data from outside
- A Kibana instance for visualize the data

## Requirements

For support the heavy load of this infrastructure, we recommend to have at least a bare metal matching the following requirements:

- 16 CPU
- 64 GB of RAM
- 1 TB of SSD storage
- 1 Gbps of network bandwidth

Be sure to have at least secure your server with an ssh key, there should be no sensitive data on it but could technically be used to shutdown the api or corrupt the data.

We will also need to create a new user and install docker and docker-compose on the server but we have also a script for that.

## Installation

Login to your freashly created server and clone this repository with the root user.

```bash
$ubuntu: git clone ########TODO: ADD REPO URL HERE########
```

Then go to the repository folder and run the installation script.

```bash
$ubuntu: cd mvx-api-deployer
$ubuntu: sudo ./1-install_machine.sh
```

This will install docker with docker-compose and other dependencies then create a new user (mvx-api) and clone again this repo into the new home folder.

## Configuration

For the moment there will be no configuration as its still under very early development.
Add the possibility to setup full history 

## Deployment

To deploy the infrastructure, you just need to run the deploy script from our newly created user.

```bash
$ubuntu: sudo su - mvx-api
$mvx-api: cd
$mvx-api: cd mvx-api-deployer
$mvx-api: ./2-deploy.sh
```

This part of the script will setup the environment and all required ajustments to the docker-compose file.

You can then run the stack with the following command:

```bash
$mvx-api: docker-compose up -d
```