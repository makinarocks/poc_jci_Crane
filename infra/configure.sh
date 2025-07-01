#!/bin/bash

PROJECT_CODE=$(read -p "PROJECT_CODE (project code) [prework]: " VALUE; echo "${VALUE:-prework}")
USER_NAME=$(read -p "USER_NAME (user name) [daeung.kim]: " VALUE; echo "${VALUE:-daeung.kim}")
RUNNER_RESOURCE_NAME=$(read -p "RUNNER_RESOURCE_NAME (Username with lower case alphabet) [dukim]: " VALUE; echo "${VALUE:-jci-dukim}")
POD_NODE_NAME=$(read -p "POD_NODE_NAME [k8s-worker-dgx01]: " VALUE; echo "${VALUE:-k8s-worker-dgx01}")
POD_LIMITS_MEMORY=$(read -p "POD_LIMITS_MEMORY (assign by Gi unit) [64]: " VALUE; echo "${VALUE:-64}")
POD_REQUESTS_CPU=$(read -p "POD_REQUESTS_CPU [16]: " VALUE; echo "${VALUE:-16}")
POD_REQUESTS_MEMORY=$(read -p "POD_REQUESTS_MEMORY (assign Gi unit) [64]: " VALUE; echo "${VALUE:-64}")
POD_REQUESTS_GPU=$(read -p "POD_REQUESTS_GPU [1]: " VALUE; echo "${VALUE:-1}")
PVC_STORAGE_SIZE=$(read -p "PVC_STORAGE_SIZE (assign Gi unit) [300]: " VALUE; echo "${VALUE:-300}")

echo "
----------[ Variables ]----------
Project Code => $PROJECT_CODE
User Name => $USER_NAME
Runner Resource Name => $RUNNER_RESOURCE_NAME
POD Image Tag => $POD_IMAGE_TAG
POD Container Branch Name => $BRANCH_NAME
POD Container Node Name => $POD_NODE_NAME
POD Limits Memory Capacity => $POD_LIMITS_MEMORY
POD Requests CPU Number => $POD_REQUESTS_CPU
POD Requests Memory Capacity => $POD_REQUESTS_MEMORY
POD Requests GPU Number => $POD_REQUESTS_GPU
PVC Storage Size => $PVC_STORAGE_SIZE
---------------------------------
"

read -p "Are these values correct? [Enter to proceed, C-c to cancel] "

typeset -p \
	PROJECT_CODE \
	USER_NAME \
	RUNNER_RESOURCE_NAME \
	POD_NODE_NAME \
	POD_LIMITS_MEMORY \
	POD_REQUESTS_CPU \
	POD_REQUESTS_MEMORY \
	POD_REQUESTS_GPU \
	PVC_STORAGE_SIZE \
	> ~/.kube/exp_vars.sh
