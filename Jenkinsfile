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
        sh 'rm -rf /build/*'
        dir ('/out') {
          sh "mkdir -p release"
          sh 'rm -rf _tmp'
          sh "mkdir -p _tmp/bundles"
          sh "mkdir _tmp/apt"
        }
        sh 'gradle clean'
        dir('sounds') {
          sh 'rm -f *.wav *.xz'
        }
        sh 'rm -f core/src/main/resources/org/luwrain/core/sound/*.wav'
        //sh "rm -rf .gradle"
      }
    }

    stage('Build') {
      steps {
        dir ('sounds') {
          sh './make'
	  //sh 'cp *.wav ../core/src/main/resources/org/luwrain/core/sound'
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

    stage('win') {
      steps {
      sh "gradle distFilesWin"
        dir ("/cache") {
          sh "if ! [ -d jdk ]; then wget https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_windows-x64_bin.zip; unzip *.zip; rm -f *.zip; mv jdk-* jdk; fi"
          sh "if ! [ -d jre ]; then docker run --rm -v /cache:/work ich777/winehq-baseimage bash -c \"cd /work/jdk/bin && wine jlink.exe --output Z:/work/jre --add-modules java.base,java.compiler,java.datatransfer,java.desktop,java.instrument,java.logging,java.management,java.management.rmi,java.naming,java.net.http,java.prefs,java.rmi,java.scripting,java.se,java.security.jgss,java.security.sasl,java.smartcardio,java.sql,java.sql.rowset,java.transaction.xa,java.xml,java.xml.crypto,jdk.accessibility,jdk.attach,jdk.charsets,jdk.compiler,jdk.crypto.cryptoki,jdk.crypto.ec,jdk.dynalink,jdk.editpad,jdk.hotspot.agent,jdk.httpserver,jdk.incubator.vector,jdk.internal.ed,jdk.internal.jvmstat,jdk.internal.le,jdk.internal.opt,jdk.internal.vm.ci,jdk.internal.vm.compiler,jdk.internal.vm.compiler.management,jdk.jartool,jdk.javadoc,jdk.jcmd,jdk.jconsole,jdk.jdeps,jdk.jdi,jdk.jdwp.agent,jdk.jfr,jdk.jlink,jdk.jpackage,jdk.jshell,jdk.jsobject,jdk.jstatd,jdk.localedata,jdk.management,jdk.management.agent,jdk.management.jfr,jdk.naming.dns,jdk.naming.rmi,jdk.net,jdk.nio.mapmode,jdk.sctp,jdk.security.auth,jdk.security.jgss,jdk.unsupported,jdk.unsupported.desktop,jdk.xml.dom,jdk.zipfs\"; fi"
        }
        sh 'mkdir -p /cache/javafx-win'
        dir '/cache/javafx-win', {
          sh 'for i in base controls graphics media swing fxml web; do if ! [ -e javafx-$i-17-win.jar ]; then wget -q https://mvn-mirror.gitverse.ru/org/openjfx/javafx-$i/17/javafx-$i-17-win.jar; fi; done'
        }
        dir ("build/release/dist") {
sh "cp -r windows /build"
        }
	sh 'chmod 777 /build/windows'
	dir '/build/windows/luwrain', {
	sh 'cp /cache/javafx-win/* lib '
	sh 'cp -r /cache/jre .'
	}
	sh 'tar -c /build/windows/ > /cache/win-debug.tar'
	
        sh 'docker run --rm -i -v /build/windows:/work amake/innosetup luwrain.iss'
		dir ("/build/windows/Output") {
		sh "cp *.exe /out/_tmp/bundles"
		}
      }
    }

    stage('deb') {
      steps {
        sh 'gradle distFilesDeb'
        dir ("build/release/dist/deb/debian") {
          sh "sed -i -e \"s/SUBST_DATE/\$(LANG=C date \"+%a, %d %b %Y %H:%M:%S %z\")/\" changelog"
        }
        sh "mkdir -p /out/_tmp/apt/dists"

        // Jammy
        sh "mkdir -p /build/dpkg/jammy"
        sh "cp bundles/apt/apt.config.jammy /build/dpkg/jammy/apt.config"
        dir ("build/release/dist") { sh "cp -r deb /build/dpkg/jammy/luwrain" }
        sh "docker run --rm -v /build:/build dpkg-jammy bash -c \"cd /build/dpkg/jammy/luwrain && dpkg-buildpackage --build=binary -us -uc\""
        dir ("/build/dpkg/jammy") {
          sh "mkdir -p dists/jammy/luwrain/binary-amd64"
          sh "cp *.deb dists/jammy/luwrain/binary-amd64"
        }
        sh "docker run --rm -v /build:/build dpkg-jammy bash -c \"cd /build/dpkg/jammy/ && dpkg-scanpackages dists/jammy/luwrain/binary-amd64 /dev/null > dists/jammy/luwrain/binary-amd64/Packages\""
        sh "docker run --rm -v /build:/build dpkg-jammy bash -c \"cd /build/dpkg/jammy/dists/jammy && apt-ftparchive release -c ../../apt.config . > Release\""
        sh 'gpg --default-key info@luwrain.org --clearsign --passphrase-fd 0 -o /build/dpkg/jammy/dists/jammy/InRelease /build/dpkg/jammy/dists/jammy/Release < /cache/dpkg-key-passphrase'
        sh "cp -r /build/dpkg/jammy/dists/jammy /out/_tmp/apt/dists"

	// Noble
        sh "mkdir -p /build/dpkg/noble"
        sh "cp bundles/apt/apt.config.noble /build/dpkg/noble/apt.config"
        dir ("build/release/dist") { sh "cp -r deb /build/dpkg/noble/luwrain" }
        sh "docker run --rm -v /build:/build dpkg-noble bash -c \"cd /build/dpkg/noble/luwrain && dpkg-buildpackage --build=binary -us -uc\""
        dir ("/build/dpkg/noble") {
          sh "mkdir -p dists/noble/luwrain/binary-amd64"
          sh "cp *.deb dists/noble/luwrain/binary-amd64"
        }
        sh "docker run --rm -v /build:/build dpkg-noble bash -c \"cd /build/dpkg/noble/ && dpkg-scanpackages dists/noble/luwrain/binary-amd64 /dev/null > dists/noble/luwrain/binary-amd64/Packages\""
        sh "docker run --rm -v /build:/build dpkg-noble bash -c \"cd /build/dpkg/noble/dists/noble && apt-ftparchive release -c ../../apt.config . > Release\""
        sh 'gpg --default-key info@luwrain.org --clearsign --passphrase-fd 0 -o /build/dpkg/noble/dists/noble/InRelease /build/dpkg/noble/dists/noble/Release < /cache/dpkg-key-passphrase'
        sh "cp -r /build/dpkg/noble/dists/noble /out/_tmp/apt/dists"
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
        dir ('core') {
          sh 'gradle publish'
        }
        dir ('pim/pim') {
          sh 'gradle publish'
        }
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
        dir ("/out") {
          sh "mv release _release"
          sh "mv _tmp release"
          sh "rm -rf _release"
        }
		//Cleaning the build dir
        dir ('/build') {
          sh 'rm -rf *'
        }

      }
    }
  }
}
