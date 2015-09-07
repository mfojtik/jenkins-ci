# OpenShift Jenkins CI example

This repository contains an example of Jenkins setup, that is configured to
provide a CI/pipeline workflow for the
[sample-app](https://github.com/mfojtik/sample-app) repository.

## Step 1: Create the CI project and templates:

To start, you have to manually enter following commands in OpenShift:

```console
$ git clone https://github.com/mfojtik/jenkins-ci
$ oc new-project ci
$ oc policy add-role-to-user edit system:serviceaccount:ci:default
$ oc create -f jenkins-ci/jenkins-master/openshift/jenkins-master-ephemeral.json
$ oc create -f jenkins-ci/jenkins-slave/openshift/s2i-slave-template.json
$ oc create -f jenkins-ci/sample-app/sample-app-template.json
```

## Step 2: Instantiating templates

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
stream you want to base the Jenkins slave image on. After creating this
template, we build a Jenkins slave image that will be derivated from the S2I
image and include all tools Jenkins needs to talk to the Jenkins slave (java,
slave.jar, etc...)

The last step is to instantiate the `sample-app` template. This template
defines resources to run the [sample-app](https://github.com/mfojtik/sample-app)
Ruby application. After you instantiate the template, you will have no pods
running, which is expected. You have to first execute the build in Jenkins and
then promote the build for it being deployed.

## Step 3: Final Workflow

This example setups following workflow:

1. Kick the build of the `sample-app-test` job. This job is kicked automatically
   everytime there is a new commit in [sample-app](https://github.com/mfojtik/sample-app) repo.
   This job then clone the repository, install all Ruby development dependencies
   and perform `rake test` to verify the change.
2. After the change is verified, the `sample-app-build` job is triggered
   automatically. This job will start a build of a new Docker image for the
   `sample-app` in OpenShift. You can watch the build in the OpenShift web
   console, or you can watch the build logs in the Jenkins console.
3. After the new Docker image is build with changes, you have to **manually**
   promote the Docker image to be deployed in OpenShift. To do that, navigate to
   the `sample-app-build` job and click on `Promotion Status`. Then click on
   `Approve`, which will kick the `sample-app-deploy` job. This job will call
   `oc deploy` command that will cause the `sample-app` to be redeployed.
