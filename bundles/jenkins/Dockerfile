FROM jenkins/jenkins:latest
USER root

#ARG MAVEN_VERSION=3.8.8
ARG USER_HOME_DIR="/root"
#ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends openjdk-17-jdk wget unzip curl git && \
    rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64

WORKDIR /gradle
RUN wget https://services.gradle.org/distributions/gradle-8.8-bin.zip && unzip *.zip && rm -f *.zip && mv gradle-*/* . && rmdir gradle-*

#RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
# && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
# && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
# && rm -f /tmp/apache-maven.tar.gz \
# && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

#ENV MAVEN_HOME /usr/share/maven
#ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN mkdir /out

WORKDIR /app

RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends timidity fluid-soundfont-gm midicsv sox ant wget xz-utils \
    && rm -rf /var/lib/apt/lists/*

ENV PATH $PATH:/gradle/bin
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml

