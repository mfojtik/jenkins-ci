<?xml version='1.0' encoding='UTF-8'?>
<hudson>
  <disabledAdministrativeMonitors/>
  <version>1.609</version>
  <numExecutors>1</numExecutors>
  <mode>EXCLUSIVE</mode>
  <useSecurity>true</useSecurity>
  <authorizationStrategy class="hudson.security.GlobalMatrixAuthorizationStrategy">
    <permission>hudson.model.Computer.Configure:admin</permission>
    <permission>hudson.model.Computer.Configure:system_builder</permission>
    <permission>hudson.model.Computer.Delete:admin</permission>
    <permission>hudson.model.Hudson.Administer:admin</permission>
    <permission>hudson.model.Hudson.Administer:system_builder</permission>
    <permission>hudson.model.Hudson.Read:admin</permission>
    <permission>hudson.model.Hudson.Read:system_builder</permission>
    <permission>hudson.model.Item.Build:admin</permission>
    <permission>hudson.model.Item.Configure:admin</permission>
    <permission>hudson.model.Item.Create:admin</permission>
    <permission>hudson.model.Item.Delete:admin</permission>
    <permission>hudson.model.Item.Read:admin</permission>
    <permission>hudson.model.Item.Workspace:admin</permission>
    <permission>hudson.model.Run.Delete:admin</permission>
    <permission>hudson.model.Run.Update:admin</permission>
    <permission>hudson.model.View.Configure:admin</permission>
    <permission>hudson.model.View.Create:admin</permission>
    <permission>hudson.model.View.Delete:admin</permission>
    <permission>hudson.scm.SCM.Tag:admin</permission>
  </authorizationStrategy>
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
    <disableSignup>true</disableSignup>
    <enableCaptcha>false</enableCaptcha>
  </securityRealm>
  <disableRememberMe>false</disableRememberMe>
  <projectNamingStrategy class="jenkins.model.ProjectNamingStrategy$DefaultProjectNamingStrategy"/>
  <workspaceDir>${ITEM_ROOTDIR}/workspace</workspaceDir>
  <buildsDir>${ITEM_ROOTDIR}/builds</buildsDir>
  <markupFormatter class="hudson.markup.RawHtmlMarkupFormatter" plugin="antisamy-markup-formatter@1.1">
    <disableSyntaxHighlighting>false</disableSyntaxHighlighting>
  </markupFormatter>
  <jdks/>
  <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
  <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar"/>
  <clouds>
    <org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud plugin="kubernetes@0.4-SNAPSHOT">
      <name>openshift</name>
      <templates>
        <org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
          <name>${JENKINS_SLAVE_LABEL}</name>
          <image>${JENKINS_SLAVE_IMAGE}</image>
          <privileged>false</privileged>
          <command>${JENKINS_SLAVE_COMMAND}</command>
          <remoteFs>${JENKINS_SLAVE_ROOT}</remoteFs>
          <instanceCap>1</instanceCap>
          <label>${JENKINS_SLAVE_LABEL}</label>
        </org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
      </templates>
      <serverUrl>https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}</serverUrl>
      <skipTlsVerify>true</skipTlsVerify>
      <namespace>ci</namespace>
      <jenkinsUrl>http://jenkins:8080</jenkinsUrl>
      <credentialsId></credentialsId>
      <containerCap>10</containerCap>
    </org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud>
  </clouds>
  <quietPeriod>1</quietPeriod>
  <scmCheckoutRetryCount>0</scmCheckoutRetryCount>
  <views>
    <hudson.model.AllView>
      <owner class="hudson" reference="../../.."/>
      <name>All</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
    </hudson.model.AllView>
    <se.diabol.jenkins.pipeline.DeliveryPipelineView plugin="delivery-pipeline-plugin@0.8.11">
      <owner class="hudson" reference="../../.."/>
      <name>Sample Pipeline View</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
      <componentSpecs>
        <se.diabol.jenkins.pipeline.DeliveryPipelineView_-ComponentSpec>
          <name>Test</name>
          <firstJob>sample-app-test</firstJob>
        </se.diabol.jenkins.pipeline.DeliveryPipelineView_-ComponentSpec>
        <se.diabol.jenkins.pipeline.DeliveryPipelineView_-ComponentSpec>
          <name>Build</name>
          <firstJob>sample-app-build</firstJob>
        </se.diabol.jenkins.pipeline.DeliveryPipelineView_-ComponentSpec>
        <se.diabol.jenkins.pipeline.DeliveryPipelineView_-ComponentSpec>
          <name>Deploy</name>
          <firstJob>sample-app-deploy</firstJob>
        </se.diabol.jenkins.pipeline.DeliveryPipelineView_-ComponentSpec>
      </componentSpecs>
      <noOfPipelines>3</noOfPipelines>
      <showAggregatedPipeline>false</showAggregatedPipeline>
      <noOfColumns>1</noOfColumns>
      <sorting>none</sorting>
      <showAvatars>false</showAvatars>
      <updateInterval>2</updateInterval>
      <showChanges>false</showChanges>
      <allowManualTriggers>false</allowManualTriggers>
      <regexpFirstJobs/>
    </se.diabol.jenkins.pipeline.DeliveryPipelineView>
    <au.com.centrumsystems.hudson.plugin.buildpipeline.BuildPipelineView plugin="build-pipeline-plugin@1.4.7">
      <owner class="hudson" reference="../../.."/>
      <name>Sample Build Pipeline</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
      <gridBuilder class="au.com.centrumsystems.hudson.plugin.buildpipeline.DownstreamProjectGridBuilder">
        <firstJob>sample-app-test</firstJob>
        <firstJobLink>job/sample-app-test/</firstJobLink>
      </gridBuilder>
      <noOfDisplayedBuilds>1</noOfDisplayedBuilds>
      <buildViewTitle></buildViewTitle>
      <consoleOutputLinkStyle>Lightbox</consoleOutputLinkStyle>
      <cssUrl></cssUrl>
      <triggerOnlyLatestJob>false</triggerOnlyLatestJob>
      <alwaysAllowManualTrigger>false</alwaysAllowManualTrigger>
      <showPipelineParameters>false</showPipelineParameters>
      <showPipelineParametersInHeaders>false</showPipelineParametersInHeaders>
      <startsWithParameters>false</startsWithParameters>
      <refreshFrequency>3</refreshFrequency>
      <showPipelineDefinitionHeader>false</showPipelineDefinitionHeader>
    </au.com.centrumsystems.hudson.plugin.buildpipeline.BuildPipelineView>
  </views>
  <primaryView>All</primaryView>
  <slaveAgentPort>49187</slaveAgentPort>
  <label>master</label>
  <nodeProperties/>
  <globalNodeProperties/>
  <noUsageStatistics>true</noUsageStatistics>
</hudson>
