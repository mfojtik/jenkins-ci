# OpenShift Jenkins CI

This repository contains an example of Jenkins setup, that is configured to
provide a CI/pipeline workflow for the
[sample-app](https://github.com/mfojtik/sample-app) repository.

## Create the CI project and the templates:

To start, you have to manually enter following commands in OpenShift:

```console
# Clone this repository
$ git clone https://github.com/mfojtik/jenkins-ci
$ cd jenkins-ci

# Create project and allow Jenkins to talk to OpenShift API
$ oc new-project ci
$ oc policy add-role-to-user edit system:serviceaccount:ci:default

# Now create the templates
$ oc create -f openshift
```

## Instantiating templates from OpenShift web console

Navigate to the OpenShift UI and choose the `ci` project we created in previous
step. Now click on *Add to Project* button and then click on *Show All
Template*. You should see *jenkins-master* template and *s2i-to-jenkins-slave*.

### S2I to Jenkins Slave

This template defines a
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
the build was started.

When the build complete, navigate to *Browse/Image Streams* and note the *Pull
spec* of the slave image you've built. For example: 

`172.30.238.218:5000/ci/ruby-20-centos7-jenkins-slave`

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
* **JENKINS_SLAVE_IMAGE** - Specify the full pull spec of the image you want to use as a Jenkins Slave (the pull spec you wrote down above)
* **JENKINS_SLAVE_COMMAND** - Specify the command you want to execute as an entrypoint on slave. There are two options:
  * */opt/app-root/jenkins/run-jnlp-client* - Use JNLP registration
  * */opt/app-root/jenkins/run-swarm-client* - Use the [Jenkins Swarm Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin)
* **JENKINS_SLAVE_ROOT** - The root directory that Jenkins will use for a workspace on the slave (must be world-writable).
* **JENKINS_SLAVE_LABEL** - The Jenkins label to use for this slave. Your job will have to specify this label.

Once you instantiate this template, you should see a new service *jenkins* in
the overview page and a route *https://jenkins-ci.router.default.svc.cluster.local/*.

You have to wait till OpenShift rebuilds the original image to include all
plugins and configuration needed.

### Sample Application

The last step is to instantiate the `sample-app` template. The [sample
app](https://github.com/mfojtik/sample-app) here is a simple Ruby application
that runs Sinatra and have one unit test defined to exercise the CI flow.

## Kubernetes plugin configuration

In order to allow Jenkins communicate with the OpenShift API, you have to
provide authentication token to the Kubernetes plugin. To do that, login to
Jenkins as administrator and navigate to *Manage Jenkins/Configure System*.

Now scroll at the very bottom of the configuration page, to the
*Cloud/Kubernetes* section. You will see that all fields are populated by the
parameter values you specified before.

To provide the *Credentials*, you have to first open an console and type this
command:

```console
$ oc whoami -t
P-tsUyn5Aawzt9rhUCkl0XRgf2rI-EOGKiEs6hejud8
```

Now go back to browser and click on *Add* button next to *Credentials* field.
Select *OAuth Bearer token* option and copy&paste the token from above to
*Token* field.  Now select the token from the drop-down menu and click the *Test
Connection* button. You should see *Connection successful* message.

## Workflow

You can see [watch the youtube](https://www.youtube.com/watch?v=HsdmSaz1zhs)
video that shows the full workflow. What happens in the video is:

1. When the `sample-app-test` job is started it fetches the [sample-app](https://github.com/mfojtik/sample-app) sources,
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

3. When the Docker image is build successfully, you have to **manually promote**
   the build to be deployed to OpenShift. Since re-deploying the application
   replaces the existing running application, human intervention is needed
   confirm this step.

4. Once the build is promoted, the `sample-app-deploy` job is started. This job
   will scale down the existing application deployment and redeploy it using the
   new Docker image.
