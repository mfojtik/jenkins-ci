#!/bin/bash -x
#
# This script will create a private keystore for Jenkins and add the Kubernetes
# CA certificate to it. This allows Jenkins to use the certificate when
# connecting to Kubernetes API.

CONFIG_PATH="/var/lib/jenkins/config.xml"
KUBE_CA="/run/secrets/kubernetes.io/serviceaccount/ca.crt"
STORE_PATH="/var/lib/jenkins/keystore"

if [ -f "${KUBE_CA}" ]; then
  echo "Creating Java keystore and adding ${KUBE_CA} to it ..."
  keytool -genkeypair -dname "cn=Kubernetes, ou=OpenShift, o=RedHat, c=US" \
      -alias secrets -keypass changeme -keystore ${STORE_PATH} \
      -storepass changeme
  keytool -import -trustcacerts -file "${KUBE_CA}" -alias k8s \
    -keystore ${STORE_PATH} --storepass changeme -noprompt

  export JAVA_OPTS="-Djavax.net.ssl.keyStore=${STORE_PATH} -D-Djavax.net.ssl.keyStorePassword=changeme"
fi

set -e

echo "Processing Jenkins Kubernetes configuration (${CONFIG_PATH}) ..."
export JENKINS_SLAVE_LABEL JENKINS_SLAVE_IMAGE JENKINS_SLAVE_COMMAND JENKINS_PASSWORD \
  JENKINS_SLAVE_LABEL KUBERNETES_SERVICE_HOST KUBERNETES_SERVICE_PORT
# TODO: Add /run/secrets as a credential here automatically.
# TODO: Add /run/secrets/../ca.crt as service certificate
envsubst < "${CONFIG_PATH}.tpl" > "${CONFIG_PATH}" && rm -f "${CONFIG_PATH}.tpl"

export JENKINS_HOME=/var/lib/jenkins
exec /usr/local/bin/run-jenkins "$@"
