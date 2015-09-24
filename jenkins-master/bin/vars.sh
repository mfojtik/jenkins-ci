#!/bin/sh

export DEFAULT_SLAVE_DIRECTORY=/opt/app-root/jenkins
export JENKINS_HOME=/var/lib/jenkins
export CONFIG_PATH=${JENKINS_HOME}/config.xml
export PROJECT_NAME=${PROJECT_NAME:-ci}
export OPENSHIFT_API_URL=https://openshift.default.svc.cluster.local
export KUBE_CA=/run/secrets/kubernetes.io/serviceaccount/ca.crt
export AUTH_TOKEN=/run/secrets/kubernetes.io/serviceaccount/token
export JENKINS_PASSWORD KUBERNETES_SERVICE_HOST KUBERNETES_SERVICE_PORT
export ITEM_ROOTDIR="\${ITEM_ROOTDIR}" # Preserve this variable Jenkins has in config.xml
export K8S_PLUGIN_POD_TEMPLATES=""

oc_auth="--token=$AUTH_TOKEN --certificate-authority=${KUBE_CA}"
alias oc="oc -n ${PROJECT_NAME} --server=$OPENSHIFT_API_URL ${oc_auth}"

# get_imagestream_names returns a list of imagestreams names that contains
# label 'role=jenkins-slave'
function get_is_names() {
  oc get is -l role=jenkins-slave -o template -t "{{range .items}}{{.metadata.name}} {{end}}"
}

# convert_is_to_slave converts the OpenShift imagestream to a Jenkins Kubernetes
# Plugin slave configuration.
function convert_is_to_slave() {
  local name=$1
  local template_file=$(mktemp)
  local template="
  <org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
    <name>{{.metadata.name}}</name>
    <image>{{.status.dockerImageRepository}}</image>
    <privileged>false</privileged>
    <remoteFs>
      {{if index .metadata.annotations \\\"slave-directory\\\"}}
        {{index .metadata.annotations \\\"slave-directory\\\"}}
      {{else}}
        ${DEFAULT_SLAVE_DIRECTORY}
      {{end}}
    </remoteFs>
    <instanceCap>1</instanceCap>
    <label>
      {{if index .metadata.annotations \\\"slave-label\\\"}}
        {{index .metadata.annotations \\\"slave-label\\\"}}
      {{else}}
        ${name}
      {{end}}
    </label>
  </org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
  "
  echo "${template}" > ${template_file}
  oc get is/${name} -o templatefile --template=${templatefile}
  rm -f ${template_file} &>/dev/null
}
