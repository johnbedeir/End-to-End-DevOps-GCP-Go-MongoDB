#!/bin/bash
project_id="johnydev"
repo_name="goapp-survey"

#GCR Authentication
echo "--------------------Authenticate Docker with GCR--------------------"
gcloud auth configure-docker

echo "--------------------Enable google apis--------------------"
gcloud services enable cloudresourcemanager.googleapis.com --project ${project_id}

# delete Docker-img from GCR
echo "--------------------Deleting GCR-IMG--------------------"
gcloud container images delete gcr.io/${project_id}/${repo_name}:latest --quiet

# delete GCP resources
echo "--------------------Deleting GCP Resources--------------------"
cd terraform && \
terraform destroy -auto-approve
