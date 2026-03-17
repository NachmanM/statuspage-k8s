#!/bin/bash
kubectl create secret docker-registry regcred \
--docker-server=992382545251.dkr.ecr.us-east-1.amazonaws.com \
--docker-username=AWS \
--docker-password=$(aws ecr get-login-password --region us-east-1) \
--namespace=statuspage \
--dry-run=client -o yaml | kubectl apply -f -
