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
          sh 'rm -f core/src/main/resources/org/luwrain/core/sound/*.wav'
        }
      }
    }

    stage('Build') {
      steps {
        dir ('sounds') {
          sh './make'
	  sh 'cp *.wav ../core/src/main/resources/org/luwrain/core/sound'
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
