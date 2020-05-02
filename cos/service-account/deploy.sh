#!/bin/bash
PROJECT="xueweiz-experimental"
SERVICE_NAME="service-account-issue"
MACHINE_TYPE="n1-standard-1"
SERVICE_ACCOUNT="service-account-problem@xueweiz-experimental.iam.gserviceaccount.com"
DISK_SIZE="200GB"


# Be sure the project is set right
echo "*** Setting project in gcloud ***"
gcloud config set project $PROJECT

# Build and push the container image
gcloud builds submit -t gcr.io/$PROJECT/$SERVICE_NAME:latest .
# echo "*** Building a fresh image ***"
# docker build -t $SERVICE_NAME .
# echo "*** Tagging the image ***"
# docker tag $SERVICE_NAME gcr.io/$PROJECT/$SERVICE_NAME:latest
# echo "*** Pushing the image to GCR ***"
# docker push gcr.io/$PROJECT/$SERVICE_NAME:latest

# Create instance-template
echo "*** Creating instance template ***"
gcloud compute instance-templates create-with-container $SERVICE_NAME \
--machine-type $MACHINE_TYPE \
--image-family projects/cos-cloud/global/images/cos-stable \
--boot-disk-size $DISK_SIZE \
--service-account $SERVICE_ACCOUNT \
--container-image gcr.io/$PROJECT/$SERVICE_NAME:latest

# Create Instance Group
echo "*** Creating instance group ***"
gcloud compute instance-groups managed create $SERVICE_NAME \
    --base-instance-name $SERVICE_NAME \
    --size 1 \
    --template $SERVICE_NAME \
    --zone us-central1-a

# Create deployment trigger
echo "*** Creating deployment trigger ***"
gcloud beta builds triggers create cloud-source-repositories \
--repo=$SERVICE_NAME \
--branch-pattern="^master$" \
--build-config=cloudbuild.yaml

curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/" -H "Metadata-Flavor: Google"
curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email" -H "Metadata-Flavor: Google"