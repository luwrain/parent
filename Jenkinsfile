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
          sh "mkdir -p _tmp/bundles"
	  sh "mkdir _tmp/apt"
        }
	sh 'gradle clean'
        dir('sounds') {
          sh 'rm -f *.wav *.xz'
	          }
          sh 'rm -f core/src/main/resources/org/luwrain/core/sound/*.wav'
        sh "rm -rf .gradle"
        sh "docker run --rm -v /build:/build dpkg-jammy bash -c \"rm -rf /build/*\""
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
        dir ("build/release/dist/deb/debian") {
          sh "sed -i -e \"s/SUBST_DATE/\$(LANG=C date \"+%a, %d %b %Y %H:%M:%S %z\")/\" changelog"
          sh "sed -i -e \"s/SUBST_VER/\$(LANG=C date \"+%Y%m%d%H%M\")/\" changelog"
        }

	// Jammy
        sh "mkdir -p /build/dpkg/jammy"
        dir ("build/release/dist") { sh "cp -r deb /build/dpkg/jammy/luwrain" }
        sh "docker run --rm -v /build:/build dpkg-jammy bash -c \"cd /build/dpkg/jammy/luwrain && dpkg-buildpackage --build=binary -us -uc\""
        sh "mkdir -p /out/_tmp/apt/dists/jammy/luwrain/binary-amd64"
        sh "cp /build/dpkg/jammy/*.deb /out/_tmp/apt/dists/jammy/luwrain/binary-amd64"

	// Noble
        sh "mkdir -p /build/dpkg/noble"
        dir ("build/release/dist") { sh "cp -r deb /build/dpkg/noble/luwrain" }
        sh "docker run --rm -v /build:/build dpkg-noble bash -c \"cd /build/dpkg/noble/luwrain && dpkg-buildpackage --build=binary -us -uc\""
        sh "mkdir -p /out/_tmp/apt/dists/noble/luwrain/binary-amd64"
        sh "cp /build/dpkg/noble/*.deb /out/_tmp/apt/dists/noble/luwrain/binary-amd64"


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
