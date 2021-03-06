#!/bin/bash

# Source functions.sh
source /azs/cli/shared/functions.sh \
  && echo "Sourced functions.sh" \
  || { echo "Failed to source functions.sh" ; exit 1 ; }

azs_job_start
################################# Task: Probe #################################
azs_task_start probe

openssl s_client \
      -connect adminmanagement.$(cat /run/secrets/cli | jq -r '.fqdn'):443 \
      -servername adminmanagement.$(cat /run/secrets/cli | jq -r '.fqdn') \
  && azs_log_field T status admin_arm_openssl_connect \
  || azs_log_field T status admin_arm_openssl_connect fail

azs_task_end probe
################################## Task: Auth #################################
azs_task_start auth

# Login to Azure Stack cloud 
# Provide argument "adminmanagement" for authenticating to admin endpoint
# Provide argument "management" for authenticating to tenant endpoint
azs_login adminmanagement

azs_task_end auth
################################## Task: Read #################################
azs_task_start read

RESOURCES=$(az resource list) \
  && azs_log_field T status admin_arm_list_resources \
  || azs_log_field T status admin_arm_list_resources fail

azs_task_end read
############################### Job: Complete #################################
azs_job_end