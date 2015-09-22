#!/bin/bash -e
#
# This script will create a private keystore for Jenkins and add the Kubernetes
# CA certificate to it. This allows Jenkins to use the certificate when
# connecting to Kubernetes API.

CONFIG_PATH="/var/lib/jenkins/config.xml"
KUBE_CA="/run/secrets/kubernetes.io/serviceaccount/ca.crt"
STORE_PATH="/var/lib/jenkins/keystore"

echo "Processing Jenkins Kubernetes configuration (${CONFIG_PATH}) ..."
export JENKINS_SLAVE_LABEL JENKINS_SLAVE_IMAGE JENKINS_SLAVE_COMMAND JENKINS_PASSWORD \
  JENKINS_SLAVE_LABEL KUBERNETES_SERVICE_HOST KUBERNETES_SERVICE_PORT
export JENKINS_HOME=/var/lib/jenkins
export ITEM_ROOTDIR="\${ITEM_ROOTDIR}" # Preserve the variable Jenkins uses

# TODO: Add /run/secrets as a credential here automatically.
# TODO: Add /run/secrets/../ca.crt as service certificate
envsubst < "${CONFIG_PATH}.tpl" > "${CONFIG_PATH}" && rm -f "${CONFIG_PATH}.tpl"
exec /usr/local/bin/run-jenkins "$@"
