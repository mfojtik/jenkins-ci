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
source /usr/local/bin/vars.sh

for name in $(get_is_names); do
  echo "Adding ${name} imagestream as Jenkins Slave ..."
  K8S_PLUGIN_POD_TEMPLATES+=$(convert_is_to_slave ${name})
done

echo "Processing Jenkins Kubernetes configuration (${CONFIG_PATH}) ..."
envsubst < "${CONFIG_PATH}.tpl" > "${CONFIG_PATH}" && rm -f "${CONFIG_PATH}.tpl"

# Don't show these in the Jenkins UI
unset oc_auth oc_cmd K8S_PLUGIN_POD_TEMPLATES

exec /usr/local/bin/run-jenkins "$@"
