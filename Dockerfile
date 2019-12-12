# s2i-tomcat
FROM openshift/base-centos7

EXPOSE 8080

ENV TOMCAT_VERSION=8.5.34 \
    MAVEN_VERSION=3.5.4 \
    STI_SCRIPTS_PATH=/usr/libexec/s2i/

LABEL io.k8s.description="Platform for building and running JEE applications on Tomcat" \
      io.k8s.display-name="Tomcat Builder" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,tomcat" \
      io.openshift.s2i.destination="/opt/s2i/destination"

COPY  apache-maven-3.5.4-bin.tar /
COPY  apache-tomcat-8.5.34.tar /
#Install Maven, Tomcat 8.5.24
RUN INSTALL_PKGS="tat java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rmp -V $INSTALL_PKGS && \
    yum clean all -y && \
    tar -xvf /apache-maven-3.5.4-bin.tar -C /usr/local && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p  $HOME/.m2 && \
    mkdir -p  /tomcat && \
    tar -xvf /apache-tomcat-8.5.34.tar --strip-components=1 -C /tomcat && \
    rm -rf /tomcat.webapps/* && \
    mkdir -p /opt/s2i/destination && \
    mkdir /tmp/src && \
    mkdir -p /opt/maven/reponsitory/ && \
    chmod 777 /opt/maven/respository
# Add s2i customizations
ADD ./setting.xml $HOME/ .m2/

# COPY the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
# CPPY ./s2i/bin/ $STI_SCRIPTS_PATH
COPY ./s2i/bin/ /usr/libexec/s2i


RUN chmod -R a+rw /tomcat && \
    chmod a+rwx /tomcat/* && \
    chmod +x /tomcat/bin/* .sh && \
    chmod -R a+rw $HOME && \
    chmod -R +x $STI_SCRIPTS_PATH && \
    chmod -R g+rw /opt/s2i/destination

USER 1001

CMD $STI_SCRIPTS_PATH/usage

# TODO: Put the maintainer name in the image metadata
# LABEL maintainer="Your Name <your@email.com>"

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
#LABEL io.k8s.description="Platform for building xyz" \
#      io.k8s.display-name="builder x.y.z" \
#      io.openshift.expose-services="8080:http" \
#      io.openshift.tags="builder,x.y.z,etc."

# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y
RUN yum install -y rubygems && yum clean all -y
RUN gem install asdf

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
# RUN chown -R 1001:1001 /opt/app-root

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
# EXPOSE 8080

# TODO: Set the default CMD for the image
# CMD ["/usr/libexec/s2i/usage"]
