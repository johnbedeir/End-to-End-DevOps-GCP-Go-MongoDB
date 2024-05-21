#!/bin/bash

# Variables
cluster_name="cluster-1-testing-env" # If you wanna change the cluster name make sure you change it in the terraform directory variables.tf (name_prefix & environment)
zone="europe-west1-d"
project_id="johnydev"
repo_name="goapp-survey" # If you wanna change the repository name make sure you change it in the k8s/app.yml (Image name) 
image_name="gcr.io/${project_id}/$repo_name:latest"
app_namespace="go-survey" # you can keep this variable or if you will change it remember to change the namespace in k8 manifests inside k8s directory
monitoring_namespace="monitoring"
app_svc="go-app"
alertmanager_svc="kube-prometheus-stack-alertmanager"
prometheus_svc="kube-prometheus-stack-prometheus"
grafana_svc="kube-prometheus-stack-grafana"
# End of Variables

# Update helm repos
helm repo update

# Google cloud authentication
gcloud auth login

# Get GCP credentials
gcloud iam service-accounts keys create terraform/gcp-credentials.json --iam-account terraform-sa@${project_id}.iam.gserviceaccount.com

# Build the infrastructure
echo "--------------------Creating GKE--------------------"
echo "--------------------Creating GCR--------------------"
echo "--------------------Deploying Monitoring--------------------"
cd terraform && \ 
terraform init
terraform apply -auto-approve
cd ..

# Update kubeconfig
echo "--------------------Update Kubeconfig--------------------"
gcloud container clusters get-credentials ${cluster_name} --region ${zone} --project ${project_id}

# Remove preious docker images
echo "--------------------Remove Previous build--------------------"
docker rmi -f ${image_name} || true

# Build new docker image with new tag
echo "--------------------Build new Image--------------------"
docker build -t ${image_name} ./Go-app/

#GCR Authentication
echo "--------------------Authenticate Docker with GCR--------------------"
gcloud auth configure-docker

# push the latest build to GCR
echo "--------------------Pushing Docker Image--------------------"
docker push ${image_name}

# create app_namespace
echo "--------------------creating Namespace--------------------"
kubectl create ns ${app_namespace} || true

# deploy app
echo "--------------------Deploy App--------------------"
kubectl apply -n ${app_namespace} -f k8s

# Wait for application to be deployed
echo "--------------------Wait for all pods to be running--------------------"
sleep 90s

echo "App_URL:" $(kubectl get svc ${app_svc} -n ${app_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Alertmanager_URL:" $(kubectl get svc ${alertmanager_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Prometheus_URL:" $(kubectl get svc ${prometheus_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Grafana_URL: " $(kubectl get svc ${grafana_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')