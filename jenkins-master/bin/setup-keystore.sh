#!/bin/bash
#
# This script will create a private keystore for Jenkins and add the Kubernetes
# CA certificate to it. This allows Jenkins to use the certificate when
# connecting to Kubernetes API.

KUBE_CA="/run/secrets/kubernetes.io/serviceaccount/ca.crt"
STORE_PATH="/var/lib/jenkins/keystore"

if [ -f "${KUBE_CA}" ]; then
  echo "Adding ${KUBE_CA} to the Jenkins keystore ..."
  keytool -genkeypair -dname "cn=Kubernetes, ou=OpenShift, o=RedHat, c=US" \
      -alias secrets -keypass changeme -keystore ${STORE_PATH} \
      -storepass changeme

  keytool -import -trustcacerts -file "${KUBE_CA}" -alias k8s \
    -keystore ${STORE_PATH} --storepass changeme -noprompt

  export JAVA_OPTS="-Djavax.net.ssl.trustStore=${STORE_PATH} -Djavax.net.ssl.trustStorePassword=changeme"
fi

exec /usr/local/bin/run-jenkins
