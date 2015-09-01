# OpenShift Jenkins CI example

## Step 0: Prepare modified Jenkins image

* `cd jenkins-master`
* `docker build -t mfojtik/jenkins-master` .

## Step 1: Create the CI project and templates:

* `oc new-project ci`
* `oc create -f origin/examples/jenkins/jenkins-ephemeral-template.json`
* `oc create -f jenkins-ci/jenkins-slave/openshift/s2i-slave-template.json`

## Step 2: Configure the templates

Navigate to the OpenShift UI and choose the *ci* project. Now click on *Add to
Project* and then click on *Show All Templates*.  You should see
*jenkins-ephemeral* and *s2i-jenkins-slave* template there.

First, click on the *jenkins-ephemeral* and change the `JENKINS_IMAGE` to
*mfojtik/jenkins-master*. Now click *Create*. You will be then taken to
the dashboard and you can watch the Jenkins to be deployed.

Second, click on the *s2i-jenkins-slave* template. It is important to enter the
S2I image you want to base the Jenkins slave on. By default, the value of the
*IMAGE_NAME* parameter is set to `ruby-22-centos7`. You can change it to
`python-33-centos7` or whatever S2I image you have image stream created for.

After you instantiate this template, you will see no pods running under the
*jenkins-slave* service. It means the Jenkins slave Docker image is currently
being built. It will take couple minutes for build to finish. After the build
finishes, you should see *ruby-22-centos7-jenkins-slave-1* replication
controller and one pod running.

## Step 3: Add Jenkins slave to Jenkins master

Navigate to the Jenkins management console and click *Manage nodes/Add node*.
Choose a 'dumb node' and give it name ('ruby-slave'). Now in the configuration
screen for the node, set *Remote directory* to `/opt/app-root/src` and the
*Launch method* to `Launch slave via execution of command on the Master`.
Now set the the *Launch command* to `/usr/local/bin/oc-connect-slave`.
