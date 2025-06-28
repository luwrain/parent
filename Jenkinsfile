pipeline {
  agent any
  triggers { pollSCM('* * * * *') }

  stages {
    stage('Checkout') {
      steps {
        sh 'git submodule update --init -f --recursive'
        sh 'git submodule update --checkout -f --recursive'
      }
    }

    stage('prepare') {
      steps {
        dir ('/out') {
          sh 'rm -rf _tmp'
          sh 'mkdir -p _tmp/bundles'
        }
	sh 'gradle clean'
        dir('sounds') {
          sh 'rm -f *.wav *.xz'
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
        sh 'gradle distCommon'
        dir ("build/release/dist") {
          sh "cp *.zip /out/_tmp/bundles"
        }
      }
    }

    stage('deb') {
      steps {
        sh 'gradle distFilesDeb'
        dir ("build/release/dist") {
          sh "cp -r deb /build/luwrain"
        }
        sh "docker run --rm -v /build:/build dpkg-jammy -c \'cd /build/luwrain && dpkg-buildpackage --build=binary -us -uc\'"
      }
    }




    stage('maven') {
      steps {
        dir ('core') {
          sh 'gradle publish'
        }
        dir ('pim/pim') {
          sh 'gradle publish'
        }
      }
    }
  }
}
