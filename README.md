# MultiversX API Deployer

This repository provides tools to quickly deploy a complete infrastructure with Docker Compose to run the MultiversX API. The setup is designed with minimal configuration requirements to enable rapid deployment on any server.

We simplified the procedure and automated the deployment process to make it accessible to a wider audience. The deployment includes all necessary components to access blockchain data and run queries on your own.

You will need to run 3 commands to deploy the infrastructure:
1. **Initialize the server**: Setup requirements and create a new user for running services.
2. **Deploy the infrastructure**: Install the different services and configure their environments
3. **Start the services**: Run the services and expose the API for external access.




### **This deployment includes:**
- [**An Observing Squad**](https://docs.multiversx.com/integrators/observing-squad ): Access blockchain data by running observer nodes.
- [**ElasticSearch Indexer**](https://docs.multiversx.com/sdk-and-tools/indexer/#observer-client): Convert raw blockchain data for efficient querying.
- [**ElasticSearch Database**](https://github.com/elastic/elasticsearch): Store the converted blockchain data.
- [**Kibana**](https://github.com/elastic/kibana): Visualize data and logs from the blockchain.
- [**MultiversX API**](https://docs.multiversx.com/sdk-and-tools/rest-api/multiversx-api/): Query blockchain data externally via a standard API.


## **0 - Prerequisites**

### **Hardware**
To support the infrastructure's heavy load, we recommend deploying on a bare-metal server with the following specifications depending on your needs:

- **12-16 CPU cores**
- **32-64 GB RAM**
- **1 TB SSD storage**
- **1 Gbps network bandwidth**

### **Security**
Before deployment:
- Secure your server with an **SSH key**.
- Ensure no sensitive data is on the server. Although the API is stateless, misuse of the infrastructure could disrupt services.

### **Configuration**
At the root of this repository you will find the file named config.cfg. It contains variables that can be configured to customize the deployment.

The following variables are available:
- **USERNAME**: The username for the new user that will be created.
- **NETWORK**: The network to deploy. Currently support `mainnet`, `devnet` and `testnet` networks.

Currently, the deployment is configured with default settings. As development progresses, more configuration options will be added, such as enabling a **full history node** or customizing ElasticSearch settings.

## **1 - Initialize Server**

1. Be sure to be on you root user

2. You will need this repository on your machine before to start:
```bash
   git clone https://github.com/PhyByte/mvx-api-deployer.git
```

3. Run the installation script that will setup the requirements for the deployment:
```bash
  cd mvx-api-deployer
   ./1-Init.sh
```

### **What this script does:**
- Updates and upgrades your system.
- Installs Docker and Docker Compose.
- Creates a new user, `mvx-api`, for running services.
- Transfer your cloned and modified repository to the `mvx-api` user.

---

## **2 - Install Services**

At the end of the previous step you should be logged in as the `mvx-api` user. If not, switch to the `mvx-api` user before to continue.

As you already configured the `config.cfg` file, you can now deploy the infrastructure by running: 
```bash
   cd ~/mvx-api-deployer
   ./2-Install.sh
 ```


### **What this script does:**
- Setup the Observing Squad with `ElasticSearch Indexer Enabled`.
- Setup the ElasticSearch Indexer and deploy the ElasticSearch Database with Kibana.
- Setup the MultiversX API.

