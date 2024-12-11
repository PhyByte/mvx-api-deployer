# MultiversX API Deployer

This repository provides tools to quickly deploy a complete infrastructure with Docker Compose to run the MultiversX API. The setup is designed with minimal configuration requirements to enable rapid deployment on any server.

### **This deployment includes:**
- **An Observing Squad**: Access blockchain data by running observer nodes.
- **ElasticSearch Indexer**: Convert raw blockchain data for efficient querying.
- **ElasticSearch Database**: Store the converted blockchain data.
- **MultiversX API**: Query blockchain data externally via a standard API.
- **Kibana**: Visualize data and logs from the blockchain.

---

## **Requirements**

To support the infrastructure's heavy load, we recommend deploying on a bare-metal server with the following minimum specifications:

- **16 CPU cores**
- **64 GB RAM**
- **1 TB SSD storage**
- **1 Gbps network bandwidth**

### **Security**
Before deployment:
- Secure your server with an **SSH key**.
- Ensure no sensitive data is on the server. Although the API is stateless, misuse of the infrastructure could disrupt services.

---

## **Installation**

### **Steps:**
1. Log in to your freshly created server as the **root** user.
2. Clone this repository:
   ```bash
   git clone ########TODO: ADD REPO URL HERE########
   cd mvx-api-deployer
   ```
3. Run the installation script:
   ```bash
   sudo ./1-install_machine.sh
   ```

### **What this script does:**
- Updates and upgrades your system.
- Installs Docker and Docker Compose.
- Creates a new user, `mvx-api`, for running services.
- Clones this repository into the `mvx-api` user's home directory.

---

## **Configuration**

Currently, the deployment is configured with default settings. As development progresses, more configuration options will be added, such as enabling a **full history node** or customizing ElasticSearch settings.

### **Folder Structure**
After running the deployment script, the following folder structure will be created:

```
mvx-api-deployer/
├── keys/                # PEM key storage
├── proxy/               # Proxy configuration and logs
├── node-0/              # Shard 0 configuration and logs
├── node-1/              # Shard 1 configuration and logs
├── node-2/              # Shard 2 configuration and logs
├── node-metachain/      # Metachain configuration and logs
└── docker-compose.yml   # Deployment orchestrator
```

---

## **Deployment**

1. Switch to the `mvx-api` user:
   ```bash
   sudo su - mvx-api
   ```

2. Navigate to the deployment folder:
   ```bash
   cd mvx-api-deployer
   ```

3. Run the deployment script:
   ```bash
   ./2-deploy.sh
   ```

### **What this script does:**
- Sets up the environment for observer nodes.
- Generates PEM keys for the Observing Squad.
- Prepares folder structures and Docker volumes.
- Adjusts the `docker-compose.yml` file with the necessary settings.

4. Start the services:
   ```bash
   docker-compose up -d
   ```

### **Verifications**
- To check that all services are running:
  ```bash
  docker ps
  ```
- To view logs for troubleshooting:
  ```bash
  docker logs <container_name>
  ```

---

## **Future Features**

- **ElasticSearch Integration**:
  Index and store blockchain data for high-performance querying.
- **Kibana Setup**:
  Visualize blockchain metrics and logs.
- **Full History Node**:
  Enable full blockchain history to support detailed data analysis.
- **Customizable Configurations**:
  Provide flexibility for advanced users to tweak settings.


docker exec -it observer-shard-0 /bin/bash
docker container logs observer-shard-0 --follow