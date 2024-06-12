pipeline {
    agent any

    environment {
        JAVA_HOME = "/usr/lib/jvm/java-17-openjdk-amd64"
    }

    stages {

        stage('Checkout') {
            steps {
                sh 'git submodule update --init --recursive ./parent'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn install'
                dir('base/scripts') {
                    sh './lwr-ant-gen-all'
                    sh './lwr-build'
                }
            }
        }

        stage('Generate dist') {
            steps {
                sh './lwr-dist-linux /tmp/lwr'
            }
        }
    }
}
