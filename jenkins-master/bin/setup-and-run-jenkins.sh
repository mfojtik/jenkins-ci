#!/bin/bash -e
#
# This script will process the Jenkins configuration and automatically
# discover the Jenkins Slave Docker images from the OpenShift ImageStreams.
#
# In order to add ImageStream as a Jenkins Slave, the ImageStream must define
# this label:
#
# * `role=jenkins-slave`  - To mark this imageStream as Jenkins Slave compatible
#
# Optionally, the ImageStream can set following annotations:
#
# * `slave-directory`     - Directory where the slave will execute jobs
#                           (default: /opt/app-root/jenkins)
# * `slave-label`         - The Jenkins Slave label that will be used in Job definitions.
#                           (default: "<image stream name>")

set -x
source /usr/local/bin/vars.sh

oc_auth="--token=$(cat $AUTH_TOKEN) --certificate-authority=${KUBE_CA}"
alias oc="oc -n ${PROJECT_NAME} --server=$OPENSHIFT_API_URL ${oc_auth}"

for name in $(get_is_names); do
  echo "Adding ${name} imagestream as Jenkins Slave ..."
  K8S_PLUGIN_POD_TEMPLATES+=$(convert_is_to_slave ${name})
done

set +x

echo "Processing Jenkins Kubernetes configuration (${CONFIG_PATH}) ..."
envsubst < "${CONFIG_PATH}.tpl" > "${CONFIG_PATH}" && rm -f "${CONFIG_PATH}.tpl"
exec /usr/local/bin/run-jenkins "$@"
