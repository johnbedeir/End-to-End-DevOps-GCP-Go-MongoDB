# End-to-End-DevOps-GCP-Go-MongoDB

<img src=imgs/cover.png>

This repository contains scripts and Kubernetes manifests for deploying the Go Survey application on a GCP GKE cluster with an accompanying Container Registry and Persistent Disks. The deployment includes setting up a LoadBalancer, monitoring with Prometheus and Grafana, and a continuous deployment pipeline.

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) configured with appropriate permissions
- [Docker](https://docs.docker.com/engine/install/) installed and configured
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed and configured to interact with your Kubernetes cluster
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed
- [Helm](https://helm.sh/docs/intro/install/) installed
- [GitHub_CLI](https://github.com/cli/cli) installed
- [K9s](https://k9scli.io/topics/install/) installed
- [Studio_3T](https://studio3t.com/download/) OR [MongoDB_Compass](https://www.mongodb.com/try/download/atlascli)

## Before you run the script

### Update Script Variables:

The `build.sh` script contains a set of variables that you need to customize according to your GCP environment and deployment requirements. Here's how you can update them:

1. Open the `build.sh` script in a text editor of your choice.

2. Update the variables at the top of the script with your specific configurations:

   ```bash
   cluster_name="YOUR_GKE_CLUSTER_NAME"
   region="YOUR_GCP_REGION"
   project_id="YOUR_GCP_PROJECT_ID"
   ```

3. Save the changes to the `build.sh` script.

### Important Notes:

- `cluster_name`: This is the name of your Google Kubernetes Engine (GKE) cluster.
- `region`: This is the GCP region where your resources are located.
- `project_id`: This is your Google Cloud project ID.

### Build and Push Docker Image:

1. Ensure you are authenticated with Google Cloud:

   ```bash
   gcloud auth login
   gcloud config set project $project_id
   ```

2. Build the Docker image:

   ```bash
   docker build -t gcr.io/$project_id/$repo_name:latest .
   ```

3. Push the Docker image to Google Container Registry:

   ```bash
   docker push gcr.io/$project_id/$repo_name:latest
   ```

## Deploying the Application

### Infrastructure Setup

1. Run the following

   ```bash
   chmod +x build.sh
   ```

   ```
   ./build.sh
   ```

   This will set up the necessary GCP resources including the GKE cluster and Persistent Disks, deploying monitoring and the application, retrieve the External URL for each app.

### Accessing the Application

The application will be exposed via a LoadBalancer service. You can get the external IP address using:

```bash
kubectl get svc -n $namespace
```

Access your application at `http://<EXTERNAL_IP>`.

### Testing the Application

Use Postman to test the API endpoints:

1. Open Postman.
2. Set up a new POST request using your application's external IP.
3. In the request body, select `raw` and enter the following JSON:

   ```json
   {
   	"Answer1": "New1",
   	"Answer2": "New2",
   	"Answer3": "New3"
   }
   ```

4. Click `Send` to submit the request to your application.

<img src=imgs/postman.png>

After sending the data, you should be able to verify that the new entries have been added to the database by using Studio 3T or MongoDB Compass to inspect the relevant collection within your MongoDB database.

## Destroying the Infrastructure

In case you need to tear down the infrastructure and services that you have deployed, a script named `destroy.sh` is provided in the repository. This script will:

- Log in to Google Container Registry.
- Delete the specified Docker image from the Container Registry.
- Delete the Kubernetes deployment and associated resources.
- Delete the Kubernetes namespace.
- Destroy the GCP resources created by Terraform.

### Before you run

1. Open the `destroy.sh` script.
2. Ensure that the variables at the top of the script match your GCP and Kubernetes settings:

   ```bash
   project_id="YOUR_GCP_PROJECT_ID"
   repo_name="YOUR_REPO_NAME"
   ```

### How to Run the Destroy Script

1. Save the script and make it executable:

   ```bash
   chmod +x destroy.sh
   ```

2. Run the script:

   ```bash
   ./destroy.sh
   ```

This script will execute several `gcloud` and `terraform` commands to remove all resources related to your deployment. It is essential to verify that the script has completed successfully to ensure that all resources have been cleaned up and no unexpected costs are incurred.
