#!/bin/bash
while :
do
    date
    curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/" -H "Metadata-Flavor: Google"
    curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email" -H "Metadata-Flavor: Google"
    /root/google-cloud-sdk/bin/gsutil ls 
    echo "sleeping 30 seconds"
    sleep 30
done
