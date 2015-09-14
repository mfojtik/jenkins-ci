# OpenShift Jenkins CI example

This repository contains an example of Jenkins setup, that is configured to
provide a CI/pipeline workflow for the
[sample-app](https://github.com/mfojtik/sample-app) repository.

## Create the CI project and the templates:

To start, you have to manually enter following commands in OpenShift:

```console
$ git clone https://github.com/mfojtik/jenkins-ci
$ cd jenkins-ci

# Create project and allow Jenkins to talk to OpenShift API
$ oc new-project ci
$ oc policy add-role-to-user edit system:serviceaccount:ci:default

# Now create the templates
$ oc create -f openshift
```

## Instantiating templates from OpenShift web console

First, create the Jenkins master. Since we have to install couple extra plugins
to the Jenkins master, we have to rebuild the official OpenShift [Jenkins]()
image to include these plugins. The master also needs a script that will allow
connection to the Jenkins slaves (`oc-connect-slave`).

Navigate to the OpenShift UI and choose the `ci` project we created in previous
stem. Now click on *Add to Project* button and then click on *Show All
Template*. You should see *jenkins-master* template and *s2i-jenkins-slave*.

First click on the *jenkins-master* and create the template. You can change the
Jenkins administrator password (default is 'password').

Now wait for the Jenkins service to be running. You can check if the Jenkins is
running in OpenShift web console. It can take few minutes for the build to
complete.

Next click on the *s2i-jenkins-slave*. You can provide the name of the S2I image
stream you want to base the Jenkins slave image on, the Jenkins master URL
(*default: http://jenkins:8080/jenkins*) and the username and password to allow
the slave to connect to Jenkins.
After creating this template, we build a Jenkins slave image that will be
derivated from the S2I image and include all tools Jenkins needs to talk to the
Jenkins slave (java, slave.jar, etc...).

The last step is to instantiate the `sample-app` template. The [sample
app](https://github.com/mfojtik/sample-app) here is a simple Ruby application
that runs Sinatra and have one unit test defined to exercise the CI flow.

## Worflow

Once the Jenkins master is up and the slave is discovered via the [swarm](https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin) plugin, following will happen in Jenkins:

1. The `sample-app-test` job is started. This job will fetch the sources,
   install all required rubygems using bundler and then execute the unit tests.

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
