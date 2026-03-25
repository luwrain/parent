FROM jenkins/jenkins:latest
USER root
VOLUME /out
VOLUME /build

#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
#chmod a+r /usr/share/keyrings/docker.gpg


# docker exec jenkins bash -c 'docker context create dind --description "Docker-in-docker for Jenkins" --docker "host=tcp://docker:2376,ca=/certs/client/ca.pem,cert=/certs/client/cert.pem,key=/certs/client/key.pem"'
# docker exec jenkins bash -c 'docker context use dind'
ARG USER_HOME_DIR="/root"

RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends openjdk-21-jdk wget curl unzip xz-utils \
    gnupg2 ca-certificates  lsb-release  git iputils-ping apt-transport-https \
    timidity fluid-soundfont-gm midicsv sox \
    && rm -rf /var/lib/apt/lists/*

# INstalling gradle
WORKDIR /gradle
RUN wget https://services.gradle.org/distributions/gradle-8.8-bin.zip && unzip *.zip && rm -f *.zip && mv gradle-*/* . && rmdir gradle-*

WORKDIR /app
COPY init-docker-context init-dpkg-images /app/
COPY env/* /app/

RUN mkdir -p /root/.gnupg && chmod 700 /root/.gnupg
COPY gpg.conf gpg-agent.conf dpkg.key /root/.gnupg/
RUN gpg --batch --no-tty --import /root/.gnupg/dpkg.key
RUN rm -f /root/.gnupg/dpkg.key

# Installing docker
RUN                         echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
RUN                         install -m 0755 -d /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && chmod 644 /etc/apt/keyrings/docker.asc
RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin





ENV PATH $PATH:/gradle/bin:/app
ENV JAVA_HOME /usr/lib/jvm/java-21-openjdk-amd64
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
