#!/bin/bash
SCRIPT_VERSION=0.5

# Source functions.sh
source /azs/common/functions.sh \
  && echo "Sourced functions.sh" \
  || { echo "Failed to source functions.sh" ; exit ; }

################################## Task: Auth #################################
azs_task_start auth

# Login to Azure Stack cloud 
# Provide argument "adminmanagement" for authenticating to admin endpoint
# Provide argument "management" for authenticating to tenant endpoint
azs_login adminmanagement

azs_task_end auth
################################## Task: Read #################################
azs_task_start read

# Get update location
BRIDGE_ACTIVATION_ID=$(az resource list \
      --resource-type "Microsoft.AzureBridge.Admin/activations" \
      | jq -r ".[0].id") \
  && azs_log_field T status srv_azure_bridge_activation_id \
  || azs_log_field T status srv_azure_bridge_activation_id fail

# Get update location status
BRIDGE_REGISTRATION_ID=$(az resource show \
      --ids $BRIDGE_ACTIVATION_ID \
      | jq -r ".properties.azureRegistrationResourceIdentifier") \
  && azs_log_field T status srv_azure_bridge_registration_id \
  || azs_log_field T status srv_azure_bridge_registration_id fail

# Remove leading "/"
BRIDGE_SUBSCRIPTION_ID=${BRIDGE_REGISTRATION_ID#*/} \
  && azs_log_field T status srv_azure_bridge_substring_01 \
  || azs_log_field T status srv_azure_bridge_substring_01 fail

# Remove "sbscriptions/"
BRIDGE_SUBSCRIPTION_ID=${BRIDGE_SUBSCRIPTION_ID#*/} \
  && azs_log_field T status srv_azure_bridge_substring_02 \
  || azs_log_field T status srv_azure_bridge_substring_02 fail

# Remove traling path from subscription id
BRIDGE_SUBSCRIPTION_ID=${BRIDGE_SUBSCRIPTION_ID%%/*} \
  && azs_log_field T status srv_azure_bridge_substring_03 \
  || azs_log_field T status srv_azure_bridge_substring_03 fail

echo $BRIDGE_SUBSCRIPTION_ID > /azs/bridge/subscriptionid \
  && azs_log_field T status srv_azure_bridge_to_file \
  || azs_log_field T status srv_azure_bridge_to_file fail

azs_task_end read
############################### Job: Complete #################################
azs_job_end