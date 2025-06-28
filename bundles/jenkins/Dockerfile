FROM jenkins/jenkins:latest
USER root
VOLUME /out
VOLUME /build

# docker exec jenkins bash -c 'docker context create dind --description "Docker-in-docker for Jenkins" --docker "host=tcp://docker:2376,ca=/certs/client/ca.pem,cert=/certs/client/cert.pem,key=/certs/client/key.pem"'
# docker exec jenkins bash -c 'docker context use dind'
ARG USER_HOME_DIR="/root"

RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends openjdk-17-jdk wget unzip xz-utils curl git iputils-ping docker.io timidity fluid-soundfont-gm midicsv sox gnupg2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /gradle
RUN wget https://services.gradle.org/distributions/gradle-8.8-bin.zip && unzip *.zip && rm -f *.zip && mv gradle-*/* . && rmdir gradle-*

WORKDIR /app
COPY init-docker init-dpkg-images /app/
COPY env/* /app/

RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends timidity fluid-soundfont-gm midicsv sox \
    && rm -rf /var/lib/apt/lists/*

ENV PATH $PATH:/gradle/bin:/app
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
