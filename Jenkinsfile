pipeline {
  agent any
  triggers { pollSCM('* * * * *') }

  stages {
    stage('Checkout') {
      steps {
        sh 'git submodule update --checkout -f --recursive'
      }
    }

    stage('prepare') {
      steps {
        dir ('/out') {
          sh 'rm -rf snapshot && mkdir -p snapshot'
        }
	sh 'gradle clean'
        dir('sounds') {
          sh 'rm -f *.wav'
//          sh 'rm -f ../../luwrain/src/main/resources/org/luwrain/core/sound/* && cp *.wav ../../luwrain/src/main/resources/org/luwrain/core/sound/'
        }
      }
    }

    stage('Build') {
      steps {
        dir ('sounds') {
          sh './make'
        }
        sh 'gradle build'
      }
    }

    stage('dist') {
      steps {
        sh 'gradle copyJars'
        sh 'gradle copyDeps'
      }
    }
  }
}
