# OpenShift Jenkins CI example

## Step 1: Create the CI project and templates:

* `git clone https://github.com/mfojtik/jenkins-ci`
* `oc new-project ci`
* `oc create -f jenkins-ci/jenkins-master/openshift/jenkins-master-ephemeral.json
* `oc create -f jenkins-ci/jenkins-slave/openshift/s2i-slave-template.json`

You also need to allow Jenkins to execute the `oc` commands against the
OpenShift server. For that run this command as admin:

```console
$ oc policy add-role-to-user edit system:serviceaccount:ci:default
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

## Step 3: Adding Jenkins slave

To add Jenkins slave, you have to navigate to the Jenkins management interface:

https://jenkins.ci.router.default.svc.cluster.local/computer/new

> NOTE: If you see 503 error, just manually fix the URL to be 'https://'. This
> is a known issue and will be fixed soon.

Now choose a *Dumb Slave* assign a name to the new node (eg. `ruby-22-builder`).
Next, you have to configure the new node:

* **Remote root directory:** */opt/app-root/src*
* **Launch method:** *Launch slave via execution of command on the Master*
* **Launch command:** */usr/local/bin/oc-connect-slave*
