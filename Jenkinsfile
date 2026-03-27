      //def winJdk = 'https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_windows-x64_bin.zip';
      def winJdk = 'https://download.java.net/openjdk/jdk21/ri/openjdk-21+35_windows-x64_bin.zip';
      def RELEASE_DIR = '/out/_tmp'
      def CACHE_DIR = '/cache'
      def JAVAFX_VER = 21



pipeline {
  agent any
  triggers { pollSCM('* * * * *') }

  stages {
    stage('Checkout') {
      steps {
        sh 'git submodule update --init -f'
        sh 'git submodule update --checkout -f'
      }
    }

    stage('prepare') {
      steps {
        sh 'rm -rf /build/*'
        dir('sounds') {
          sh 'rm -f *.wav *.xz'
        }
        sh 'rm -f core/src/main/resources/org/luwrain/core/sound/*.wav'
        dir ('/out') {
          sh "mkdir -p release"
          sh 'rm -rf _tmp && mkdir _tmp'
          sh "[ -d release/maven2 ] && cp -r release/maven2 _tmp"
          sh 'for i in bundles apt; do mkdir _tmp/$i; done'
        }
        sh 'gradle clean'
      }
    }

    stage('Build-sounds') {
      steps {
        dir ('sounds') {
          sh './make'
        }
      }
    }

    stage('Build-main') {
      steps {
        sh 'gradle build'
      }
    }

    stage('dist-zip') {
      steps {
        sh 'gradle distCommon'
        dir ("build/release/dist") {
          sh "cp *.zip /out/_tmp/bundles"
        }
      }
    }

    stage('win-jdk') {
      steps {
        dir ("$CACHE_DIR") {
          sh "if ! [ -d jdk ]; then wget -q $winJdk; unzip *.zip; rm -f *.zip; mv jdk-* jdk; fi"
          sh "if ! [ -d jre ]; then docker run --rm -v /cache:/work ich777/winehq-baseimage bash -c \"cd /work/jdk/bin && wine jlink.exe --output Z:/work/jre --add-modules java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.se,java.security.jgss,java.security.sasl,java.smartcardio,java.sql,java.sql.rowset,java.transaction.xa,java.xml,java.xml.crypto,jdk.accessibility,jdk.attach,jdk.charsets,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.dynalink,jdk.editpad,jdk.hotspot.agent,jdk.httpserver,jdk.incubator.vector,jdk.internal.ed,jdk.internal.jvmstat,jdk.internal.le,jdk.internal.opt,jdk.internal.vm.ci,jdk.jcmd,jdk.jconsole,jdk.jdeps,jdk.jdi,jdk.jdwp.agent,jdk.jfr,jdk.jshell,jdk.jsobject,jdk.jstatd,jdk.localedata,jdk.management,jdk.management.agent,jdk.management.jfr,jdk.naming.dns,jdk.naming.rmi,jdk.net,jdk.nio.mapmode,jdk.sctp,jdk.security.auth,jdk.security.jgss,jdk.unsupported,jdk.unsupported.desktop,jdk.xml.dom,jdk.zipfs\"; fi"
        }
      }
    }

    stage('win-javafx') {
      steps {
        sh "mkdir -p $CACHE_DIR/javafx-win"
        dir "$CACHE_DIR/javafx-win", {
          sh "for i in base controls graphics media swing fxml web; do if ! [ -e javafx-\$i-$JAVAFX_VER-win.jar ]; then wget -q https://mvn-mirror.gitverse.ru/org/openjfx/javafx-\$i/$JAVAFX_VER/javafx-\$i-$JAVAFX_VER-win.jar; fi; done"
        }
      }
    }

    stage('dist-win') {
      steps {
      sh "gradle distFilesWin"
        dir ("build/release/dist") {
          sh "cp -r windows /build"
        }
	sh 'chmod 777 /build/windows'
	dir '/build/windows/luwrain', {
	sh "cp $CACHE_DIR/javafx-win/* lib "
	sh "cp -r $CACHE_DIR/jre ."
	}
	sh 'tar -c /build/windows/ > /cache/win-debug.tar'
	
        sh 'docker run --rm -i -v /build/windows:/work amake/innosetup luwrain.iss'
		dir ("/build/windows/Output") {
		sh "cp *.exe /out/_tmp/bundles"
		}
      }
    }

    stage('deb-common') {
      steps {
        sh 'gradle distFilesDeb'
        dir ("build/release/dist/deb/debian") {
          sh "sed -i -e \"s/SUBST_DATE/\$(LANG=C date \"+%a, %d %b %Y %H:%M:%S %z\")/\" changelog"
        }
      }
    }

    stage ('deb-main') {
      matrix {
        axes {
          axis {
            name 'DISTRO'
            values 'bookworm', 'bullseye', 'jammy', 'noble', 'resolute', 'trixie'
          }
        }
        stages {
          stage ('deb-dirs') {
            steps {
              sh "mkdir -p $RELEASE_DIR/apt/dists"
              sh "mkdir -p /build/dpkg/${DISTRO}"
              sh "cp bundles/apt/apt.config.${DISTRO} /build/dpkg/${DISTRO}/apt.config"
              dir ("build/release/dist") { sh "cp -r deb /build/dpkg/${DISTRO}/luwrain" }
            }
          }

          stage ("tdlib") {
            steps {
              sh "mkdir -p $CACHE_DIR/tdlib/"
              script { if (!fileExists("$CACHE_DIR/tdlib/tdlib-${DISTRO}.jar")) { stage ('tdlib-build') {
                sh "mkdir -p /build/tdlib/${DISTRO}"
                dir ("/build/tdlib/${DISTRO}") {
                  sh "git clone https://github.com/marigostra/td/"
                }
                dir ("/build/tdlib/${DISTRO}/td") {
                  sh "git branch java origin/java && git checkout java"
                  sh "docker run --rm -v /build:/build dpkg-${DISTRO} bash -c \"cd /build/tdlib/${DISTRO}/td/ && ./build-java.sh && ./depl-java.sh ./maven2\""
                  sh "cp tdlib-*.jar $CACHE_DIR/tdlib/tdlib-${DISTRO}.jar"
                }
              }}}
            }
          }
	
          stage ('dpkg-build') {
            steps {
              sh "docker run --rm -v /build:/build dpkg-${DISTRO} bash -c \"cd /build/dpkg/${DISTRO}/luwrain && dpkg-buildpackage --build=binary -us -uc\""
            }
          }

          stage ('dep-repo') {
steps {
        dir ("/build/dpkg/${DISTRO}") {
          sh "mkdir -p dists/$DISTRO/luwrain/binary-amd64"
          sh "cp *.deb dists/${DISTRO}/luwrain/binary-amd64"
        }
        sh "docker run --rm -v /build:/build dpkg-${DISTRO} bash -c \"cd /build/dpkg/${DISTRO}/ && dpkg-scanpackages dists/${DISTRO}/luwrain/binary-amd64 /dev/null > dists/${DISTRO}/luwrain/binary-amd64/Packages\""
        sh "docker run --rm -v /build:/build dpkg-${DISTRO} bash -c \"cd /build/dpkg/${DISTRO}/dists/${DISTRO} && apt-ftparchive release -c ../../apt.config . > Release\""
	}
          }

          stage ('deb-signing') {
steps {
        sh 'gpg --default-key info@luwrain.org --clearsign --passphrase-fd 0 -o /build/dpkg/${DISTRO}/dists/${DISTRO}/InRelease /build/dpkg/${DISTRO}/dists/${DISTRO}/Release < /cache/dpkg-key-passphrase'
        sh "cp -r /build/dpkg/${DISTRO}/dists/${DISTRO} $RELEASE_DIR/apt/dists"
      }
    }
    }
    }
    }

    stage('javadoc') {
      steps {
          sh 'gradle distJavadoc'
dir ('build/release') {
sh 'cp -r javadoc /out/_tmp/'
}
	  }
    }

    stage('maven') {
      steps {
        sh 'gradle publish'
      }
    }

    stage("finalizing") {
      steps {
      //Writing version information
        sh 'gradle writeVer'
        sh 'git rev-parse HEAD > /out/_tmp/commit.txt'
        sh 'LANG=C date > /out/_tmp/timestamp.txt'
        sh 'cp build/version.txt /out/_tmp/'
	//Writing hashsums
	dir ('/out/_tmp/bundles') {
	sh 'sha256sum luwrain-$(cat ../version.txt).zip > luwrain-$(cat ../version.txt).zip.sha256'
		sh 'sha256sum luwrain-$(cat ../version.txt).exe > luwrain-$(cat ../version.txt).exe.sha256'
	}
	}
	}
  }

  post {
    success {
      dir ("/out") {
        sh "mv release _release"
          sh "mv _tmp release"
        sh "rm -rf _release"
      }
    }
    failure {
      dir ('/out') { sh 'rm -rf _tmp' }
    }
    always {
      sh 'gradle clean'
      dir ('sounds') { sh 'rm -rf *.wav *.xz' }
      sh 'rm -f core/src/main/resources/org/luwrain/core/sound/*.wav'
      dir ('/build') { sh 'rm -rf *' }
    }
  }
}
