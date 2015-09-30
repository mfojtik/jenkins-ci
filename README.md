# OpenShift Jenkins CI

This repository contains an example of Jenkins setup, that is configured to
demonstrate the CI/pipeline workflow for the [sample-app](sample-app) application
using the Jenkins Master/Slave setup and automatization done on OpenShift v3.

<p align="center">
<img width="420" src="https://raw.githubusercontent.com/mfojtik/jenkins-ci/master/jenkins-flow.png"/>
</p>
## Create the CI project and the templates:

To start, you have to manually enter following commands in OpenShift:

```console
# Clone this repository
$ git clone https://github.com/mfojtik/jenkins-ci
$ cd jenkins-ci

# Create project and allow Jenkins to talk to OpenShift API
$ oc new-project ci
$ oc policy add-role-to-user edit system:serviceaccount:ci:default

# Create the 'staging' project where we deploy the sample-app for testing
$ oc new-project stage
$ oc policy add-role-to-user edit system:serviceaccount:stage:default
$ oc policy add-role-to-user edit system:serviceaccount:ci:default

# Now create the templates in the 'ci' and 'stage' projects
$ oc create -f openshift -n ci
$ oc create -f openshift/sample-app-stage.json
```

## Instantiating templates from OpenShift web console

Navigate to the OpenShift UI and choose the `ci` project we created in previous
step. Now click on *Add to Project* button and then click on *Show All
Template*. You should see *jenkins-master* template and *s2i-to-jenkins-slave*.

### Jenkins Slaves

#### Manual Setup

You can use any Docker image as a Jenkins Slave as long as it runs either JNLP
client or the swarm plugin client. For example, look at these two scripts:

* [run-jnlp-client](https://github.com/mfojtik/jenkins-ci/blob/master/jenkins-slave/contrib/openshift/run-jnlp-client)
* [run-swarm-client](https://github.com/mfojtik/jenkins-ci/blob/master/jenkins-slave/contrib/openshift/run-swarm-client)

Once you have this Docker Image, you have to manually configure Jenkins Master
to use these images as a slaves. Follow the steps in the
[jenkins-kubernetes-plugin](https://github.com/jenkinsci/kubernetes-plugin#running-in-kubernetes-google-container-engine)
documentation.

#### Tagging exiting ImageStream as Jenkins Slave

If you have your Jenkins Slave image imported in OpenShift and available as an
ImageStream, you can tell Jenkins Master to automatically add it as a Kubernetes
Plugin slave. To do that, you have to set following labels:

```json
{
  "kind": "ImageStream",
  "apiVersion": "v1",
  "metadata": {
    "name": "jenkins-slave-image",
    "labels": {
      "role": "jenkins-slave"
    },
    "annotations": {
      "slave-label": "my-slave",
      "slave-directory": "/opt/app-root/jenkins"
    }
  },
  "spec": {}
}
```

The `role=jenkins-slave` label is mandatory, but the annotations are optional.
If the `slave-label` annotations is not set, Jenkins use the ImageStream name as
label. If the `slave-directory` is not set, Jenkins will use default
*/opt/app-root/jenkins* directory.

Make sure that the Jenkins slave directory is world writeable.

#### Converting S2I image to Jenkins Slave

NOTE: This step needs to be execute before you instantiate the template with Jenkins
Master.

The `s2i-to-jenkins-slave` template defines a
[BuildConfig](https://docs.openshift.org/latest/dev_guide/builds.html#defining-a-buildconfig)
that uses the [Docker
Strategy](https://docs.openshift.org/latest/dev_guide/builds.html#docker-strategy-options)
to rebuild the S2I image (or any compatible image) to serve as a Jenkins Slave.
For that, we have to install JRE to run the `slave.jar`, setup nss_wrapper to
provide the username for the random UID the container will run as and a shell
script that we launch as an entrypoint from Jenkins.

When you choose `s2i-to-jenkins-slave` template, you have to specify the image
name you want to convert. The default value is `ruby-20-centos7`, but you can
change it to any available ImageStream you have in OpenShift.

Once you instantiate the template, go to *Browse/Builds* where you can see that
the build was started. You have to wait till the build finishes and the
ImageStream contains the Docker image for slaves.

The labels are annotations are automatically set for this ImageStream, so you
can ignore the section above.

### Jenkins Master

This template defines a
[BuildConfig](https://docs.openshift.org/latest/dev_guide/builds.html#defining-a-buildconfig)
that again, use the [Docker
Strategy](https://docs.openshift.org/latest/dev_guide/builds.html#docker-strategy-options)
to rebuild the official [OpenShift Jenkins Image](https://github.com/openshift/jenkins).
This template also defines a [Deployment Configuration](https://docs.openshift.org/latest/dev_guide/deployments.html#creating-a-deployment-configuration) that will start just one instance
of the Jenkins server.

When you choose the `jenkins-master` template, you have to specify these parameters:

* **JENKINS_SERVICE_NAME** - The name of the Jenkins service (default: *jenkins*)
* **JENKINS_IMAGE** - The name of the original Jenkins image to use
* **JENKINS_PASSWORD** - The Jenkins 'admin' user password

Once you instantiate this template, you should see a new service *jenkins* in
the overview page and a route *https://jenkins-ci.router.default.svc.cluster.local/*.

You have to wait till OpenShift rebuilds the original image to include all
plugins and configuration needed.

### Sample Application

The last step is to instantiate the `sample-app` template. The [sample
app](sample-app) here is a simple Ruby application
that runs Sinatra and have one unit test defined to exercise the CI flow.

You have to instantiate the template in both `ci` and `stage` projects.

## Workflow

You can see [watch the youtube](https://www.youtube.com/watch?v=HsdmSaz1zhs)
video that shows the full workflow. What happens in the video is:

1. When the `sample-app-test` job is started it fetches the [sample-app](sample-app) sources,
   install all required rubygems using bundler and then execute the sample unit tests.
   In the job definition, we restricted this job to run only on slaves that has
   *ruby-20-centos7* label. This will match the Kubernetes Pod Template you seen
   in the Kubernetes plugin configuration. Once this job is started and queued,
   the plugin connects to OpenShift and start the slave Pod using the converted
   S2I image. The job then run entirely on that slave.
   When this job finishes, the Pod is automatically destroyed by the Kubernetes
   plugin.

2. If the unit tests passed, the `sample-app-build` is started automatically via
   the Jenkins [promoted builds](https://wiki.jenkins-ci.org/display/JENKINS/Promoted+Builds+Plugin)
   plugin. This job will leverage the OpenShift Jenkins plugin that will start a
   build of the Docker image which will contain 'sample-app'.

3. Once the new Docker image for the `sample-app` is built, the
   `sample-app-stage` project will automatically deploy it into `stage` project
   and notify the QA team about availability for testing.

3. If the `sample-app` image pass the `stage` testing, you have to **manually
   promote** the `sample-app-build` build to be deployed to OpenShift. Since
   re-deploying the application replaces the existing running application, human
   intervention is needed confirm this step.

4. Once the build is promoted, the `sample-app-deploy` job is started. This job
   will scale down the existing application deployment and redeploy it using the
   new Docker image.
